import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami
import "lib" as Lib

PlasmoidItem {
    id: root

    property bool hasUpdate: false
    property string currentVersion: "Not installed"
    property string latestVersion: "Checking..."
    property bool isWorking: false
    property real progress: 0.0

    preferredRepresentation: fullRepresentation

    // Preferred sizes for popup
    Layout.preferredWidth: Kirigami.Units.gridUnit * 20
    Layout.preferredHeight: Kirigami.Units.gridUnit * 14

    toolTipMainText: "Proton GE Monitor"
    toolTipSubText: hasUpdate ? i18n("Update available: %1", latestVersion) : i18n("Up to date")

    // Background execution engine
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            protonManager.handleCommandResult(sourceName, data)
            disconnectSource(sourceName)
        }
    }

    // Main logic controller
    Lib.ProtonManager {
        id: protonManager
        executableSource: executable

        checkInterval: plasmoid.configuration.checkInterval * 60000
        autoDownload: plasmoid.configuration.autoDownload
        steamPath: plasmoid.configuration.customSteamPath
        showNotifications: plasmoid.configuration.showNotifications
        debugMode: plasmoid.configuration.debugMode || false

        onVersionInfoUpdated: function(current, latest, updateAvailable) {
            currentVersion = current
            latestVersion = latest
            hasUpdate = updateAvailable
        }

        onWorkingStateChanged: function(working, workingProgress) {
            isWorking = working
            progress = workingProgress
        }
    }

    // Context menu actions
    Component.onCompleted: {
        // Add actions to context menu
        Plasmoid.addAction("checkNow", i18n("Check Now"), "view-refresh")
        Plasmoid.addAction("download", hasUpdate ? i18n("Download Update") : i18n("Force Download"), "download")
        Plasmoid.addAction("openFolder", i18n("Open Compatibility Tools Folder"), "folder-open")
        Plasmoid.addAction("openLogs", i18n("View Logs"), "view-list-text")

        console.log("Proton GE Monitor widget loaded")
    }

    // Handle context menu actions
    function action_checkNow() {
        protonManager.checkForUpdates()
    }

    function action_download() {
        protonManager.downloadLatest()
    }

    function action_openFolder() {
        var path = protonManager.compatToolsPath || "~/.steam/root/compatibilitytools.d/"
        Qt.openUrlExternally("file://" + path)
    }

    function action_openLogs() {
        // Use home directory detection
        var homeDir = Qt.resolvedUrl("~").toString().replace("file://", "")
        var logDir = homeDir + "/.local/share/proton-ge-monitor/logs/"
        Qt.openUrlExternally("file://" + logDir)
    }

    // Compact representation (panel icon)
    compactRepresentation: Item {
        id: compactRoot

        Layout.minimumWidth: Kirigami.Units.iconSizes.small
        Layout.minimumHeight: Kirigami.Units.iconSizes.small
        Layout.preferredWidth: Layout.minimumWidth
        Layout.preferredHeight: Layout.minimumHeight

        Kirigami.Icon {
            id: icon
            anchors.fill: parent
            source: plasmoid.configuration.icon || "application-x-ms-dos-executable"
            active: compactMouse.containsMouse

            // Update indicator
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                width: parent.width * 0.4
                height: width
                radius: width / 2
                color: Kirigami.Theme.positiveBackgroundColor
                visible: hasUpdate && !isWorking

                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: parent.width * 0.7
                    height: width
                    source: "arrow-down"
                    color: Kirigami.Theme.positiveTextColor
                }
            }

            // Working indicator
            PlasmaComponents.BusyIndicator {
                anchors.centerIn: parent
                width: parent.width * 0.8
                height: width
                running: isWorking
                visible: running
            }
        }

        MouseArea {
            id: compactMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton

            onClicked: function(mouse) {
                if (mouse.button === Qt.LeftButton) {
                    root.expanded = !root.expanded
                } else if (mouse.button === Qt.MiddleButton) {
                    protonManager.checkForUpdates()
                }
            }
        }
    }

    // Full representation (popup)
    fullRepresentation: ColumnLayout {
        id: fullRoot

        Layout.minimumWidth: Kirigami.Units.gridUnit * 18
        Layout.minimumHeight: Kirigami.Units.gridUnit * 12
        Layout.preferredWidth: Kirigami.Units.gridUnit * 20
        Layout.preferredHeight: Kirigami.Units.gridUnit * 14

        spacing: Kirigami.Units.smallSpacing

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Icon {
                source: "application-x-ms-dos-executable"
                Layout.preferredWidth: Kirigami.Units.iconSizes.large
                Layout.preferredHeight: Kirigami.Units.iconSizes.large
            }

            ColumnLayout {
                spacing: 0

                PlasmaComponents.Label {
                    text: "Proton GE Monitor"
                    font.weight: Font.Bold
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.2
                }

                PlasmaComponents.Label {
                    text: hasUpdate ? i18n("Update available") : i18n("Up to date")
                    color: hasUpdate ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.textColor
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                }
            }

            Item {
                Layout.fillWidth: true
            }

            // Quick action button for logs
            PlasmaComponents.ToolButton {
                icon.name: "view-list-text"
                onClicked: action_openLogs()
                PlasmaComponents.ToolTip {
                    text: i18n("View logs")
                }
            }
        }

        // Separator
        Kirigami.Separator {
            Layout.fillWidth: true
        }

        // Version information
        GridLayout {
            columns: 2
            columnSpacing: Kirigami.Units.largeSpacing
            rowSpacing: Kirigami.Units.smallSpacing
            Layout.fillWidth: true

            PlasmaComponents.Label {
                text: i18n("Current version:")
                color: Kirigami.Theme.disabledTextColor
            }
            PlasmaComponents.Label {
                text: currentVersion
                font.family: "monospace"
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                text: i18n("Latest version:")
                color: Kirigami.Theme.disabledTextColor
            }
            PlasmaComponents.Label {
                text: latestVersion
                font.family: "monospace"
                color: hasUpdate ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.textColor
                font.weight: hasUpdate ? Font.Bold : Font.Normal
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                text: i18n("Steam path:")
                color: Kirigami.Theme.disabledTextColor
                visible: protonManager.detectedSteamPath.length > 0
            }
            PlasmaComponents.Label {
                text: protonManager.detectedSteamPath
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                color: Kirigami.Theme.textColor
                visible: protonManager.detectedSteamPath.length > 0
                elide: Text.ElideMiddle
                Layout.fillWidth: true

                PlasmaComponents.ToolTip {
                    text: protonManager.detectedSteamPath
                }
            }
        }

        // Status message
        PlasmaComponents.Label {
            Layout.fillWidth: true
            text: protonManager.statusMessage
            color: Kirigami.Theme.textColor
            visible: protonManager.statusMessage.length > 0
            wrapMode: Text.WordWrap
            font.pointSize: Kirigami.Theme.smallFont.pointSize
        }

        // Progress bar
        PlasmaComponents.ProgressBar {
            Layout.fillWidth: true
            visible: isWorking
            from: 0
            to: 1
            value: progress

            PlasmaComponents.Label {
                anchors.centerIn: parent
                text: Math.round(progress * 100) + "%"
                visible: progress > 0
                font.pointSize: Kirigami.Theme.smallFont.pointSize
            }
        }

        // Spacer
        Item {
            Layout.fillHeight: true
        }

        // Action buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Button {
                text: i18n("Check Updates")
                icon.name: "view-refresh"
                enabled: !isWorking
                onClicked: protonManager.checkForUpdates()
            }

            PlasmaComponents.Button {
                text: hasUpdate ? i18n("Download") : i18n("Reinstall")
                icon.name: "download"
                enabled: !isWorking && latestVersion !== "Checking..."
                highlighted: hasUpdate
                onClicked: protonManager.downloadLatest()
            }

            Item {
                Layout.fillWidth: true
            }

            // Info text instead of Configure button
            PlasmaComponents.Label {
                text: i18n("Right-click for options")
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                color: Kirigami.Theme.disabledTextColor
            }
        }
    }
}
