====================================================================================================
                     OMORI CONTROLLER RUMBLE - MOD SETUP
====================================================================================================

Author: Sierra

This folder contains the RPG Maker MV plugins that tell OMORI when to 
trigger the controller vibrations. 

REQUIREMENT: The C++ RumbleBridge.exe MUST be running while you play, 
or the mod will (safely) do nothing.

====================================================================================================
1. INSTALLATION (ONELOADER)
====================================================================================================

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
    { intensity: 0.8, duration: 200, delay: 350 } // Triggers 350ms after sound plays
  ]
};

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
triggerRumble(0.9, 500, 1)  // Heavy, 500ms rumble that smoothly fades out

TO STOP A RUMBLE IMMEDIATELY:
stopRumble()

====================================================================================================
CREDITS
====================================================================================================

Author: Sierra