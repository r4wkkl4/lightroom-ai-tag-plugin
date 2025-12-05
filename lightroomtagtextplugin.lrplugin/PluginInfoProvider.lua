local LrView = import 'LrView'
local LrPrefs = import 'LrPrefs'
local LrBinding = import 'LrBinding'

local prefs = LrPrefs.prefsForPlugin()

return {
    sectionsForTopOfDialog = function(f)
        local bind = LrView.bind
        local share = LrView.share

        return {
            {
                title = "AI Keyword Generator Settings",
                f:row {
                    f:static_text {
                        title = "API URL (e.g. https://api.openai.com/v1):",
                        alignment = 'right',
                        width = share 'label_width',
                    },
                    f:edit_field {
                        value = bind { key = 'apiUrl', object = prefs },
                        width_in_chars = 150,
                    },
                },
                f:row {
                    f:static_text {
                        title = "API Key:",
                        alignment = 'right',
                        width = share 'label_width',
                    },
                    f:edit_field {
                        value = bind { key = 'apiKey', object = prefs },
                        width_in_chars = 50,
                    },
                },
                f:row {
                    f:static_text {
                        title = "Model Name (e.g. gpt-5.1):",
                        alignment = 'right',
                        width = share 'label_width',
                    },
                    f:edit_field {
                        value = bind { key = 'modelName', object = prefs },
                        width_in_chars = 50,
                    },
                },
            },
        }
    end,
}
