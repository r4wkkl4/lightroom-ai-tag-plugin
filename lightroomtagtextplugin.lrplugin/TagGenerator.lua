local LrApplication = import 'LrApplication'
local LrDialogs = import 'LrDialogs'
local LrTasks = import 'LrTasks'
local LrHttp = import 'LrHttp'
local LrFileUtils = import 'LrFileUtils'
local LrExportSession = import 'LrExportSession'
local LrStringUtils = import 'LrStringUtils'
local LrPathUtils = import 'LrPathUtils'
local LrPrefs = import 'LrPrefs'
local LrFunctionContext = import 'LrFunctionContext'
local LrProgressScope = import 'LrProgressScope'
local LrLogger = import 'LrLogger'

local logger = LrLogger('TagTextPlugin')
logger:enable("logfile")

local configPath = LrPathUtils.child(_PLUGIN.path, 'config.lua')
local config = dofile(configPath)
local prefs = LrPrefs.prefsForPlugin()
local dkjsonPath = LrPathUtils.child(_PLUGIN.path, 'dkjson.lua')
local json = dofile(dkjsonPath)

local function resizePhoto(photo, progressScope)
    progressScope:setCaption("Resizing photo...")
    local tempDir = LrPathUtils.getStandardFilePath('temp')
    local photoName = LrPathUtils.leafName(photo:getFormattedMetadata('fileName'))
    local resizedPhotoPath = LrPathUtils.child(tempDir, photoName)

    if LrFileUtils.exists(resizedPhotoPath) then
        return nil
    end

    local exportSettings = {
        LR_export_destinationType = 'specificFolder',
        LR_export_destinationPathPrefix = tempDir,
        LR_export_useSubfolder = false,
        LR_format = 'JPEG',
        LR_jpeg_quality = 0.8,
        LR_minimizeEmbeddedMetadata = true,
        LR_outputSharpeningOn = false,
        LR_size_doConstrain = true,
        LR_size_maxHeight = 1024,--2000,
        LR_size_maxWidth = 1024,
        LR_size_resizeType = 'wh',
        LR_size_units = 'pixels',
    }

    local exportSession = LrExportSession({
        photosToExport = {photo},
        exportSettings = exportSettings
    })

    for _, rendition in exportSession:renditions() do
        local success, path = rendition:waitForRender()
        if success then
            return path
        end
    end

    return nil
end

local function encodePhotoToBase64(filePath, progressScope)
    progressScope:setCaption("Encoding photo...")

    local file = io.open(filePath, "rb")
    if not file then
        return nil
    end

    local data = file:read("*all")
    file:close()

    return LrStringUtils.encodeBase64(data)
end

local function requestTagsFromAI(imageBase64, progressScope)
    progressScope:setCaption("Requesting tag text from API...")
    local apiKey = prefs.apiKey --config.API_KEY
    if not apiKey then
        LrDialogs.message("Your API key is missing. Please set it up in the plugin manager.")
        return nil
    end
    local apiUrl = prefs.apiUrl
    if not apiUrl then
        LrDialogs.message("Your API URL is missing. Please set it up in the plugin manager.")
        return nil
    end
    local modelName = prefs.modelName
    if not modelName then
        LrDialogs.message("Your Model Name is missing. Please set it up in the plugin manager.")
        return nil
    end

    local url = apiUrl .. "/responses"
    local headers = {
        { field = "Content-Type", value = "application/json" },
        { field = "Authorization", value = "Bearer " .. apiKey },
    }

    local body = {
        model = modelName,--config.MODEL,
--        store = false,
--        instructions = config.INSTRUCTIONS,
--        user = "lightroom-plugin",
        input = {
            {
                role = "user",
                content = {
                    {
                        type = "input_text",
                        text = config.INSTRUCTIONS
                    },
                    {
                        type = "input_image",
                        image_url = "data:image/jpeg;base64," .. imageBase64
                    }
                }
            }
        },
        text = {
            format = {
                type = "json_schema",
                name = "tag_text",
                schema = {
                    type = "object",
                    properties = {
                        tagText = { type = "string" }
                    },
                    required = { "tagText" },
                    additionalProperties = false
                }
            }
        }
    }

    local bodyJson = json.encode(body)
    local response, _ = LrHttp.post(url, bodyJson, headers)

    if not response then
        LrDialogs.message("No response from AI API. Please try again.")
        return nil
    end

    local ok, decoded = pcall(json.decode, response)
    if not ok then
        logger:trace("Failed to parse API response: " .. tostring(response))
        LrDialogs.message("Invalid response from API.")
        return nil
    end

    -- Check for API error
    if decoded.error and decoded.error.message then
        logger:trace("API error:\n" .. json.encode(decoded, { indent = true }))
        LrDialogs.message("API error: " .. decoded.error.message)
        return nil
    end

    -- Normal success path
    local outputs = decoded.output or {}
    for _, output in ipairs(outputs) do
        if output.role == "assistant" and output.content and output.content[1] and output.content[1].text then
            return output.content[1].text
        end
    end

    LrDialogs.message("API returned an unexpected response.")
    return nil
end

-- Check if val is empty or nil
-- Taken from https://github.com/midzelis/mi.Immich.Publisher/blob/main/Utils.lua
local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

--Taken from https://github.com/CommRogue/lrc-ai-assistant/blob/main/lrc-ai-assistant.lrplugin/Util.lua
local function string_split(s, delimiter)
    local t = {}
    for str in string.gmatch(s, "([^" .. delimiter .. "]+)") do
        table.insert(t, trim(str))
    end
    return t
end

local function generateTagsForPhoto(photo, progressScope)
    local resizedFilePath = resizePhoto(photo, progressScope)
    if not resizedFilePath then
        return false
    end

    local base64Image = encodePhotoToBase64(resizedFilePath, progressScope)
    if not base64Image then
        return false
    end

    LrFileUtils.delete(resizedFilePath)

    local response = requestTagsFromAI(base64Image, progressScope)

    if response then 
        local ai_tags = response
        photo.catalog:withWriteAccessDo("Set Keyword", function()
            tags_list = string_split(ai_tags, ',')
            for i, tag in next, tags_list do
                keyword = photo.catalog:createKeyword(tag, {}, true, nil, true)
                photo:addKeyword(keyword)
            end
        end)
        LrDialogs.showBezel("Tags generated and saved to keywords.")
        return true
    end

    return false
end

LrTasks.startAsyncTask(function()
    LrFunctionContext.callWithContext("GenerateTags", function(context)
        local catalog = LrApplication.activeCatalog()
        local selectedPhotos = catalog:getTargetPhotos()

        if #selectedPhotos == 0 then
            LrDialogs.message("Please select at least one photo.")
            return
        end

        local progressScope = LrProgressScope({
            title = "Generating Tags",
            functionContext = context,
        })

        for i, photo in ipairs(selectedPhotos) do
            progressScope:setPortionComplete(i - 1, #selectedPhotos)
            if not generateTagsForPhoto(photo, progressScope) then
                break
            end
            progressScope:setPortionComplete(i, #selectedPhotos)
        end

        progressScope:done()
    end)
end)
