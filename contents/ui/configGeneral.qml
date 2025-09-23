import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import Qt.labs.platform as Platform

KCM.SimpleKCM {
    property alias cfg_checkInterval: intervalSpinBox.value
    property alias cfg_autoDownload: autoDownloadCheckBox.checked
    property alias cfg_customSteamPath: steamPathField.text
    property alias cfg_showNotifications: notificationCheckBox.checked
    property alias cfg_debugMode: debugModeCheckBox.checked

    Kirigami.FormLayout {
        QQC2.GroupBox {
            title: i18n("Update Settings")
            Layout.fillWidth: true
            Kirigami.FormData.isSection: true

            ColumnLayout {
                RowLayout {
                    QQC2.Label {
                        text: i18n("Check for updates every:")
                    }

                    QQC2.SpinBox {
                        id: intervalSpinBox
                        from: 30
                        to: 1440
                        stepSize: 30
                        value: 120

                        textFromValue: function(value) {
                            if (value < 60) {
                                return value + " " + i18n("minutes")
                            } else {
                                var hours = Math.floor(value / 60)
                                var minutes = value % 60
                                if (minutes === 0) {
                                    return hours + " " + (hours === 1 ? i18n("hour") : i18n("hours"))
                                } else {
                                    return hours + "h " + minutes + "m"
                                }
                            }
                        }

                        QQC2.ToolTip.text: i18n("How often to check GitHub for new releases")
                        QQC2.ToolTip.visible: hovered
                    }
                }

                QQC2.CheckBox {
                    id: autoDownloadCheckBox
                    text: i18n("Automatically download updates")
                    QQC2.ToolTip.text: i18n("Download new versions as soon as they're detected")
                    QQC2.ToolTip.visible: hovered
                }

                QQC2.CheckBox {
                    id: notificationCheckBox
                    text: i18n("Show desktop notifications")
                    QQC2.ToolTip.text: i18n("Display notifications when updates are found or downloads complete")
                    QQC2.ToolTip.visible: hovered
                }
            }
        }

        QQC2.GroupBox {
            title: i18n("Steam Directory")
            Layout.fillWidth: true
            Kirigami.FormData.isSection: true

            ColumnLayout {
                QQC2.RadioButton {
                    id: autoDetectRadio
                    text: i18n("Auto-detect Steam installation")
                    checked: steamPathField.text.length === 0
                    onClicked: {
                        if (checked) {
                            steamPathField.text = ""
                        }
                    }
                }

                QQC2.RadioButton {
                    id: customPathRadio
                    text: i18n("Use custom Steam path")
                    checked: steamPathField.text.length > 0
                }

                RowLayout {
                    enabled: customPathRadio.checked
                    Layout.fillWidth: true

                    QQC2.TextField {
                        id: steamPathField
                        Layout.fillWidth: true
                        placeholderText: i18n("/path/to/Steam/")

                        onTextChanged: {
                            if (text.length > 0) {
                                customPathRadio.checked = true
                            }
                        }

                        QQC2.ToolTip.text: i18n("Path to your Steam installation directory")
                        QQC2.ToolTip.visible: hovered
                    }

                    QQC2.Button {
                        icon.name: "folder-open"
                        QQC2.ToolTip.text: i18n("Browse for Steam directory")
                        onClicked: folderDialog.open()
                    }
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    text: i18n("Common Steam locations:\n" +
                    "• ~/.steam/root/\n" +
                    "• ~/.local/share/Steam/\n" +
                    "• ~/.var/app/com.valvesoftware.Steam/data/Steam/")
                    font.pointSize: 8
                    color: Kirigami.Theme.disabledTextColor
                    visible: customPathRadio.checked
                }
            }
        }

        QQC2.GroupBox {
            title: i18n("Debug")
            Layout.fillWidth: true
            Kirigami.FormData.isSection: true

            ColumnLayout {
                QQC2.CheckBox {
                    id: debugModeCheckBox
                    text: i18n("Enable debug logging")
                    QQC2.ToolTip.text: i18n("Write detailed debug information to log files")
                    QQC2.ToolTip.visible: hovered
                }

                RowLayout {
                    QQC2.Button {
                        text: i18n("Open logs folder")
                        icon.name: "folder-open"
                        enabled: debugModeCheckBox.checked
                        onClicked: {
                            var logDir = Platform.StandardPaths.writableLocation(Platform.StandardPaths.GenericDataLocation) + "/proton-ge-monitor/logs/"
                            Qt.openUrlExternally("file://" + logDir)
                        }
                    }

                    QQC2.Label {
                        text: i18n("Logs are saved with timestamp: YYYYMMDD_HHMMSS.log")
                        font.pointSize: 8
                        color: Kirigami.Theme.disabledTextColor
                    }
                }
            }
        }

        QQC2.GroupBox {
            title: i18n("Quick Actions")
            Layout.fillWidth: true
            Kirigami.FormData.isSection: true

            RowLayout {
                QQC2.Button {
                    text: i18n("Check Now")
                    icon.name: "view-refresh"
                    QQC2.ToolTip.text: i18n("Check for updates immediately")
                    onClicked: {
                        // This would trigger an immediate check
                        showPassiveNotification(i18n("Checking for updates..."))
                    }
                }

                QQC2.Button {
                    text: i18n("Open Compatibility Tools")
                    icon.name: "folder-open"
                    QQC2.ToolTip.text: i18n("Open the Steam compatibility tools folder")
                    onClicked: {
                        var path = steamPathField.text || "~/.steam/root"
                        Qt.openUrlExternally("file://" + path + "/compatibilitytools.d/")
                    }
                }

                QQC2.Button {
                    text: i18n("Reset Settings")
                    icon.name: "edit-reset"
                    QQC2.ToolTip.text: i18n("Reset all settings to defaults")
                    onClicked: resetDialog.open()
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    Platform.FolderDialog {
        id: folderDialog
        title: i18n("Select Steam Installation Directory")
        folder: steamPathField.text || Platform.StandardPaths.writableLocation(Platform.StandardPaths.HomeLocation)

        onAccepted: {
            steamPathField.text = folder.toString().replace("file://", "")
        }
    }

    QQC2.Dialog {
        id: resetDialog
        title: i18n("Reset Settings")
        standardButtons: QQC2.Dialog.Yes | QQC2.Dialog.No
        modal: true
        parent: QQC2.Overlay.overlay

        QQC2.Label {
            text: i18n("Are you sure you want to reset all settings to their default values?")
        }

        onAccepted: {
            intervalSpinBox.value = 120
            autoDownloadCheckBox.checked = false
            steamPathField.text = ""
            notificationCheckBox.checked = true
            debugModeCheckBox.checked = false
            showPassiveNotification(i18n("Settings have been reset to defaults"))
        }
    }

    function showPassiveNotification(message) {
        // This would show a passive notification in the config window
        console.log("Notification:", message)
    }
}
