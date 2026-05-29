//=============================================================================
// ControllerRumble.js
//=============================================================================

/*:
 * @plugindesc Zero-Drift Hardware-Anchored Rumble Engine for XInput Controllers.
 * @author Sierra
 *
 * @help
 * =======================================================================
 * CONTROLLER RUMBLE ENGINE (v1.0.0)
 * =======================================================================
 * Requires: ControllerRumbleProfiles.js (Must be placed above this in plugin list)
 * External: Requires the C++ XInput Bridge running on localhost:9002
 *
 * -----------------------------------------------------------------------
 * SCRIPT CALLS (For Event Commands -> Script...) (Should work in theory, I haven't tested it actually.)
 * -----------------------------------------------------------------------
 * Modders can trigger custom rumbles anywhere in RPG Maker events using these:
 *
 *   triggerRumble(intensity, duration, fade)
 *   stopRumble()
 *
 * EXAMPLES:
 *   triggerRumble(0.9, 500, 1)  // Heavy, 500ms rumble that smoothly fades out
 *   triggerRumble(0.2, 60, 0)   // Very soft, 60ms quick thud
 *   stopRumble()                // Immediately kills any active rumble
 *
 * PARAMETERS:
 *   intensity: 0.0 to 1.0 (0.0 = off, 1.0 = max motor power)
 *   duration : Time in milliseconds (1000 = 1 second)
 *   fade     : 0 = Instant stop after duration, 1 = Smooth fade out
 *
 * -----------------------------------------------------------------------
 * DEVELOPER HOTKEYS (For testing only)
 * -----------------------------------------------------------------------
 * [F1] - Flat 1-second test vibration.
 * [F3] - Toggle the boss heartbeat BGS sync.
 */

(() => {

    if (typeof require !== 'function') {
        console.error("[RUMBLE] Node.js context missing. Make sure you are running in NW.js.");
        return;
    }

    const net = require('net');
    const PORT = 9002;
    const HOST = '127.0.0.1';

    let clientSocket = null;
    let isConnected = false;
    let retryTimeout = null;
    let _lastRumbleTime = 0;
    let _f3ToggleActive = false;

    // =========================================================================
    // STATE MANAGEMENT
    // =========================================================================

    let _activeBgsName = null;
    let _activeProfile = null;
    let _syncRunning = false;
    let _audioHardwareStartTime = 0;
    let _currentBeatIndex = 0;
    let _lastLoopPos = 0;
    let _syncRAF = null;
    let _currentPlaybackRate = 1.0; 

    let _comboTimer = null;
    let _pendingCombo = false;

    // =========================================================================
    // SOCKET CONNECTION
    // =========================================================================

    function connectToBridge() {
        if (clientSocket) clientSocket.destroy();

        clientSocket = new net.Socket();
        clientSocket.connect(PORT, HOST, () => {
            isConnected = true;
        });

        clientSocket.on('close', () => {
            isConnected = false;
            scheduleReconnect();
        });

        clientSocket.on('error', () => {
            isConnected = false;
            scheduleReconnect();
        });
    }

    function scheduleReconnect() {
        if (retryTimeout) clearTimeout(retryTimeout);
        retryTimeout = setTimeout(connectToBridge, 3000);
    }

    // =========================================================================
    // RUMBLE COMMUNICATION
    // =========================================================================

    function sendRumble(intensity, time = 120, fade = 0) {
        if (!isConnected || !clientSocket || clientSocket.destroyed) return;

        const safeIntensity = Math.max(0.0, Math.min(1.0, Number(intensity || 0.5))).toFixed(2);
        const safeTime = Math.max(10, Math.min(5000, Math.floor(time)));
        const safeFade = fade ? 1 : 0;

        clientSocket.write(`${safeIntensity} ${safeTime} ${safeFade}`);
    }

    function killRumbleImmediately() {
        if (!isConnected || !clientSocket || clientSocket.destroyed) return;
        clientSocket.write("0.00 10 0");
    }

    // =========================================================================
    // SEQUENCE ENGINE
    // =========================================================================

    function executeSequence(steps) {
        if (!steps || steps.length === 0) return;
        steps.forEach(step => {
            setTimeout(() => sendRumble(step.intensity, step.duration, step.fade || 0), step.delay || 0);
        });
    }

    // =========================================================================
    // ZERO-DRIFT SYNC ENGINE (BGS)
    // =========================================================================

    function syncRAFLoop() {
        if (!_syncRunning || !_activeProfile) {
            _syncRAF = null;
            return;
        }

        const ctx = WebAudio._context;
        if (!ctx || _audioHardwareStartTime === 0) {
            _syncRAF = requestAnimationFrame(syncRAFLoop);
            return;
        }

        try {
            const elapsedHardwareTime = ctx.currentTime - _audioHardwareStartTime;
            const scaledAudioTime = elapsedHardwareTime * _currentPlaybackRate;
            let currentPos = scaledAudioTime % _activeProfile.loopDuration;

            if (currentPos < _lastLoopPos - 0.1) _currentBeatIndex = 0;
            _lastLoopPos = currentPos;

            while (_currentBeatIndex < _activeProfile.beats.length) {
                const beat = _activeProfile.beats[_currentBeatIndex];
                if (currentPos >= beat.time) {
                    sendRumble(beat.intensity, beat.duration, beat.fade);
                    _currentBeatIndex++;
                } else {
                    break;
                }
            }
        } catch (e) {
            console.error("[RUMBLE] Sync error:", e);
        }

        _syncRAF = requestAnimationFrame(syncRAFLoop);
    }

    function killSyncLoop() {
        _syncRunning = false;
        _activeBgsName = null;
        _activeProfile = null;
        _audioHardwareStartTime = 0;
        _currentBeatIndex = 0;
        _lastLoopPos = 0;
        _currentPlaybackRate = 1.0;

        if (_syncRAF) {
            cancelAnimationFrame(_syncRAF);
            _syncRAF = null;
        }
        killRumbleImmediately();
    }

    // =========================================================================
    // AUDIO MANAGER HOOKS (BGS)
    // =========================================================================

    const _AudioManager_playBgs = AudioManager.playBgs;
    AudioManager.playBgs = function(bgs, pos) {
        _AudioManager_playBgs.call(this, bgs, pos);

        if (bgs && bgs.name && window.RumbleSyncProfiles && window.RumbleSyncProfiles[bgs.name]) {
            const profile = window.RumbleSyncProfiles[bgs.name];
            if (profile.type === "bgs") {
                _currentPlaybackRate = (bgs.pitch || 100) / 100;
                _activeBgsName = bgs.name;
                _activeProfile = profile;
                _currentBeatIndex = 0;
                _lastLoopPos = 0;

                if (WebAudio._context) _audioHardwareStartTime = WebAudio._context.currentTime;

                if (!_syncRunning) {
                    _syncRunning = true;
                    if (!_syncRAF) _syncRAF = requestAnimationFrame(syncRAFLoop);
                }
            }
        }
    };

    const _AudioManager_stopBgs = AudioManager.stopBgs;
    AudioManager.stopBgs = function() {
        if (_syncRunning) killSyncLoop();
        _AudioManager_stopBgs.call(this);
    };

    const _AudioManager_fadeOutBgs = AudioManager.fadeOutBgs;
    AudioManager.fadeOutBgs = function(duration) {
        if (_syncRunning) killSyncLoop();
        _AudioManager_fadeOutBgs.call(this, duration);
    };

    // =========================================================================
    // AUDIO MANAGER HOOKS (SE)
    // =========================================================================

    const _AudioManager_playSe = AudioManager.playSe;
    AudioManager.playSe = function(se) {
        _AudioManager_playSe.call(this, se);

        if (!se || !se.name || !window.RumbleSyncProfiles) return;
        const profile = window.RumbleSyncProfiles[se.name];

        // Contextual Override Check
        if (window.RumbleContextOverrides) {
            for (const eventNameKey in window.RumbleContextOverrides) {
                const rule = window.RumbleContextOverrides[eventNameKey];
                if (se.name === rule.triggerSe) {
                    let currentEventName = "";
                    const interp = $gameMap._interpreter;
                    if (interp && interp._eventId > 0) {
                        const ev = $gameMap.event(interp._eventId);
                        if (ev) currentEventName = ev.event().name;
                    }
                    if (currentEventName.includes(eventNameKey)) {
                        sendRumble(rule.intensity, rule.duration, rule.fade || 0);
                        return; 
                    }
                }
            }
        }

        // Combo Logic
        if (se.name === "BA_CRITICAL_HIT" || se.name === "se_impact_double") {
            if (_pendingCombo) {
                clearTimeout(_comboTimer);
                _pendingCombo = false;
                sendRumble(1.00, 500, 1); 
                return;
            } else {
                _pendingCombo = true;
                _comboTimer = setTimeout(() => {
                    _pendingCombo = false;
                    if (profile) sendRumble(profile.intensity, profile.duration, profile.fade || 0);
                }, 200);
                return;
            }
        }

        // Standard SE Processing
        if (profile && profile.type === "se") {
            if (profile.sequence) {
                executeSequence(profile.sequence);
            } else {
                sendRumble(profile.intensity, profile.duration, profile.fade || 0);
            }
        }
    };

    // =========================================================================
    // SCREEN & SCENE HOOKS
    // =========================================================================

    const _Scene_Boot_start = Scene_Boot.prototype.start;
    Scene_Boot.prototype.start = function() {
        _Scene_Boot_start.call(this);
        if (typeof Aries !== 'undefined' && Aries.P001_ASE && typeof Aries.P001_ASE.shake === 'function') {
            const _Aries_shake = Aries.P001_ASE.shake;
            Aries.P001_ASE.shake = function(duration, power, type) {
                _Aries_shake.call(this, duration, power, type);
                sendRumble(Math.min((power || 5) / 9, 1.0), Math.floor((duration || 30) * 16.67), 1);
            };
        }
    };

    const _Game_Screen_startShake = Game_Screen.prototype.startShake;
    Game_Screen.prototype.startShake = function(power, speed, duration) {
        _Game_Screen_startShake.call(this, power, speed, duration);
        sendRumble(Math.min((power || 5) / 9, 1.0), Math.floor((duration || 30) * 16.67), 1);
    };

    const _Game_Screen_startFadeOut = Game_Screen.prototype.startFadeOut;
    Game_Screen.prototype.startFadeOut = function(duration) {
        _Game_Screen_startFadeOut.call(this, duration);
        if (window.RumbleContextOverrides) {
            const interp = $gameMap._interpreter;
            if (interp && interp._eventId > 0) {
                const ev = $gameMap.event(interp._eventId);
                if (ev) {
                    const rule = window.RumbleContextOverrides[ev.event().name];
                    if (rule && rule.triggerOnFadeOut) sendRumble(rule.intensity, rule.duration, rule.fade || 0);
                }
            }
        }
    };

    // =========================================================================
    // COMBAT DAMAGE RUMBLE
    // =========================================================================

    const _Game_Battler_performDamage = Game_Battler.prototype.performDamage;
    Game_Battler.prototype.performDamage = function() {
        _Game_Battler_performDamage.call(this);
        if ($gameParty.inBattle() && !this.result().missed) {
            const now = Date.now();
            if (now - _lastRumbleTime < 150) return;
            _lastRumbleTime = now;
            if (this.isActor()) {
                sendRumble((typeof this.hpRate === 'function' && this.hpRate() < 0.3) ? 0.95 : 0.65, this.hpRate() < 0.3 ? 300 : 80, this.hpRate() < 0.3 ? 1 : 0);
            } else {
                sendRumble(0.40, 50, 0);
            }
        }
    };

    // =========================================================================
    // GLOBAL EXPOSURE & INIT
    // =========================================================================

    // Expose for RPG Maker MV Script Calls
    window.triggerRumble = function(intensity = 0.5, duration = 120, fade = 0) {
        sendRumble(intensity, duration, fade);
    };

    window.stopRumble = function() {
        killRumbleImmediately();
    };

    window.addEventListener('keydown', (event) => {
        if (event.key === "F1") sendRumble(0.70, 1000, 0);
        if (event.key === "F3") {
            if (!_f3ToggleActive) {
                _f3ToggleActive = true;
                AudioManager.playBgs({ name: "boss_something_heartbeat", volume: 90, pitch: 100, pan: 0 });
            } else {
                _f3ToggleActive = false;
                AudioManager.fadeOutBgs(1.0); 
            }
        }
    });

    connectToBridge();

})();