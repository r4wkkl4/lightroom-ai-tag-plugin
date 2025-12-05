# Lightroom Tag Generator Plugin

A lightweight, AI‑powered Lightroom Classic plugin that automatically generates keywords for your photos based on the image contents.  
The plugin sends a resized preview to an OpenAI‑compatible endpoint and expects a response containing a comma separated list of tags.

---
## Getting Started

### Download

Download the latest release tarball or clone the repository:

```bash
git clone https://github.com/r4wkkl4/lightroom-ai-tag-plugin.git
```

### Installation (OSX)

1. **Build the plugin** – The project uses only plain Lua and no external
   build steps are required.  
2. **Copy the `.lrplugin` folder** – Place the entire `TagGenerator.lrplugin`
   directory into:

```
/Applications/Adobe Lightroom Classic/Adobe Lightroom Classic.app/Contents/PlugIns
```

> **Note** – The path is the standard Lightning plug‑in location on macOS.  
> After adding the folder, start (or restart) Lightroom Classic to load it.

3. **Enable in Lightroom** – Open `Lightroom Classic → File → Plug-in Manager.  
   Find **Tag Generator** in the list, set its status to **Enabled** and complete the configuration (see next section).

---

## Configuration

The plugin relies on three settings that must be entered once in the
Lightroom Plug‑in Manager:

| Setting      | Description                                 |
|--------------|---------------------------------------------|
| **API URL**  | Full base URL of the OpenAI‑compatible API, e.g. `https://api.openai.com/v1` |
| **API Key**  | Secret key for authentication.             |
| **Model Name** | The model to use, e.g. `gpt-5.1` or a local LLM such as `mistralai/ministral-3-3b`. |

>**Note:**
> The endpoint provided must support the `responses` endpoint.

> **Tip:**  
A pre‑defined prompt (hard coded in `config.lua`).

> **Tip:**  
> The plugin has been used successfully with mini‑LLMs such as `Ministral-3-3B-Instruct-2512` hosted locally via **LMStudio**.  

### Plug‑in Manager Pane

After launching Lightroom, open **Preferences → Plug‑ins**.  
Locate the *Tag Generator* plugin and click **Configure**:

```
API URL:     http://127.0.0.1:1234/v1          (example LMStudio URL)
API Key:     1234                              (LMStudio does not require a key)
Model Name:  mistralai/ministral-3-3b          (or your local model)
```

> The plugin only uses the values above; no further authentication modes
> are supported.

---

## Usage

1. Select one or more photos in the Library module.
2. Click Library → Plugin Extras → *Generate Tags with an OpenAI API endpoint*.
3. The plugin will resize an intermediate image, transmit it to your endpoint, and create keywords from the returned response.
4. Once finished a confirmation bezel will appear, and the keywords are applied to the selected photos.

> The operation is fully asynchronous; Lightroom remains responsive during tagging.

---

## Compatibility

- **OS X:** Tested on macOS **Sequoia** (macOS 14.1).
- **Lightroom Classic:** Tested on **v15.0.1**.

> The plugin uses only standard Lightroom SDK functions and Lua 5.3,
> so it should work on any later release of Lightroom Classic
> (and other supported OS versions) with minimal adjustments.

---

## Credits

- **[gesteves/lightroom-alt-text-plugin](https://github.com/gesteves/lightroom-alt-text-plugin)** –  
  The foundational architecture for this plugin came from the alt‑text
  generator example.
- **[CommRogue/lrc-ai-assistant](https://github.com/CommRogue/lrc-ai-assistant)** –  
  Shared utilities and workflow patterns used in the tagging logic.
- **[midzelis/mi.Immich.Publisher](https://github.com/midzelis/mi.Immich.Publisher)** –  
  Inspiration for configuration handling and utility functions.
