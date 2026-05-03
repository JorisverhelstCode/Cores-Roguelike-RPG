# Building Aftermath

This project can be exported from Godot as downloadable builds or as a browser-playable web build.

## One-time setup

1. Open the project in Godot.
2. Install export templates if Godot asks for them:
   - `Editor > Manage Export Templates`
   - Download and install the matching templates for your Godot version.
3. Open `Project > Export` and confirm the presets:
   - `Windows`
   - `Linux`
   - `Web`

## Build from the Godot editor

1. Open `Project > Export`.
2. Select a preset.
3. Click `Export Project`.
4. Use the preset's default output path:
   - Windows: `build/windows/Aftermath.exe`
   - Linux: `build/linux/Aftermath.x86_64`
   - Web: `build/web/index.html`

## Build from command line

From this folder:

```powershell
godot --headless --path . --export-release "Windows" "build/windows/Aftermath.exe"
godot --headless --path . --export-release "Linux" "build/linux/Aftermath.x86_64"
godot --headless --path . --export-release "Web" "build/web/index.html"
```

If a command says export templates are missing, install them in Godot first.

## Sharing downloads

For Windows, zip the contents of `build/windows` and share the zip. Since the preset embeds the `.pck`, the `.exe` should be the main file people run.

For Linux, zip `build/linux` and tell players to run `Aftermath.x86_64`. They may need to mark it executable.

## Putting it online

The `Web` export creates files in `build/web`. Upload all files in that folder to a static web host. Good options include itch.io, GitHub Pages, Netlify, or any normal web server.

For itch.io:

1. Create a new project.
2. Set `Kind of project` to `HTML`.
3. Zip the contents of `build/web`.
4. Upload that zip.
5. Check `This file will be played in the browser`.

The web build is useful for quick access, while the Windows/Linux builds are better for downloadable play.
