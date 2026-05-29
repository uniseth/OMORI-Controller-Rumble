#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <Xinput.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <iostream>
#include <fstream>
#include <thread>
#include <atomic>
#include <cstdlib>
#include <Client.h>

#pragma comment(lib, "Xinput9_1_0.lib")
#pragma comment(lib, "ws2_32.lib")

// Atomic flag to instantly kill active rumbles when a 0.00 command arrives
std::atomic<bool> abortRumble(false);
DWORD activeController = 0xFFFFFFFF;

// Global log file stream
std::ofstream logFile;

void ExecuteRumble(float intensity, int time, int fade) {
    abortRumble = false;
    XINPUT_VIBRATION vibration{};

    if (fade == 1 && time > 20) {
        int elapsed = 0;
        int tickMs = 10;
        float startIntensity = intensity;

        while (elapsed < time) {
            if (abortRumble) break; 

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

            int ticks = time / 10;
            for (int i = 0; i < ticks; i++) {
                if (abortRumble) break;
                Sleep(10);
            }
        }
    }

    vibration.wLeftMotorSpeed = 0;
    vibration.wRightMotorSpeed = 0;
    XInputSetState(activeController, &vibration);
}

int main() {
    // Open log file directly in the current directory (overwrites old logs)
    logFile.open("bridge_log.txt", std::ios::out | std::ios::trunc);
    if (logFile.is_open()) {
        logFile << "=============================================================\n" << std::flush;
        logFile << "               OMORI RUNTIME CONTROLLER BRIDGE               \n" << std::flush;
        logFile << "=============================================================\n" << std::flush;
    }

    for (DWORD i = 0; i < 4; i++) {
        XINPUT_STATE state{};
        if (XInputGetState(i, &state) == ERROR_SUCCESS) {
            activeController = i;
            if (logFile.is_open()) logFile << "[HARDWARE] XInput Controller Detected on Index: " << i << "\n" << std::flush;
            break;
        }
    }

    if (activeController == 0xFFFFFFFF) {
        if (logFile.is_open()) logFile << "[ERROR] No XInput gamepads detected on system.\n" << std::flush;
        system("pause"); return 1;
    }

    WSADATA wsa;
    if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0) {
        if (logFile.is_open()) logFile << "[ERROR] WSAStartup failed.\n" << std::flush;
        system("pause"); return 1;
    }

    SOCKET server = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    sockaddr_in addr{};
    addr.sin_family = AF_INET;
    addr.sin_port = htons(9002);
    addr.sin_addr.s_addr = INADDR_ANY;

    if (bind(server, (sockaddr*)&addr, sizeof(addr)) == SOCKET_ERROR || listen(server, 1) == SOCKET_ERROR) {
        if (logFile.is_open()) logFile << "[ERROR] Port 9002 bind/listen failed.\n" << std::flush;
        system("pause"); return 1;
    }

    if (logFile.is_open()) logFile << "[NETWORK] Operational! Waiting for OMORI process...\n" << std::flush;
    SOCKET client = accept(server, NULL, NULL);
    if (client == INVALID_SOCKET) {
        if (logFile.is_open()) logFile << "[ERROR] Connection handshake failed.\n" << std::flush;
        system("pause"); return 1;
    }
    if (logFile.is_open()) logFile << "[NETWORK] Connected! Tracking execution sequences...\n\n" << std::flush;

    char buffer[128];
    while (true) {
        int len = recv(client, buffer, sizeof(buffer) - 1, 0);
        if (len <= 0) {
            if (logFile.is_open()) logFile << "\n[NETWORK] Game disconnected.\n" << std::flush;
            break;
        }
        buffer[len] = 0;

        float intensity = 0.5f;
        int time = 120;
        int fade = 0;

        sscanf_s(buffer, "%f %d %d", &intensity, &time, &fade);

        if (intensity < 0.0f) intensity = 0.0f;
        if (intensity > 1.0f) intensity = 1.0f;

        if (logFile.is_open()) {
            logFile << "[SIGNAL] Intensity: " << intensity 
                    << " | Duration: " << time << "ms" 
                    << " | Fade: " << (fade ? "YES" : "NO") << "\n" << std::flush;
        }

        if (intensity == 0.0f) {
            abortRumble = true;
            Sleep(15); 
        }

        std::thread(ExecuteRumble, intensity, time, fade).detach();
    }

    closesocket(client); closesocket(server); WSACleanup();
    if (logFile.is_open()) logFile.close();
    
    return 0;
}