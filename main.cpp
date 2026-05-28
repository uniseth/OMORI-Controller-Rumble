#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <Xinput.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <iostream>
#include <thread>
#include <atomic>
#include <cstdlib>
#include <Client.h>

#pragma comment(lib, "Xinput9_1_0.lib")
#pragma comment(lib, "ws2_32.lib")

#define RESET   "\033[0m"
#define GREEN   "\033[32m"
#define YELLOW  "\033[33m"
#define RED     "\033[31m"
#define CYAN    "\033[36m"
#define WHITE   "\033[37m"
#define GRAY    "\033[90m"

// Atomic flag to instantly kill active rumbles when a 0.00 command arrives
std::atomic<bool> abortRumble(false);
DWORD activeController = 0xFFFFFFFF;

void EnableVirtualTerminalProcessing() {
    HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
    if (hOut == INVALID_HANDLE_VALUE) return;
    DWORD dwMode = 0;
    if (!GetConsoleMode(hOut, &dwMode)) return;
    dwMode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;
    SetConsoleMode(hOut, dwMode);
}

// Runs in a background thread so the main socket never blocks
void ExecuteRumble(float intensity, int time, int fade) {
    abortRumble = false;
    XINPUT_VIBRATION vibration{};

    if (fade == 1 && time > 20) {
        int elapsed = 0;
        int tickMs = 10;
        float startIntensity = intensity;

        while (elapsed < time) {
            if (abortRumble) break; // Instant abort check

            float progress = (float)elapsed / (float)time;
            float currentIntensity = startIntensity * (1.0f - progress);
            WORD motor = (WORD)(currentIntensity * 65535.0f);

            vibration.wLeftMotorSpeed = motor;
            vibration.wRightMotorSpeed = motor;
            XInputSetState(activeController, &vibration);

            Sleep(tickMs);
            elapsed += tickMs;
        }
    }
    else {
        if (time > 0) {
            WORD motor = (WORD)(intensity * 65535.0f);
            vibration.wLeftMotorSpeed = motor;
            vibration.wRightMotorSpeed = motor;
            XInputSetState(activeController, &vibration);

            // Non-blocking sleep loop to allow instant abort
            int ticks = time / 10;
            for (int i = 0; i < ticks; i++) {
                if (abortRumble) break;
                Sleep(10);
            }
        }
    }

    // Clean cut motor shut down
    vibration.wLeftMotorSpeed = 0;
    vibration.wRightMotorSpeed = 0;
    XInputSetState(activeController, &vibration);
}

int main() {
    EnableVirtualTerminalProcessing();

    std::cout << CYAN << "=============================================================\n";
    std::cout << "               OMORI RUNTIME CONTROLLER BRIDGE               \n";
    std::cout << "=============================================================\n" << RESET;

    for (DWORD i = 0; i < 4; i++) {
        XINPUT_STATE state{};
        if (XInputGetState(i, &state) == ERROR_SUCCESS) {
            activeController = i;
            std::cout << GREEN << "[HARDWARE] XInput Controller Detected on Index: " << i << RESET << "\n";
            break;
        }
    }

    if (activeController == 0xFFFFFFFF) {
        std::cout << RED << "[ERROR] No XInput gamepads detected on system." << RESET << "\n";
        system("pause"); return 1;
    }

    WSADATA wsa;
    if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0) {
        std::cout << RED << "[ERROR] WSAStartup failed." << RESET << "\n";
        system("pause"); return 1;
    }

    SOCKET server = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    sockaddr_in addr{};
    addr.sin_family = AF_INET;
    addr.sin_port = htons(9002);
    addr.sin_addr.s_addr = INADDR_ANY;

    if (bind(server, (sockaddr*)&addr, sizeof(addr)) == SOCKET_ERROR || listen(server, 1) == SOCKET_ERROR) {
        std::cout << RED << "[ERROR] Port 9002 bind/listen failed." << RESET << "\n";
        system("pause"); return 1;
    }

    std::cout << YELLOW << "[NETWORK] Operational! Waiting for OMORI process..." << RESET << "\n";
    SOCKET client = accept(server, NULL, NULL);
    if (client == INVALID_SOCKET) {
        std::cout << RED << "[ERROR] Connection handshake failed." << RESET << "\n";
        system("pause"); return 1;
    }
    std::cout << GREEN << "[NETWORK] Connected! Tracking execution sequences...\n\n" << RESET;

    char buffer[128];
    while (true) {
        int len = recv(client, buffer, sizeof(buffer) - 1, 0);
        if (len <= 0) {
            std::cout << RED << "\n[NETWORK] Game disconnected." << RESET << "\n";
            break;
        }
        buffer[len] = 0;

        float intensity = 0.5f;
        int time = 120;
        int fade = 0;

        sscanf_s(buffer, "%f %d %d", &intensity, &time, &fade);

        if (intensity < 0.0f) intensity = 0.0f;
        if (intensity > 1.0f) intensity = 1.0f;

        const char* intensityColor = (intensity < 0.35f) ? GREEN : ((intensity <= 0.70f) ? YELLOW : RED);
        std::cout << GRAY << "[SIGNAL] " << RESET
            << "Intensity: " << intensityColor << intensity << RESET
            << " | Duration: " << WHITE << time << "ms" << RESET
            << " | Fade: " << (fade ? YELLOW : GRAY) << (fade ? "YES" : "NO") << RESET << "\n";

        // If a kill command arrives, instantly abort whatever is currently running
        if (intensity == 0.0f) {
            abortRumble = true;
            Sleep(15); // Give thread a tiny moment to see the flag and kill motors
        }

        // Spawn a detached thread to handle the hardware sleep.
        // This ensures the main 'recv' loop never blocks!
        std::thread(ExecuteRumble, intensity, time, fade).detach();
    }

    closesocket(client); closesocket(server); WSACleanup();
    return 0;
}