import QtQuick
import Qt.labs.platform as Platform

QtObject {
    id: root

    property var executableSource
    property int checkInterval: 7200000 // 120 minutes
    property bool autoDownload: false
    property string steamPath: ""
    property bool showNotifications: true
    property bool debugMode: false

    property bool working: false
    property real workingProgress: 0.0
    property string statusMessage: ""

    signal versionInfoUpdated(string current, string latest, bool updateAvailable)
    signal workingStateChanged(bool working, real workingProgress)

    property string detectedSteamPath: ""
    property string compatToolsPath: ""
    property string currentInstalledVersion: ""
    property string latestReleaseVersion: ""
    property string latestDownloadUrl: ""
    property string logFilePath: ""

    // Timer for clearing status messages
    property Timer statusTimer: Timer {
        interval: 5000
        repeat: false
        onTriggered: statusMessage = ""
    }

    // Timer for clearing installation message
    property Timer installTimer: Timer {
        interval: 3000
        repeat: false
        onTriggered: statusMessage = ""
    }

    // GitHub API component
    property var githubAPI: GitHubAPI {
        id: githubAPI
        owner: "GloriousEggroll"
        repo: "proton-ge-custom"

        onReleaseDataReceived: function(releaseInfo) {
            if (Array.isArray(releaseInfo)) {
                if (releaseInfo.length > 0) {
                    handleReleaseInfo(releaseInfo[0])
                }
            } else {
                handleReleaseInfo(releaseInfo)
            }
        }

        onErrorOccurred: function(error) {
            setWorking(false, 0, error)
            log("ERROR", "GitHub API Error: " + error)
        }
    }

    // Timer for periodic checks
    property Timer updateTimer: Timer {
        interval: root.checkInterval
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            if (!working) {
                checkForUpdates()
            }
        }
    }

    Component.onCompleted: {
        initializeLogFile()
        detectSteamDirectory()
    }

    // Initialize log file with timestamp
    function initializeLogFile() {
        var date = new Date()
        var timestamp = Qt.formatDateTime(date, "yyyyMMdd_HHmmss")
        var homeDir = Platform.StandardPaths.writableLocation(Platform.StandardPaths.HomeLocation)
        var logDir = homeDir + "/.local/share/proton-ge-monitor/logs/"

        // Create logs directory
        executableSource.connectSource("mkdir -p '" + logDir + "'")

        logFilePath = logDir + timestamp + ".log"
        log("INFO", "=== Proton GE Monitor Started ===")
        log("INFO", "Log file: " + logFilePath)

        // Clean old logs (keep only last 10)
        executableSource.connectSource("ls -t '" + logDir + "'*.log 2>/dev/null | tail -n +11 | xargs -r rm")
    }

    // Logging function
    function log(level, message) {
        if (!debugMode && level === "DEBUG") return

            var date = new Date()
            var timestamp = Qt.formatDateTime(date, "yyyy-MM-dd HH:mm:ss.zzz")
            var logEntry = "[" + timestamp + "] [" + level + "] " + message

            console.log(logEntry)

            if (logFilePath && logFilePath.length > 0) {
                var escapedEntry = logEntry.replace(/'/g, "'\\''")
                executableSource.connectSource("echo '" + escapedEntry + "' >> '" + logFilePath + "'")
            }
    }

    function detectSteamDirectory() {
        log("INFO", "Starting Steam directory detection")
        statusMessage = "Detecting Steam installation..."

        // If custom path is provided, validate it first
        if (steamPath && steamPath.length > 0) {
            log("INFO", "Checking custom Steam path: " + steamPath)
            // Remove trailing slash if present
            var cleanPath = steamPath.replace(/\/$/, "")

            // Check if the path exists and contains Steam
            var validateCmd = "if [ -d '" + cleanPath + "' ]; then " +
            "if [ -d '" + cleanPath + "/steamapps' ] || [ -d '" + cleanPath + "/compatibilitytools.d' ]; then " +
            "echo 'VALID:" + cleanPath + "'; " +
            "elif [ -d '" + cleanPath + "/data/Steam' ]; then " +
            "echo 'VALID:" + cleanPath + "/data/Steam'; " +
            "elif [ -d '" + cleanPath + "/.steam/root' ]; then " +
            "echo 'VALID:" + cleanPath + "/.steam/root'; " +
            "else " +
            "echo 'INVALID'; " +
            "fi; " +
            "else " +
            "echo 'NOTFOUND'; " +
            "fi"

            executableSource.connectSource("validate_steam|" + validateCmd)
            return
        }

        // Auto-detect Steam locations
        log("INFO", "Auto-detecting Steam installation")
        var homeDir = Platform.StandardPaths.writableLocation(Platform.StandardPaths.HomeLocation)

        // Check common Steam locations in order of likelihood
        var checkCmd = "for dir in " +
        "'" + homeDir + "/.steam/root' " +
        "'" + homeDir + "/.steam/steam' " +
        "'" + homeDir + "/.local/share/Steam' " +
        "'" + homeDir + "/.var/app/com.valvesoftware.Steam/data/Steam' " +
        "'" + homeDir + "/.var/app/com.valvesoftware.Steam/.local/share/Steam' " +
        "'/usr/share/steam' " +
        "'/usr/local/share/steam'; do " +
        "if [ -d \"$dir\" ] && [ -d \"$dir/steamapps\" ]; then " +
        "echo \"FOUND:$dir\"; " +
        "break; " +
        "fi; " +
        "done"

        executableSource.connectSource("auto_detect|" + checkCmd)
    }

    function checkCurrentVersion() {
        if (!compatToolsPath || compatToolsPath.length === 0) {
            log("WARNING", "Cannot check current version: compatToolsPath not set")
            currentInstalledVersion = "Not installed"
            checkForUpdates()
            return
        }

        log("INFO", "Checking installed version in: " + compatToolsPath)
        statusMessage = "Checking installed version..."

        // List all GE-Proton directories and get the latest
        var checkCmd = "if [ -d '" + compatToolsPath + "' ]; then " +
        "ls -d '" + compatToolsPath + "'/GE-Proton* 2>/dev/null | " +
        "sed 's/.*GE-Proton/GE-Proton/' | sort -V | tail -1; " +
        "else " +
        "echo 'DIR_NOT_FOUND'; " +
        "fi"

        executableSource.connectSource("check_version|" + checkCmd)
    }

    function checkForUpdates() {
        if (working || githubAPI.loading) return

            log("INFO", "Checking for updates from GitHub")
            setWorking(true, 0, "Checking for updates...")
            githubAPI.getLatestRelease()
    }

    function handleReleaseInfo(releaseInfo) {
        log("INFO", "Received release info: " + releaseInfo.version)
        latestReleaseVersion = releaseInfo.version
        latestDownloadUrl = releaseInfo.downloadUrl

        if (!latestDownloadUrl) {
            log("ERROR", "No download URL found in release")
            setWorking(false, 0, "No download URL found in release")
            return
        }

        var hasUpdate = currentInstalledVersion !== latestReleaseVersion &&
        currentInstalledVersion !== "Not installed" &&
        currentInstalledVersion !== ""

        log("INFO", "Current: " + currentInstalledVersion + ", Latest: " + latestReleaseVersion + ", Update available: " + hasUpdate)

        versionInfoUpdated(currentInstalledVersion || "Not installed", latestReleaseVersion, hasUpdate)

        setWorking(false, 0, "")

        if (hasUpdate && autoDownload) {
            log("INFO", "Auto-download enabled, starting download")
            downloadLatest()
        }

        // Show additional info temporarily
        if (releaseInfo.publishedAt) {
            var formattedDate = githubAPI.formatDate(releaseInfo.publishedAt)
            var formattedSize = githubAPI.formatFileSize(releaseInfo.fileSize)
            statusMessage = "Released: " + formattedDate + " - Size: " + formattedSize
            statusTimer.restart()
        }
    }

    function downloadLatest() {
        if (working || !latestDownloadUrl || latestDownloadUrl.length === 0) {
            log("WARNING", "Cannot download: working=" + working + ", URL=" + latestDownloadUrl)
            return
        }

        if (!compatToolsPath || compatToolsPath.length === 0) {
            log("ERROR", "Cannot download: Steam directory not found")
            statusMessage = "Steam directory not found"
            return
        }

        log("INFO", "Starting download of " + latestReleaseVersion)
        setWorking(true, 0.1, "Starting download...")

        // Create compatibility tools directory if needed
        executableSource.connectSource("create_dir|mkdir -p '" + compatToolsPath + "'")

        // Download with progress tracking
        var tempFile = "/tmp/" + latestReleaseVersion + ".tar.xz"
        log("INFO", "Downloading to: " + tempFile)

        var wgetCmd = "wget --progress=dot:giga " +
        "--tries=3 " +
        "--timeout=30 " +
        "--user-agent='ProtonGE-Monitor-Widget' " +
        "-O '" + tempFile + "' " +
        "'" + latestDownloadUrl + "' 2>&1"

        executableSource.connectSource("download|" + wgetCmd)
    }

    function handleCommandResult(source, data) {
        var exitCode = data["exit code"] || 0
        var stdout = (data["stdout"] || "").trim()
        var stderr = (data["stderr"] || "").trim()

        // Extract command ID from source
        var parts = source.split("|")
        var commandId = parts[0]

        log("DEBUG", "Command [" + commandId + "] exit: " + exitCode + ", stdout: " + stdout.substring(0, 100))

        if (commandId === "validate_steam") {
            handleValidateSteam(stdout, exitCode)
        }
        else if (commandId === "auto_detect") {
            handleAutoDetect(stdout, exitCode)
        }
        else if (commandId === "check_version") {
            handleCheckVersion(stdout, exitCode)
        }
        else if (commandId === "create_dir") {
            if (exitCode === 0) {
                log("DEBUG", "Directory created/verified")
            }
        }
        else if (commandId === "download") {
            handleDownload(stdout, stderr, exitCode)
        }
        else if (commandId === "extract") {
            handleExtract(exitCode, stderr)
        }
        else if (commandId === "cleanup") {
            log("DEBUG", "Cleanup completed")
        }
        else if (commandId === "notify") {
            log("DEBUG", "Notification sent")
        }
    }

    function handleValidateSteam(stdout, exitCode) {
        if (stdout.substring(0, 6) === "VALID:") {
            var validPath = stdout.substring(6)
            log("INFO", "Valid Steam path found: " + validPath)
            detectedSteamPath = validPath
            compatToolsPath = validPath + "/compatibilitytools.d"
            checkCurrentVersion()
        } else {
            log("ERROR", "Invalid Steam path: " + steamPath)
            statusMessage = "Invalid Steam path specified"
            // Try auto-detection
            steamPath = ""
            detectSteamDirectory()
        }
    }

    function handleAutoDetect(stdout, exitCode) {
        if (stdout.substring(0, 6) === "FOUND:") {
            var foundPath = stdout.substring(6)
            log("INFO", "Auto-detected Steam at: " + foundPath)
            detectedSteamPath = foundPath
            compatToolsPath = foundPath + "/compatibilitytools.d"
            checkCurrentVersion()
        } else {
            log("ERROR", "Steam installation not found")
            statusMessage = "Steam not found. Please set custom path in settings."
            setWorking(false, 0, statusMessage)
        }
    }

    function handleCheckVersion(stdout, exitCode) {
        if (stdout === "DIR_NOT_FOUND") {
            log("WARNING", "Compatibility tools directory not found")
            currentInstalledVersion = "Not installed"
        } else if (stdout && stdout.length > 0) {
            currentInstalledVersion = stdout
            log("INFO", "Current installed version: " + currentInstalledVersion)
        } else {
            currentInstalledVersion = "Not installed"
            log("INFO", "No Proton GE version installed")
        }
        checkForUpdates()
    }

    function handleDownload(stdout, stderr, exitCode) {
        if (exitCode === 0) {
            log("INFO", "Download completed successfully")
            setWorking(true, 0.7, "Download complete, extracting...")
            extractDownload()
        } else {
            log("ERROR", "Download failed: " + stderr)
            setWorking(false, 0, "Download failed. Check logs for details.")
        }
    }

    function handleExtract(exitCode, stderr) {
        if (exitCode === 0) {
            log("INFO", "Extraction completed successfully")
            finishInstallation()
        } else {
            log("ERROR", "Extraction failed: " + stderr)
            setWorking(false, 0, "Extraction failed. Check logs for details.")
        }
    }

    function extractDownload() {
        var tempFile = "/tmp/" + latestReleaseVersion + ".tar.xz"
        log("INFO", "Extracting " + tempFile + " to " + compatToolsPath)
        setWorking(true, 0.8, "Extracting...")

        var extractCmd = "cd '" + compatToolsPath + "' && " +
        "tar -xf '" + tempFile + "' 2>&1 && " +
        "echo 'Extraction completed'"

        executableSource.connectSource("extract|" + extractCmd)
    }

    function finishInstallation() {
        log("INFO", "Installation completed for " + latestReleaseVersion)
        setWorking(false, 1.0, "Installation complete!")

        // Clean up temporary file
        var tempFile = "/tmp/" + latestReleaseVersion + ".tar.xz"
        executableSource.connectSource("cleanup|rm -f '" + tempFile + "'")

        // Update current version
        currentInstalledVersion = latestReleaseVersion
        versionInfoUpdated(currentInstalledVersion, latestReleaseVersion, false)

        if (showNotifications) {
            var notifyCmd = "notify-send 'Proton GE Updated' 'Successfully installed " + latestReleaseVersion + "'"
            executableSource.connectSource("notify|" + notifyCmd)
        }

        installTimer.restart()
    }

    function setWorking(isWorking, progressValue, message) {
        working = isWorking
        workingProgress = progressValue
        statusMessage = message
        if (message && message.length > 0) {
            log("STATUS", message)
        }
        workingStateChanged(working, workingProgress)
    }
}
