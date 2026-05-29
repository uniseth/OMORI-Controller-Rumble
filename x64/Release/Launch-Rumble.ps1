param(
    [string]$GameExePath
)

# OMORI Rumble Auto-Updater & Launcher
#
# ========================================================
# CONFIGURATION (Optional)
# ========================================================
# To customize the launcher, create a file named "config.txt" 
# in the same folder as this script. See the config.txt file
# for a full list of options, custom themes, and presets!
# ========================================================

# Force TLS 1.2 for GitHub connections
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

# Define current directory FIRST so the quote reader can use it
 $currentDir = Split-Path -Path $PSCommandPath -Parent

# ========================================================
#      C O N F I G   R E A D E R
# ========================================================
 $configFile = Join-Path $currentDir 'config.txt'
 $isDebug = $false
 $isAuto = $false
 $selectedTheme = "random"
 $aprilFools = $false
 $customThemeStr = $null
 $overrideOmoriPath = $null
 $launchMethod = "steam"

if (Test-Path $configFile) {
    $configContent = Get-Content $configFile -ErrorAction SilentlyContinue
    foreach ($line in $configContent) {
        $line = $line.Trim()
        if ($line -match '^Debug\s*=\s*(.+)$') {
            $val = $matches[1].Trim()
            if ($val -match '^(true|1|yes)$') { $isDebug = $true }
        }
        elseif ($line -match '^Auto\s*=\s*(.+)$') {
            $val = $matches[1].Trim()
            if ($val -match '^(true|1|yes)$') { $isAuto = $true }
        }
        elseif ($line -match '^Theme\s*=\s*(.+)$') {
            $selectedTheme = $matches[1].Trim().ToLower()
        }
        elseif ($line -match '^CustomTheme\s*=\s*(.+)$') {
            $customThemeStr = $matches[1].Trim()
        }
        elseif ($line -match '^AprilFools\s*=\s*(.+)$') {
            $val = $matches[1].Trim()
            if ($val -match '^(true|1|yes)$') { $aprilFools = $true }
        }
        elseif ($line -match '^OmoriPath\s*=\s*(.+)$') {
            $val = $matches[1].Trim().Trim('"')
            if ($val -ne '') { $overrideOmoriPath = $val }
        }
        elseif ($line -match '^LaunchMethod\s*=\s*(.+)$') {
            $val = $matches[1].Trim().ToLower()
            if ($val -match '^(direct|steam)$') {
                $launchMethod = $val
            } else {
                $launchMethod = "steam"
            }
        }
    }
}

function Write-DebugMsg {
    param([string]$Message)
    if ($isDebug) {
        Write-Host "  [DBG] $Message" -ForegroundColor DarkMagenta
    }
}

Write-DebugMsg "Config loaded -> Debug: $isDebug | Auto: $isAuto | Theme: $selectedTheme | AprilFools: $aprilFools"
Write-DebugMsg "Config loaded -> OmoriPath Override: $($overrideOmoriPath -or 'None') | Launch Method: $launchMethod"
Write-DebugMsg "Current Script Directory: $currentDir"
Write-DebugMsg "PowerShell Version: $($PSVersionTable.PSVersion)"

# ========================================================
#                  A S C I I   A R T
# ========================================================
 $normalArt = @(
    '__________________________________________________/\\\_________/\\\\\\___________________        ',
    ' _________________________________________________\/\\\________\////\\\___________________       ',
    '  _________________________________________________\/\\\___________\/\\\___________________      ',
    '   __/\\/\\\\\\\___/\\\____/\\\____/\\\\\__/\\\\\___\/\\\___________\/\\\________/\\\\\\\\__     ',
    '    _\/\\\/////\\\_\/\\\___\/\\\__/\\\///\\\\\///\\\_\/\\\\\\\\\_____\/\\\______/\\\/////\\\_    ',
    '     _\/\\\___\///__\/\\\___\/\\\_\/\\\_\//\\\__\/\\\_\/\\\////\\\____\/\\\_____/\\\\\\\\\\\__   ',
    '      _\/\\\_________\/\\\___\/\\\_\/\\\__\/\\\__\/\\\_\/\\\__\/\\\____\/\\\____\//\\///////___  ',
    '       _\/\\\_________\//\\\\\\\\\__\/\\\__\/\\\__\/\\\_\/\\\\\\\\\___/\\\\\\\\\__\//\\\\\\\\\\_ ',
    '        _\///___________\/////////___\///___\///___\///__\/////////___\/////////____\//////////__'
)

# Reversed
 $aprilFoolsArt = @(
    '_________________/\\\\\\_____/\\\________________________________________________________        ',
    ' ________________\////\\\____\/\\\________________________________________________________       ',
    '  ___________________\/\\\____\/\\\________________________________________________________      ',
    '   _____/\\\\\\\\_____\/\\\____\/\\\___________/\\\\\__/\\\\\____/\\\____/\\\__/\\/\\\\\\\__     ',
    '    ___/\\\/////\\\____\/\\\____\/\\\\\\\\\___/\\\///\\\\\///\\\_\/\\\___\/\\\_\/\\\/////\\\_    ',
    '     __/\\\\\\\\\\\_____\/\\\____\/\\\////\\\_\/\\\_\//\\\__\/\\\_\/\\\___\/\\\_\/\\\___\///__   ',
    '      _\//\\///////______\/\\\____\/\\\__\/\\\_\/\\\__\/\\\__\/\\\_\/\\\___\/\\\_\/\\\_________  ',
    '       __\//\\\\\\\\\\__/\\\\\\\\\_\/\\\\\\\\\__\/\\\__\/\\\__\/\\\_\//\\\\\\\\\__\/\\\_________ ',
    '        ___\//////////__\/////////__\/////////___\///___\///___\///___\/////////___\///__________ '
)

# Map specific theme names to exact color schemes (Includes holidays so forced config still works)
 $themeMap = @{
    'og'          = "DarkCyan,DarkCyan,Cyan,Cyan,White,Magenta,White,Cyan,DarkCyan"
    'trans'       = "Cyan,Cyan,Magenta,Magenta,White,Magenta,Magenta,Cyan,Cyan"
    'nonbinary'   = "Yellow,Yellow,White,White,Magenta,Magenta,Magenta,DarkGray,DarkGray"
    'pan'         = "Magenta,Magenta,Magenta,Yellow,Yellow,Yellow,Cyan,Cyan,Cyan"
    'bi'          = "Magenta,Magenta,Magenta,DarkMagenta,Blue,Blue,Blue,DarkBlue,DarkBlue"
    'lesbian'     = "DarkRed,DarkRed,Red,Red,White,Magenta,Magenta,DarkMagenta,DarkMagenta"
    'gay'         = "Green,Green,Green,Green,Blue,Blue,Magenta,Magenta,DarkMagenta"
    'ace'         = "DarkGray,DarkGray,Gray,Gray,White,White,Magenta,Magenta,Magenta"
    'aro'         = "DarkGreen,DarkGreen,Green,Green,White,Gray,Gray,DarkGray,DarkGray"
    'genderfluid' = "Magenta,Magenta,White,White,Magenta,Magenta,DarkGray,DarkGray,Blue"
    'progress'    = "DarkRed,Red,DarkYellow,Yellow,Green,Blue,DarkMagenta,White,Magenta"
    'white'       = "White,White,White,White,White,White,White,White,White"
    'cyan'        = "Cyan,Cyan,Cyan,Cyan,Cyan,Cyan,Cyan,Cyan,Cyan"
    'magenta'     = "Magenta,Magenta,Magenta,Magenta,Magenta,Magenta,Magenta,Magenta,Magenta"
    'red'         = "Red,Red,Red,Red,Red,Red,Red,Red,Red"
    'green'       = "Green,Green,Green,Green,Green,Green,Green,Green,Green"
    'yellow'      = "Yellow,Yellow,Yellow,Yellow,Yellow,Yellow,Yellow,Yellow,Yellow"
    'gray'        = "Gray,Gray,Gray,Gray,Gray,Gray,Gray,Gray,Gray"
    'matrix'      = "DarkGreen,DarkGreen,Green,Green,Green,Green,Green,DarkGreen,DarkGreen"
    'amber'       = "DarkYellow,DarkYellow,Yellow,Yellow,Yellow,Yellow,Yellow,DarkYellow,DarkYellow"
    'dos'         = "DarkBlue,DarkBlue,Blue,Blue,White,Blue,Blue,DarkBlue,DarkBlue"
    'retro'       = "Cyan,Magenta,Yellow,Blue,White,Blue,Yellow,Magenta,Cyan"
    'bloodmoon'   = "Red,Red,Yellow,Yellow,White,Gray,Gray,DarkGray,DarkGray"
    'gradientblue'= "DarkBlue,DarkBlue,Blue,Blue,Cyan,Cyan,White,White,White"
    'gradientred' = "DarkGray,DarkRed,Red,Red,Magenta,Magenta,White,White,White"
    'gradientpink'= "DarkMagenta,DarkMagenta,Magenta,Magenta,Magenta,White,White,Gray,Gray"
    'gradientcyan'= "White,White,Cyan,Cyan,Blue,Blue,DarkBlue,DarkBlue,DarkBlue"
    'gradientyellow' = "White,White,Yellow,Yellow,Red,Red,DarkRed,DarkRed,DarkRed"
    'heart'       = "DarkRed,DarkRed,Red,White,White,White,Red,DarkRed,DarkRed"
    'monochrome'  = "DarkGray,DarkGray,DarkGray,Gray,White,Gray,DarkGray,DarkGray,DarkGray"
    # HOLIDAYS (Excluded from random pool, but accessible via config or date)
    'xmas'        = "Red,Green,Red,Green,White,Green,Red,Green,Red"
    'halloween'   = "DarkYellow,DarkYellow,Red,Red,White,Red,Red,DarkYellow,DarkYellow"
    'valentine'   = "Magenta,Magenta,Red,Red,White,Red,Red,Magenta,Magenta"
    'easter'      = "Cyan,Yellow,Magenta,Green,White,Green,Magenta,Yellow,Cyan"
    'stpatricks'  = "Green,Green,Green,White,Yellow,White,Green,Green,Green"
    'july4'       = "Red,Red,White,White,Blue,Blue,White,White,Red"
}

# Valid colors for validation
 $validColors = @("Black","DarkBlue","DarkGreen","DarkCyan","DarkRed","DarkMagenta","DarkYellow","Gray","DarkGray","Blue","Green","Cyan","Red","Magenta","Yellow","White")

 $chosenScheme = $null

# ========================================================
# H O L I D A Y   A U T O - D E T E C T
# ========================================================
if ($selectedTheme -eq "random") {
    $today = Get-Date
    $m = $today.Month
    $d = $today.Day
    $autoHoliday = $null

    if ($m -eq 2 -and $d -eq 14) { $autoHoliday = "valentine" }
    elseif ($m -eq 3 -and $d -eq 17) { $autoHoliday = "stpatricks" }
    elseif ($m -eq 7 -and $d -eq 4) { $autoHoliday = "july4" }
    elseif ($m -eq 10 -and $d -eq 31) { $autoHoliday = "halloween" }
    elseif ($m -eq 12 -and $d -eq 25) { $autoHoliday = "xmas" }

    if ($autoHoliday) {
        $selectedTheme = $autoHoliday
        Write-DebugMsg "HOLIDAY AUTO-DETECT: Happy $autoHoliday! Forcing holiday theme."
    }
}

# ========================================================
# T H E M E   R E S O L U T I O N
# ========================================================
if ($selectedTheme -match ',') {
    Write-DebugMsg "Inline custom theme detected in config."
    $chosenScheme = $selectedTheme -split ','
}
elseif ($selectedTheme -eq 'custom') {
    if ($customThemeStr) {
        Write-DebugMsg "Referenced 'custom' theme. Reading CustomTheme string."
        $chosenScheme = $customThemeStr -split ','
    } else {
        Write-DebugMsg "Theme set to 'custom', but CustomTheme is not defined in config.txt. Defaulting to random."
    }
}
elseif ($themeMap.ContainsKey($selectedTheme)) {
    $chosenScheme = $themeMap[$selectedTheme] -split ','
    Write-DebugMsg "Forcing built-in theme: $selectedTheme"
}
elseif ($selectedTheme -ne "random" -and $isDebug) {
    Write-DebugMsg "Invalid theme '$selectedTheme' in config.txt. Defaulting to random."
}

if ($null -ne $chosenScheme) {
    $isValid = $true
    $chosenScheme = $chosenScheme | ForEach-Object { $_.Trim() }
    
    if ($chosenScheme.Count -ne 9) {
        Write-DebugMsg "Custom theme must have exactly 9 colors. Found $($chosenScheme.Count). Falling back to random."
        $isValid = $false
    } else {
        foreach ($c in $chosenScheme) {
            if ($validColors -notcontains $c) {
                Write-DebugMsg "Invalid color '$c' in custom theme. Falling back to random."
                $isValid = $false
                break
            }
        }
    }
    if (-not $isValid) { $chosenScheme = $null }
    else { Write-DebugMsg "Custom theme validated successfully." }
}

if ($null -eq $chosenScheme) {
    $randomSchemes = @(
        "DarkCyan,DarkCyan,Cyan,Cyan,White,Magenta,White,Cyan,DarkCyan",
        "Cyan,Cyan,Magenta,Magenta,White,Magenta,Magenta,Cyan,Cyan",
        "Yellow,Yellow,White,White,Magenta,Magenta,Magenta,DarkGray,DarkGray",
        "Magenta,Magenta,Magenta,Yellow,Yellow,Yellow,Cyan,Cyan,Cyan",
        "Magenta,Magenta,Magenta,DarkMagenta,Blue,Blue,Blue,DarkBlue,DarkBlue",
        "DarkRed,DarkRed,Red,Red,White,Magenta,Magenta,DarkMagenta,DarkMagenta",
        "Green,Green,Green,Green,Blue,Blue,Magenta,Magenta,DarkMagenta",
        "DarkGray,DarkGray,Gray,Gray,White,White,Magenta,Magenta,Magenta",
        "DarkGreen,DarkGreen,Green,Green,White,Gray,Gray,DarkGray,DarkGray",
        "Magenta,Magenta,White,White,Magenta,Magenta,DarkGray,DarkGray,Blue",
        "DarkRed,Red,DarkYellow,Yellow,Green,Blue,DarkMagenta,White,Magenta",
        "Magenta,Magenta,White,White,White,Green,Green,DarkGreen,DarkGreen",
        "White,White,White,White,White,White,White,White,White",
        "Cyan,Cyan,Cyan,Cyan,Cyan,Cyan,Cyan,Cyan,Cyan",
        "Magenta,Magenta,Magenta,Magenta,Magenta,Magenta,Magenta,Magenta,Magenta",
        "Red,Red,Red,Red,Red,Red,Red,Red,Red",
        "Green,Green,Green,Green,Green,Green,Green,Green,Green",
        "Yellow,Yellow,Yellow,Yellow,Yellow,Yellow,Yellow,Yellow,Yellow",
        "Gray,Gray,Gray,Gray,Gray,Gray,Gray,Gray,Gray",
        "DarkGreen,DarkGreen,Green,Green,Green,Green,Green,DarkGreen,DarkGreen",
        "DarkYellow,DarkYellow,Yellow,Yellow,Yellow,Yellow,Yellow,DarkYellow,DarkYellow",
        "DarkBlue,DarkBlue,Blue,Blue,White,Blue,Blue,DarkBlue,DarkBlue",
        "Cyan,Magenta,Yellow,Blue,White,Blue,Yellow,Magenta,Cyan",
        "Red,Red,Yellow,Yellow,White,Gray,Gray,DarkGray,DarkGray",
        "DarkGray,DarkGray,Gray,White,Yellow,Yellow,Gray,DarkGray,DarkGray",
        "DarkBlue,DarkBlue,Blue,Blue,Cyan,Cyan,White,White,White",
        "DarkGray,DarkRed,Red,Red,Magenta,Magenta,White,White,White",
        "DarkMagenta,DarkMagenta,Magenta,Magenta,Magenta,White,White,Gray,Gray",
        "White,White,Cyan,Cyan,Blue,Blue,DarkBlue,DarkBlue,DarkBlue",
        "White,White,Yellow,Yellow,Red,Red,DarkRed,DarkRed,DarkRed",
        "DarkRed,DarkRed,Red,White,White,White,Red,DarkRed,DarkRed",
        "DarkGray,DarkGray,DarkGray,Gray,White,Gray,DarkGray,DarkGray,DarkGray"
    )
    
    $chosenSchemeString = $randomSchemes | Get-Random
    $chosenScheme = $chosenSchemeString -split ','
    
    $themeName = "Custom Random"
    foreach ($key in $themeMap.Keys) {
        if ($themeMap[$key] -eq $chosenSchemeString) {
            $themeName = $key
            break
        }
    }
    Write-DebugMsg "Randomly selected theme: $themeName"
}

# Handle April Fools shape manipulation
if ($aprilFools) {
    Write-DebugMsg "APRIL FOOLS ENABLED! Using reversed art."
    $displayArt = $aprilFoolsArt
} else {
    $displayArt = $normalArt
}

Write-Host ''
for ($i = 0; $i -lt $displayArt.Count; $i++) {
    Write-Host $displayArt[$i] -ForegroundColor $chosenScheme[$i]
}

Write-Host ''
Write-Host '                    >> O M O R I   C O N T R O L L E R <<' -ForegroundColor DarkGray
Write-Host '============================================================' -ForegroundColor DarkGray

# ========================================================
#               R A N D O M   Q U O T E
# ========================================================
 $quotesFile = Join-Path $currentDir 'quotes.txt'
 $quoteToDisplay = "Waiting for something to happen?"

if (Test-Path $quotesFile) {
    $quotes = Get-Content $quotesFile -ErrorAction SilentlyContinue | Where-Object { $_.Trim() -ne '' }
    if ($quotes.Count -gt 0) {
        $quoteToDisplay = $quotes | Get-Random
    }
}

Write-Host "   $quoteToDisplay" -ForegroundColor DarkYellow
Write-Host '============================================================' -ForegroundColor DarkGray
Write-Host ''

 $ErrorActionPreference = 'SilentlyContinue'

 $repoOwner = 'uniseth'
 $repoName = 'OMORI-Controller-Rumble'
 $steamAppId = '1150690'
 $tempDir = $env:TEMP
 $extractDir = Join-Path $tempDir 'RumbleBridge_Extract'
 $bridgeExe = Join-Path $currentDir 'RumbleBridge.exe'
 $bridgeDll = Join-Path $currentDir 'ViGEmClient.dll'
 $localModDir = Join-Path $currentDir 'rumble'
 $logFile = Join-Path $currentDir 'bridge_log.txt'

 $bridgeReady = $false
 $modReady = $false

if (Test-Path $logFile) { Remove-Item $logFile -Force }

# =========================================================================
# STEP 1
# =========================================================================
Write-DebugMsg "Beginning Step 1: Locating OMORI installation..."
Write-Host "[1/4] " -ForegroundColor Cyan -NoNewline
Write-Host "Locating OMORI installation..." -ForegroundColor White

 $omoriPath = $null
 $steamPath = $null

if ($overrideOmoriPath) {
    Write-DebugMsg "Override OmoriPath detected: $overrideOmoriPath"
    $testPath = Join-Path $overrideOmoriPath 'OMORI.exe'
    if (Test-Path $testPath) {
        $omoriPath = (Resolve-Path $overrideOmoriPath).Path
        Write-DebugMsg "SUCCESS: Found OMORI at override path: $omoriPath"
    } else {
        Write-DebugMsg "ERROR: OMORI.exe not found at override path: $testPath"
        Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host "Could not locate OMORI at specified path: $overrideOmoriPath" -ForegroundColor Red
        if ($isDebug) { Read-Host "Press Enter to exit..." }
        exit 1
    }
}
else {
    $steamRegPaths = @(
        'HKLM:\SOFTWARE\Valve\Steam',
        'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam',
        'HKCU:\SOFTWARE\Valve\Steam',
        'HKCU:\SOFTWARE\WOW6432Node\Valve\Steam'
    )

    foreach ($regPath in $steamRegPaths) {
        $p = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue).InstallPath
        if ($p) { 
            $steamPath = $p
            Write-DebugMsg "Found Steam Install Path: $steamPath"
            break 
        }
    }

    if (-not $steamPath) {
        Write-DebugMsg "ERROR: Steam registry keys not found."
        Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host "Steam is not installed." -ForegroundColor Red
        if ($isDebug) { Read-Host "Press Enter to exit..." }
        Start-Sleep -Seconds 5
        exit 1
    }

    $vdfPath = Join-Path $steamPath 'steamapps\libraryfolders.vdf'
    $libraryPaths = @()
    Write-DebugMsg "Reading libraryfolders.vdf at: $vdfPath"

    if (Test-Path $vdfPath) {
        $vdfContent = Get-Content $vdfPath
        foreach ($line in $vdfContent) {
            if ($line -match '^\s*"[^"]+"\s+"([A-Za-z]:\\[^"]+)"') {
                $extractedPath = $matches[1]
                if ($extractedPath -notmatch 'steamapps\\common$') {
                    $libraryPaths += Join-Path $extractedPath 'steamapps\common'
                } else {
                    $libraryPaths += $extractedPath
                }
                Write-DebugMsg "Added Library Path: $($libraryPaths[-1])"
            }
        }
    }

    $defaultPath = Join-Path $steamPath 'steamapps\common'
    if ($libraryPaths -notcontains $defaultPath) { 
        $libraryPaths += $defaultPath 
        Write-DebugMsg "Added Default Library Path: $defaultPath"
    }

    foreach ($libPath in $libraryPaths) {
        $testPath = Join-Path $libPath 'OMORI'
        Write-DebugMsg "Checking for OMORI.exe in: $testPath"
        if (Test-Path (Join-Path $testPath 'OMORI.exe')) {
            $omoriPath = $testPath
            Write-DebugMsg "SUCCESS: Found OMORI at $omoriPath"
            break
        }
    }

    if (-not $omoriPath) {
        Write-DebugMsg "ERROR: OMORI.exe not found in any library path."
        Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host "Could not locate OMORI." -ForegroundColor Red
        if ($isDebug) { Read-Host "Press Enter to exit..." }
        Start-Sleep -Seconds 5
        exit 1
    }
}

Write-Host "[OK] " -ForegroundColor Green -NoNewline
Write-Host "Found OMORI at: " -ForegroundColor White -NoNewline
Write-Host $omoriPath -ForegroundColor Gray
Write-Host ''

# =========================================================================
# STEP 2: Download & Extract
# =========================================================================
Write-DebugMsg "Beginning Step 2: Checking for updates..."
Write-Host "[2/4] " -ForegroundColor Cyan -NoNewline
Write-Host "Checking for latest Rumble Bridge update..." -ForegroundColor White
 $ErrorActionPreference = 'Continue'

try {
    $apiUrl = "https://api.github.com/repos/$repoOwner/$repoName/releases/latest"
    Write-DebugMsg "Calling GitHub API: $apiUrl"
    $release = Invoke-RestMethod -Uri $apiUrl -Headers @{'User-Agent'='RumbleBridgeUpdate'}
    Write-DebugMsg "API Success. Latest Release Tag: $($release.tag_name)"
    
    $zipAssets = $release.assets | Where-Object { $_.name -like '*.zip' -and $_.name -notlike '*Source*' }
    Write-DebugMsg "Found $($zipAssets.Count) valid .zip assets in release."
    
    if ($zipAssets) {
        Write-Host "[OK] " -ForegroundColor Green -NoNewline
        Write-Host "Found $($zipAssets.Count) release file(s) to download..." -ForegroundColor White
        
        if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
        New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
        
        foreach ($zip in $zipAssets) {
            $zipPath = Join-Path $tempDir $zip.name
            Write-DebugMsg "Downloading: $($zip.name)"
            Write-Host "[INFO] " -ForegroundColor Blue -NoNewline
            Write-Host "Downloading: $($zip.name)" -ForegroundColor Gray
            Invoke-WebRequest -Uri $zip.browser_download_url -OutFile $zipPath
            Write-DebugMsg "Extracting to: $extractDir"
            Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force
        }
        
        Write-Host "[OK] " -ForegroundColor Green -NoNewline
        Write-Host "All files extracted successfully." -ForegroundColor White
        
        $foundExe = Get-ChildItem -Path $extractDir -Filter "RumbleBridge*.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        $foundDll = Get-ChildItem -Path $extractDir -Filter "ViGEmClient.dll" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        
        $localExeExists = Test-Path $bridgeExe
        $localDllExists = Test-Path $bridgeDll
        Write-DebugMsg "Local EXE Exists: $localExeExists | Local DLL Exists: $localDllExists"

        if (($foundExe -or $foundDll) -and ($localExeExists -or $localDllExists)) {
            $doUpdateExe = $false
            if ($isAuto) {
                Write-DebugMsg "AUTO MODE: Skipping prompt. Auto-updating executable files."
                $doUpdateExe = $true
            } else {
                Write-Host ''
                $reply = Read-Host "Update available. Overwrite local executable files? [Y/N]"
                Write-Host ''
                if ($reply -match '^[Yy]') { $doUpdateExe = $true }
            }

            if ($doUpdateExe) {
                if ($foundExe) { 
                    Write-DebugMsg "Overwriting $bridgeExe"
                    Copy-Item $foundExe.FullName -Destination $bridgeExe -Force
                    Write-Host "[OK] " -ForegroundColor Green -NoNewline; Write-Host "Overwrote RumbleBridge.exe." -ForegroundColor White
                }
                if ($foundDll) { 
                    Write-DebugMsg "Overwriting $bridgeDll"
                    Copy-Item $foundDll.FullName -Destination $bridgeDll -Force
                    Write-Host "[OK] " -ForegroundColor Green -NoNewline; Write-Host "Overwrote ViGEmClient.dll." -ForegroundColor White
                }
            } else {
                Write-Host "[INFO] " -ForegroundColor Blue -NoNewline; Write-Host "Keeping your local executable files." -ForegroundColor DarkYellow
            }
        } 
        elseif ($foundExe -or $foundDll) {
            Write-DebugMsg "Missing local files detected. Copying from extracted archive."
            if ($foundExe) { Copy-Item $foundExe.FullName -Destination $bridgeExe -Force }
            if ($foundDll) { Copy-Item $foundDll.FullName -Destination $bridgeDll -Force }
            Write-Host "[OK] " -ForegroundColor Green -NoNewline; Write-Host "Downloaded missing executable files." -ForegroundColor White
        }

        $foundModJson = Get-ChildItem -Path $extractDir -Filter "mod.json" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        $localModExists = (Test-Path $localModDir) -and (Test-Path (Join-Path $localModDir 'mod.json'))
        Write-DebugMsg "Extracted Mod JSON found: $($foundModJson.FullName)"
        Write-DebugMsg "Local Mod Exists: $localModExists"

        if ($foundModJson -and $localModExists) {
            $doUpdateMod = $false
            if ($isAuto) {
                Write-DebugMsg "AUTO MODE: Skipping prompt. Auto-updating mod cache."
                $doUpdateMod = $true
            } else {
                $modReply = Read-Host "Update available. Overwrite local mod cache? [Y/N]"
                Write-Host ''
                if ($modReply -match '^[Yy]') { $doUpdateMod = $true }
            }

            if ($doUpdateMod) {
                Write-DebugMsg "Overwriting local mod cache at $localModDir"
                if (Test-Path $localModDir) { Remove-Item $localModDir -Recurse -Force }
                Copy-Item -Path $foundModJson.Directory.FullName -Destination $localModDir -Recurse -Force
                Write-Host "[OK] " -ForegroundColor Green -NoNewline; Write-Host "Overwrote local mod cache." -ForegroundColor White
            } else {
                Write-Host "[INFO] " -ForegroundColor Blue -NoNewline; Write-Host "Keeping your local mod files." -ForegroundColor DarkYellow
            }
        } 
        elseif ($foundModJson -and -not $localModExists) {
            Write-DebugMsg "Local mod missing. Copying from extracted archive."
            if (Test-Path $localModDir) { Remove-Item $localModDir -Recurse -Force }
            Copy-Item -Path $foundModJson.Directory.FullName -Destination $localModDir -Recurse -Force
            Write-Host "[OK] " -ForegroundColor Green -NoNewline; Write-Host "Downloaded missing mod cache." -ForegroundColor White
        }

    } else {
        Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline; Write-Host "No .zip files found in release." -ForegroundColor DarkYellow
    }
} catch { 
    Write-DebugMsg "EXCEPTION in Step 2: $($_.Exception.Message)"
    Write-DebugMsg "STACK TRACE: $($_.ScriptStackTrace)"
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host "Download failed: $($_.Exception.Message)" -ForegroundColor Red
} 

try {
    $readmeUrl = "https://raw.githubusercontent.com/$repoOwner/$repoName/main/README.txt"
    Invoke-WebRequest -Uri $readmeUrl -OutFile (Join-Path $currentDir "README.txt")
} catch { }

 $ErrorActionPreference = 'SilentlyContinue'

if (-not $bridgeReady) {
    if (Test-Path $bridgeExe) {
        Write-Host "[INFO] " -ForegroundColor Blue -NoNewline; Write-Host "Using local RumbleBridge.exe." -ForegroundColor DarkYellow
        $bridgeReady = $true
    } else {
        $versionedExe = Get-ChildItem -Path $currentDir -Filter "RumbleBridge*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($versionedExe) {
            Write-DebugMsg "Fallback: Found versioned EXE $($versionedExe.Name). Copying to RumbleBridge.exe"
            Copy-Item $versionedExe.FullName -Destination $bridgeExe -Force
            $bridgeReady = $true
        }
    }
}
Write-Host ''

# =========================================================================
# STEP 3: Install / Update OMORI Mod
# =========================================================================
Write-DebugMsg "Beginning Step 3: Checking OMORI mod installation..."
Write-Host "[3/4] " -ForegroundColor Cyan -NoNewline
Write-Host "Checking OMORI mod installation..." -ForegroundColor White

 $modDest = Join-Path $omoriPath 'www\mods\rumble'
Write-DebugMsg "Target Mod Destination: $modDest"

if (Test-Path (Join-Path $modDest 'mod.json')) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline; Write-Host "Mod already installed in OMORI. Skipping." -ForegroundColor White
    $modReady = $true
} 
elseif ((Test-Path $localModDir) -and (Test-Path (Join-Path $localModDir 'mod.json'))) {
    Write-Host "[OK] " -ForegroundColor Green -NoNewline; Write-Host "Installing mod from local cache..." -ForegroundColor White
    $modsParentDir = Split-Path $modDest
    if (-not (Test-Path $modsParentDir)) { 
        Write-DebugMsg "Creating parent directory: $modsParentDir"
        New-Item -ItemType Directory -Path $modsParentDir -Force | Out-Null 
    }
    Write-DebugMsg "Copying from $localModDir to $modDest"
    Copy-Item -Path $localModDir -Destination $modDest -Recurse -Force
    $modReady = $true
} 
else {
    Write-DebugMsg "ERROR: Mod files not found locally or in OMORI directory."
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host "Mod not found!" -ForegroundColor Red
}
Write-Host ''

# =========================================================================
# STEP 4: Launch & Monitor via Text File
# =========================================================================
Write-DebugMsg "Beginning Step 4: Launching processes..."
Write-Host "[4/4] " -ForegroundColor Cyan -NoNewline
Write-Host "Launching Rumble Bridge and OMORI..." -ForegroundColor White

if ($bridgeReady -and $modReady) {
    
    try {
        $existingBridges = Get-Process -Name "RumbleBridge" -ErrorAction SilentlyContinue
        if ($existingBridges) {
            Write-Host "[INFO] " -ForegroundColor Blue -NoNewline
            Write-Host "Found $($existingBridges.Count) extra RumbleBridge process(es). Killing them..." -ForegroundColor DarkYellow
            Write-DebugMsg "Killing existing RumbleBridge processes. PIDs: $($existingBridges.Id -join ', ')"
            $existingBridges | Stop-Process -Force
            Start-Sleep -Seconds 2
        }
        
        Write-DebugMsg "Executing: Start-Process -FilePath '$bridgeExe' -WindowStyle Hidden"
        Start-Process -FilePath $bridgeExe -WindowStyle Hidden

        Write-Host "[OK] " -ForegroundColor Green -NoNewline; Write-Host "Rumble Bridge started." -ForegroundColor White

        Write-Host '====================================================================' -ForegroundColor Cyan
        Write-Host ' Rumble Bridge is running. OMORI is launching via Steam...' -ForegroundColor Cyan
        Write-Host ' Window closes automatically when you exit OMORI.' -ForegroundColor DarkGray
        Write-Host '====================================================================' -ForegroundColor Cyan

        if ($GameExePath -and (Test-Path $GameExePath)) {
            Write-DebugMsg "STEAM WRAPPER LAUNCH: Executing Start-Process -FilePath '$GameExePath'"
            Start-Process -FilePath $GameExePath
        }
        elseif ($launchMethod -eq "direct") {
            $omoriExe = Join-Path $omoriPath 'OMORI.exe'
            Write-DebugMsg "DIRECT LAUNCH: Executing Start-Process -FilePath '$omoriExe'"
            Start-Process -FilePath $omoriExe
        } else {
            Write-DebugMsg "STEAM LAUNCH: Executing Start-Process 'steam://rungameid/$steamAppId'"
            Start-Process "steam://rungameid/$steamAppId"
        }

        Start-Sleep -Seconds 3 
        $lastLineCount = 0
        $lastDebugTick = Get-Date

        while ($true) {
            $bridgeRunning = [bool](Get-Process -Name "RumbleBridge" -ErrorAction SilentlyContinue)
            $omoriRunning = [bool](Get-Process -Name "OMORI*" -ErrorAction SilentlyContinue)

            if ($isDebug -and ((Get-Date) - $lastDebugTick).TotalSeconds -ge 5) {
                Write-DebugMsg "Loop Tick -> Bridge: $bridgeRunning | OMORI: $omoriRunning | LogExists: $(Test-Path $logFile) | Lines Read: $lastLineCount"
                $lastDebugTick = Get-Date
            }

            if (-not $bridgeRunning -and -not $omoriRunning) {
                Write-DebugMsg "Both processes exited. Breaking loop."
                Write-Host ''
                Write-Host '====================================================================' -ForegroundColor Red
                Write-Host ' OMORI and Rumble Bridge have closed. Exiting...' -ForegroundColor Red
                Write-Host '====================================================================' -ForegroundColor Red
                break
            }

            if (Test-Path $logFile) {
                try {
                    $lines = Get-Content $logFile -ErrorAction Stop
                    if ($lines -and $lines.Count -gt $lastLineCount) {
                        $newLines = $lines[$lastLineCount..($lines.Count - 1)]
                        Write-DebugMsg "Read $($newLines.Count) new lines from bridge_log.txt"
                        foreach ($line in $newLines) {
                            
                            if ($line -match '^\s*=+\s*$' -or $line -match 'OMORI RUNTIME CONTROLLER BRIDGE') {
                                continue
                            }

                            if ($line -match 'Intensity:\s*([0-9.]+)') {
                                $intensity = [float]$matches[1]
                                if ($intensity -lt 0.35) { $color = "Green" }
                                elseif ($intensity -le 0.70) { $color = "Yellow" }
                                else { $color = "Red" }
                                Write-Host "  $line" -ForegroundColor $color
                            } elseif ($line -match '\[ERROR\]') {
                                Write-Host "  $line" -ForegroundColor Red
                            } elseif ($line -match '\[HARDWARE\]') {
                                Write-Host "  $line" -ForegroundColor Green
                            } elseif ($line -match '\[NETWORK\] Connected') {
                                Write-Host "  $line" -ForegroundColor Green
                            } elseif ($line -match '\[NETWORK\]') {
                                Write-Host "  $line" -ForegroundColor Cyan
                            } else {
                                Write-Host "  $line" -ForegroundColor DarkGray
                            }
                        }
                        $lastLineCount = $lines.Count
                    }
                } catch { 
                    Write-DebugMsg "EXCEPTION reading log file: $($_.Exception.Message)"
                }
            }
            
            Start-Sleep -Milliseconds 100
        }
    }
    catch {
        Write-DebugMsg "FATAL EXCEPTION in Step 4: $($_.Exception.Message)"
        Write-DebugMsg "STACK TRACE: $($_.ScriptStackTrace)"
    }
    finally {
        Write-Host "[INFO] " -ForegroundColor Blue -NoNewline; Write-Host "Cleaning up residual processes..." -ForegroundColor DarkYellow
        $leftoverBridges = Get-Process -Name "RumbleBridge" -ErrorAction SilentlyContinue
        if ($leftoverBridges) {
            Write-DebugMsg "Cleanup: Killing leftover PIDs: $($leftoverBridges.Id -join ', ')"
            $leftoverBridges | Stop-Process -Force
            Write-Host "[OK] " -ForegroundColor Green -NoNewline; Write-Host "Successfully killed all RumbleBridge processes." -ForegroundColor White
        }
        
        if (Test-Path $logFile) { Remove-Item $logFile -Force -ErrorAction SilentlyContinue }
        
        # Pause before closing if Debug mode is on
        if ($isDebug) {
            Write-Host ''
            Write-Host "[DEBUG] " -ForegroundColor DarkMagenta -NoNewline; Write-Host "Window paused for log review. Press Enter to close..." -ForegroundColor White
            Read-Host
        }
        Start-Sleep -Seconds 1
    }

    exit 0

} else {
    Write-Host ''    
    Write-Host '====================================================================' -ForegroundColor Red
    Write-Host ' LAUNCH ABORTED: MISSING REQUIRED FILES' -ForegroundColor Red
    Write-Host '====================================================================' -ForegroundColor Red
    if (-not $bridgeReady) { 
        Write-Host ' - RumbleBridge.exe is missing.' -ForegroundColor Red
        Write-DebugMsg "LAUNCH ABORTED: RumbleBridge.exe missing at $bridgeExe"
    }
    if (-not $modReady) { 
        Write-Host ' - OMORI mod is not installed.' -ForegroundColor Red
        Write-DebugMsg "LAUNCH ABORTED: Mod not found at $modDest"
    }
    Write-Host ''    
    
    # Pause before closing if Debug mode is on
    if ($isDebug) {
        Write-Host "[DEBUG] " -ForegroundColor DarkMagenta -NoNewline; Write-Host "Window paused for log review. Press Enter to close..." -ForegroundColor White
        Read-Host
    }
    
    Start-Sleep -Seconds 10
}