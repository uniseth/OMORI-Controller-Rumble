//=============================================================================
// ControllerRumbleProfiles.js
//=============================================================================

/*:
 * @plugindesc Defines audio timestamps and rumble intensities for Controller Rumble.
 * @author Sierra
 *
 * @help
 * =======================================================================
 * RUMBLE PROFILES CONFIGURATION
 * =======================================================================
 * 
 * INTENSITY TIERS:
 * Modify the TIER object at the top to globally adjust whole categories.
 * 
 * SE PROFILES:
 * type: "se" - Standard one-shot rumbles.
 * sequence:   - Array of steps to create delayed/multi-stage rumbles.
 * 
 * BGS PROFILES:
 * type: "bgs" - Looping audio sync. Requires loopDuration and beats array.
 * 
 * CONTEXTUAL OVERRIDES:
 * Allows overriding rumbles based on specific Event Names.
 * Example:
 * window.RumbleContextOverrides["My Scary Event"] = {
 *     triggerSe: "SE_horror",
 *     intensity: 1.0,
 *     duration: 500,
 *     fade: 1
 * };
 */

window.RumbleSyncProfiles = window.RumbleSyncProfiles || {};

// =========================================================================
// INTENSITY TIERS
// =========================================================================
const TIER = {
    verySoft: { intensity: 0.20, duration: 60 },
    soft:     { intensity: 0.35, duration: 90 },
    medSoft:  { intensity: 0.50, duration: 100 },
    medium:   { intensity: 0.65, duration: 120 },
    sharpMed: { intensity: 0.75, duration: 90 },
    high:     { intensity: 0.90, duration: 160 }
};

// =========================================================================
// BGS PROFILES (Looping Sync)
// =========================================================================

window.RumbleSyncProfiles["boss_something_heartbeat"] = {
    type: "bgs",
    loopDuration: 9.696, 
    beats: [
        { time: 0.000, intensity: 0.90, duration: 60,  fade: 0 },
        { time: 0.407, intensity: 0.55, duration: 180, fade: 1 },
        { time: 1.245, intensity: 0.90, duration: 60,  fade: 0 },
        { time: 1.629, intensity: 0.55, duration: 180, fade: 1 },
        { time: 2.478, intensity: 0.90, duration: 60,  fade: 0 },
        { time: 2.850, intensity: 0.55, duration: 180, fade: 1 },
        { time: 3.692, intensity: 0.90, duration: 60,  fade: 0 },
        { time: 4.075, intensity: 0.55, duration: 180, fade: 1 },
        { time: 4.913, intensity: 0.90, duration: 60,  fade: 0 },
        { time: 5.294, intensity: 0.55, duration: 180, fade: 1 },
        { time: 6.135, intensity: 0.90, duration: 60,  fade: 0 },
        { time: 6.515, intensity: 0.55, duration: 180, fade: 1 },
        { time: 7.349, intensity: 0.90, duration: 60,  fade: 0 },
        { time: 7.741, intensity: 0.55, duration: 180, fade: 1 },
        { time: 8.570, intensity: 0.90, duration: 60,  fade: 0 },
        { time: 8.964, intensity: 0.55, duration: 180, fade: 1 } 
    ]
};

// =========================================================================
// SE PROFILES (One-Shots & Sequences)
// =========================================================================

// --- COMBATS ---
window.RumbleSyncProfiles["BA_CRITICAL_HIT"] = { type: "se", ...TIER.high, duration: 200 };
window.RumbleSyncProfiles["se_impact_double"]  = { type: "se", ...TIER.high, duration: 200 };
window.RumbleSyncProfiles["BA_stab"]           = { type: "se", ...TIER.soft };

// --- GEN SOUNDS ---
window.RumbleSyncProfiles["GEN_cut"]           = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["GEN_hit"]           = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["gen_just_smash"]    = { type: "se", ...TIER.medium };
window.RumbleSyncProfiles["GEN_munch"]         = { type: "se", ...TIER.verySoft };
window.RumbleSyncProfiles["GEN_Poke"]          = { type: "se", ...TIER.verySoft };
window.RumbleSyncProfiles["GEN_rubble"]        = { type: "se", ...TIER.medium };
window.RumbleSyncProfiles["GEN_stab"]          = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["GEN_stomp"]         = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["GEN_Wham"]          = { type: "se", ...TIER.soft };

window.RumbleSyncProfiles["GEN_smash"] = {
    type: "se",
    sequence: [{ intensity: TIER.medium.intensity, duration: TIER.medium.duration, delay: 150 }]
};

// --- SE SOUNDS ---
window.RumbleSyncProfiles["SE_Aub_Smash_01"]   = { type: "se", ...TIER.high };
window.RumbleSyncProfiles["SE_Aub_Smash_02"]   = { type: "se", ...TIER.high };
window.RumbleSyncProfiles["SE_Aub_Smash_05"]   = { type: "se", ...TIER.high };
window.RumbleSyncProfiles["SE_barrel_smash"]   = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["se_big_gate2"]      = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["SE_bs_scare1"]      = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["SE_bs_scare3"]      = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["SE_bs_scare4"]      = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["se_bump_fall"]      = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["se_chimera_break"]  = { type: "se", ...TIER.medSoft };
window.RumbleSyncProfiles["SE_cut"]            = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["SE_dig"]            = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["se_door_default"]   = { type: "se", ...TIER.soft };

window.RumbleSyncProfiles["SE_Door_Exit"] = {
    type: "se",
    sequence: [{ intensity: TIER.soft.intensity, duration: TIER.soft.duration, delay: 180 }]
};

window.RumbleSyncProfiles["SE_Gate"]           = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["SE_glass_break"]    = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["SE_hit_5"]          = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["SE_load"]           = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["SE_munch"]          = { type: "se", ...TIER.verySoft };
window.RumbleSyncProfiles["SE_pot_smash"]      = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["SE_Push"]           = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["SE_static"]         = { type: "se", ...TIER.medSoft };
window.RumbleSyncProfiles["SE_Thunder"]        = { type: "se", ...TIER.sharpMed };
window.RumbleSyncProfiles["SE_Watermelon"]     = { type: "se", ...TIER.verySoft };
window.RumbleSyncProfiles["SE_WaterSplash_CC0"]= { type: "se", ...TIER.soft };

window.RumbleSyncProfiles["SE_horror"] = {
    type: "se",
    sequence: [
        { intensity: TIER.soft.intensity, duration: 80, delay: 0 },
        { intensity: TIER.medium.intensity, duration: 150, delay: 100 }
    ]
};

window.RumbleSyncProfiles["SE_neo_deep_well_explodes"] = { type: "se", intensity: 0.90, duration: 500, fade: 1 };

// --- SYS SOUNDS ---
window.RumbleSyncProfiles["sys_blackletter1"]        = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["SYS_cut"]                = { type: "se", ...TIER.soft };
window.RumbleSyncProfiles["SYS_super_smash_impact"] = { type: "se", ...TIER.medium };
window.RumbleSyncProfiles["SYS_watermelon"]         = { type: "se", ...TIER.verySoft };

window.RumbleSyncProfiles["SYS_you died_2"] = { type: "se", intensity: 0.90, duration: 500, fade: 1 };

// =========================================================================
// CONTEXTUAL OVERRIDES
// =========================================================================

window.RumbleContextOverrides = window.RumbleContextOverrides || {};