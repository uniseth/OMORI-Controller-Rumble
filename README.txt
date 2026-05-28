====================================================================================================
  ____  __  _______  ___  ____  ___  __  ____  ______  __   ____  ___  ___  _______  _________
 / __ \/  |/  / __ \/ _ \/  _/ / _ \/ / / /  |/  / _ )/ /  / __/ / _ )/ _ \/  _/ _ \/ ___/ __/
/ /_/ / /|_/ / /_/ / , _// /  / , _/ /_/ / /|_/ / _  / /__/ _/  / _  / , _// // // / (_ / _/  
\____/_/  /_/\____/_/|_/___/ /_/|_|\____/_/  /_/____/____/___/ /____/_/|_/___/____/\___/___/  
                                                                                              
====================================================================================================

Author: Sierra

A lightweight, zero-drift controller vibration bridge for OMORI.
This repository contains two parts:
1. A C++ executable (RumbleBridge) that handles hardware XInput/ViGEm communication.
2. An OMORI mod (included in the OMORI Mod folder) that sends vibration commands.

====================================================================================================
TABLE OF CONTENTS
====================================================================================================

1. REQUIREMENTS
2. FOR DEVELOPERS: HOW TO COMPILE
3. FOR PLAYERS: HOW TO RUN
4. INPUT FORMAT
5. TROUBLESHOOTING

====================================================================================================
1. REQUIREMENTS
====================================================================================================

To Compile:
- Visual Studio 2019 or newer (with C++ Desktop Development workload)
- Windows 10/11 SDK

To Run:
- Windows 10 / 11
- Xbox controller (or XInput/ViGEm-compatible controller)
- The compiled RumbleBridge.exe, start.bat, and ViGEmClient.dll in the same folder

====================================================================================================
2. FOR DEVELOPERS: HOW TO COMPILE
====================================================================================================

1. Open "RumbleBridge.sln" in Visual Studio.
2. The required dependencies (ViGEmClient.lib, Client.h, Common.h) are already 
   included in the "dependencies" folder. The project file is configured to find them.
3. Set your build mode to "Release" and platform to "x64".
4. Click Build -> Build Solution.
5. Once compiled, navigate to x64/Release/.
6. A Post-Build event is included in the project. It will automatically 
   copy start.bat, README.txt, and ViGEmClient.dll right next to your new .exe. 
   You do not need to copy them manually!

====================================================================================================
3. FOR PLAYERS: HOW TO RUN
====================================================================================================

If you downloaded a pre-compiled Release from the GitHub Releases page:

1. Extract the files.
2. Ensure ViGEmClient.dll, start.bat, and RumbleBridge.exe are in the same folder.
3. Run "start.bat".
4. You should see:

   ==============================================================
                  OMORI RUNTIME CONTROLLER BRIDGE
   ==============================================================
   [HARDWARE] XInput Controller Detected on Index: 0
   [NETWORK] Operational! Waiting for OMORI process handshake...

5. Start OMORI! (Make sure the OMORI Mod included in this repository is installed).

====================================================================================================
4. INPUT FORMAT
====================================================================================================

The bridge receives TCP messages in this format:

    intensity time_ms fade_flag

Example:
    0.8 120 0   (80% power, 120ms, instant stop)
    0.3 60 0    (30% power, 60ms, instant stop)
    1.0 500 1   (100% power, 500ms, smooth fade out)

====================================================================================================
5. TROUBLESHOOTING
====================================================================================================

NO CONTROLLER FOUND
- Plug in your controller before launching the bridge.
- Check Windows (Win + R) "joy.cpl" to confirm it is detected.

GAME DOES NOT CONNECT
- Ensure bridge is running BEFORE launching OMORI.
- Check firewall settings for localhost access.
- Make sure port 9002 is not in use.

COMPILATION ERRORS
- Ensure you are using C++17 standard in Visual Studio project properties.
- Ensure the "dependencies" folder wasn't deleted or moved.

====================================================================================================
CREDITS
====================================================================================================

Author: Sierra
Made with love for the OMORI modding community <3

====================================================================================================
