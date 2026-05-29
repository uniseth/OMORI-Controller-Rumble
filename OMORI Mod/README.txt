====================================================================================================
                     OMORI CONTROLLER RUMBLE - MOD FILES
====================================================================================================

Author: Sierra

This folder contains the RPG Maker MV plugins that tell OMORI when to 
trigger the controller vibrations. 

NOTE: The main "start.bat" launcher automatically installs or updates 
these files into your OMORI directory for you. You generally do not 
need to touch this folder unless you are manually installing!

REQUIREMENT: The C++ RumbleBridge.exe MUST be running while you play, 
or the mod will (safely) do nothing.

====================================================================================================
TABLE OF CONTENTS
====================================================================================================

1. MANUAL INSTALLATION (ADVANCED)
2. CONFIGURING RUMBLE (FOR MODDERS)
3. SCRIPT CALLS (FOR EVENT MAKERS)

====================================================================================================
1. MANUAL INSTALLATION (ADVANCED)
====================================================================================================

If the automatic installer fails, or if you prefer to install things 
yourself, follow these steps:

1. Navigate to your OMORI game folder:
   steamapps/common/OMORI/www/mods/

2. Drag and drop the entire "rumble" folder from this directory 
   into the "mods" folder.

3. Start the game! OneLoader will automatically load the plugins 
   in the correct order.

====================================================================================================
2. CONFIGURING RUMBLE (FOR MODDERS)
====================================================================================================

If you want to add your own custom rumbles to your own mods, open:
   js/plugins/ControllerRumbleProfiles.js

INTENSITY TIERS:
You can use pre-built tiers to keep things consistent:
- verySoft: 0.20 intensity, 60ms
- soft: 0.35 intensity, 90ms
- medium: 0.65 intensity, 120ms
- high: 0.90 intensity, 160ms

Example:
window.RumbleSyncProfiles["My_Custom_Sound"] = { type: "se", ...TIER.high };

SEQUENCES (DELAYED RUMBLES):
If you want a pause before a rumble, use a sequence:

window.RumbleSyncProfiles["My_Delayed_Sound"] = {
  type: "se",
  sequence: [
    { intensity: 0.8, duration: 200, delay: 350 }
  ]
};
// Triggers 350ms after the sound plays

BGS SYNC:
If you want to perfectly sync a looping BGS, you must 
use Audacity to find the exact timestamps of the beats, and list them 
in a "bgs" type profile. The engine will automatically lock onto the 
audio hardware clock so it never desyncs.

====================================================================================================
3. SCRIPT CALLS (FOR EVENT MAKERS)
====================================================================================================

You can trigger custom rumbles directly inside RPG Maker event commands 
using the "Script..." command.

TO TRIGGER A RUMBLE:
triggerRumble(intensity, duration, fade)

Example:
triggerRumble(0.9, 500, 1)  
// Heavy, 500ms rumble that smoothly fades out

TO STOP A RUMBLE IMMEDIATELY:
stopRumble()

====================================================================================================
CREDITS
====================================================================================================

Author: Sierra
Made with love for the OMORI modding community <3

====================================================================================================