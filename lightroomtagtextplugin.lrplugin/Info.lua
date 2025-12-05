--Forked from https://github.com/gesteves/lightroom-alt-text-plugin/
return {
  LrSdkVersion = 6.0,
  LrSdkMinimumVersion = 6.0,
  LrPluginName = "Tag Generator",
  LrToolkitIdentifier = "com.example.lightroom.taggenerator",
  LrPluginInfoUrl = "https://github.com/r4wkkl4/lightroom-ai-tag-plugin",
  LrInitPlugin = "TagGenerator.lua",
  LrLibraryMenuItems = {
      {
          title = "Generate Tags with an OpenAI API endpoint",
          file = "TagGenerator.lua",
      },
  },
  LrPluginInfoProvider = 'PluginInfoProvider.lua',
  VERSION = { major=1, minor=0, revision=0, build=1, },
}
