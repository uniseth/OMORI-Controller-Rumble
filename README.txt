========================================================================================================
                                                         ▄▄                                         
                                                    █▄    ██         █▄               █▄            
       ▄              ▄    ▀▀   ▄          ▄        ██    ██         ██    ▄    ▀▀    ██    ▄▄      
 ▄███▄ ███▄███▄ ▄███▄ ████▄██   ████▄██ ██ ███▄███▄ ████▄ ██ ▄█▀█▄   ████▄ ████▄██ ▄████ ▄████ ▄█▀█▄
 ██ ██ ██ ██ ██ ██ ██ ██   ██   ██   ██ ██ ██ ██ ██ ██ ██ ██ ██▄█▀   ██ ██ ██   ██ ██ ██ ██ ██ ██▄█▀
▄▀███▀▄██ ██ ▀█▄▀███▀▄█▀  ▄██  ▄█▀  ▄▀██▀█▄██ ██ ▀█▄████▀▄██▄▀█▄▄▄  ▄████▀▄█▀  ▄██▄█▀███▄▀████▄▀█▄▄▄
                                                                                            ██      
                                                                                          ▀▀▀       
========================================================================================================

A lightweight, zero-drift controller vibration bridge for OMORI.

This repository contains:
 * A C++ executable (RumbleBridge) that handles hardware XInput/ViGEm communication.
 * The OMORI mod (included in the OMORI Mod folder) that sends vibration commands.
 * A smart PowerShell launcher that handles automatic updates, mod installation, and cosmetic themes.

====================================================================================================
TABLE OF CONTENTS
====================================================================================================

1. REQUIREMENTS
2. FOR DEVELOPERS: HOW TO COMPILE
3. FOR PLAYERS: HOW TO RUN
4. CONFIGURATION & CUSTOMIZATION (config.txt)
5. CUSTOM QUOTES (quotes.txt)
6. INPUT FORMAT
7. TROUBLESHOOTING

====================================================================================================
1. REQUIREMENTS
====================================================================================================

To Compile:
- Visual Studio 2019 or newer (with C++ Desktop Development workload)
- Windows 10/11 SDK

To Run:
- Windows 10 / 11
- Xbox controller (or XInput/ViGEmClient-compatible controller)
- An active internet connection for automatic updates

====================================================================================================
2. FOR DEVELOPERS: HOW TO COMPILE
====================================================================================================

1. Open "RumbleBridge.sln" in Visual Studio.
2. The required dependencies are already included in the "dependencies" folder. The project file is configured to find them.
3. Set your build mode to "Release" and platform to "x64".
4. Click Build -> Build Solution.
5. Once compiled, navigate to x64/Release/.
6. A Post-Build event is included in the project. It will automatically 
   copy start.bat, README.txt, ViGEmClient.dll, quotes.txt, and config.txt 
   right next to your new .exe. You do not need to copy them manually!

====================================================================================================
3. FOR PLAYERS: HOW TO RUN
====================================================================================================

If you downloaded a pre-compiled Release from the GitHub Releases page:

1. Extract the files into a folder.
2. Ensure start.bat and Launch-Rumble.ps1 are in the same folder.
3. Double-click "start.bat" to launch the OMORI Controller Bridge.

What happens next?
The launcher script will automatically do the following:
- Check for the latest version on GitHub and download updates if available.
- Automatically install (or update) the OMORI mod into your Steam installation.
- Launch both Rumble Bridge and OMORI.exe.

IMPORTANT: Because the launcher now manages the mod files, please do not manually 
copy the mod files to your OMORI directory unless you REALLY need to. Just let the script handle it!

----------------------------------------------------------------------------------------
LAUNCHING FROM STEAM (Optional)
----------------------------------------------------------------------------------------
If you want the Rumble Bridge to automatically start up every time you launch 
OMORI through Steam, you can use a quick workaround using Steam's Launch Options.

1. Right-click OMORI in your Steam Library and select "Properties".
2. In the "General" tab, find the "Launch Options" text box.
3. Paste the following line (adjust the path if your mod files are in a 
   different folder):

   "C:\SteamLibrary\steamapps\common\OMORI\Rumble-Bridge\start.bat" %command%

4. Close the window and click "PLAY" in Steam!

TIP: If you don't want the tool to pause and ask you to confirm updates every time 
you click Play, open config.txt and set:
   Auto = true
----------------------------------------------------------------------------------------

====================================================================================================
4. CONFIGURATION & CUSTOMIZATION (config.txt)
====================================================================================================

The `config.txt` file allows you to tweak how the launcher behaves without 
editing code. If it doesn't exist, the launcher will generate a default one 
for you on the first run.

CORE SETTINGS:
- Debug = true: Pauses the window on exit so you can read error logs. Also prints 
  highly detailed background information to the console.
- Auto = true: Automatically accepts all update prompts (great for Steam shortcuts).
- LaunchMethod = direct: Launches OMORI.exe directly like a normal app. 
  LaunchMethod = steam: (Default) Launches via Steam protocol.

THEME SETTINGS:
The launcher features a colorful ASCII art header that can be customized!

- `Theme = random`: (Default) Picks a random color scheme every launch.
- `Theme = og`: Uses the original color scheme.
- `Theme = trans`, `pan`, `bi`, `lesbian`, `gay`, `ace`, etc.: Forces a specific Pride flag theme.
- `Theme = matrix`, `amber`, `dos`, `retro`, `bloodmoon`, etc.: Forces a retro or gradient theme.
- `Theme = xmas`, `halloween`, `valentine`, `easter`, etc.: Forces a specific holiday theme.
  *Note: If left on `random`, holiday themes will automatically activate on their respective dates! Otherwise, you must set them manually.*

CREATING CUSTOM THEMES:
You can create your own 9-color gradient themes! Set `Theme = custom` and define 
your colors like this:
`CustomTheme = Red, White, Red, White, Red, White, Red, White, Red`

Valid colors: Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, 
DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White.

APRIL FOOLS:
- AprilFools = true: Reverses the ASCII art!
  (Works with ALL color themes).

====================================================================================================
5. CUSTOM QUOTES (quotes.txt)
====================================================================================================

By default, the launcher displays a random message when it opens. You can replace these with whatever you want!

1. Open `quotes.txt` (or create one if it's missing).
2. Add quotes, one per line.
3. Save the file. The launcher will randomly pick one every time it starts.

If you delete `quotes.txt`, the launcher will safely fall back to a single line.

====================================================================================================
6. INPUT FORMAT
====================================================================================================

The bridge receives TCP messages in this format:

    intensity time_ms fade_flag

Example:
    0.8 120 0   (80% power, 120ms, instant stop)
    0.3 60 0    (30% power, 60ms, instant stop)
    1.0 500 1   (100% power, 500ms, smooth fade out)

====================================================================================================
7. TROUBLESHOOTING
====================================================================================================

NO CONTROLLER FOUND
- Plug in your controller before launching the bridge.
- Check Windows (Win + R) "joy.cpl" to confirm it is detected.

GAME DOES NOT CONNECT
- Ensure the bridge is running before launching OMORI.
- Check firewall settings for localhost access.
- Make sure port 9002 is not in use.

LAUNCHER KEEPS FAILING OR NOT FINDING OMORI
- Open `config.txt` and set `Debug = true`.
- Run `start.bat` again. It will now print exactly what folders it's checking.
- If Steam is installed in a custom location, you can force the path in `config.txt`:
  `OmoriPath = D:\Games\SteamLibrary\steamapps\common\OMORI`

UPDATES KEEP FAILING
- Check your internet connection.
- If you are behind a strict firewall, the script might not be able to reach GitHub.

COMPILATION ERRORS
- Ensure you are using C++17 standard in Visual Studio project properties.
- Ensure the "dependencies" folder wasn't deleted or moved.

====================================================================================================
CREDITS
====================================================================================================

Author: Sierra
Made with love for the OMORI modding community <3

====================================================================================================