import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import Qt.labs.platform as Platform // Aggiunto per il FolderDialog

KCM.SimpleKCM {
    property alias cfg_cleanOldVersions: cleanOldCheckBox.checked
    property alias cfg_maxVersionsToKeep: maxVersionsSpinBox.value
    property alias cfg_githubToken: githubTokenField.text
    property alias cfg_downloadTimeout: timeoutSpinBox.value
    property alias cfg_useSystemProxy: proxyCheckBox.checked
    property alias cfg_debugMode: debugCheckBox.checked
    property alias cfg_logDirectory: logDirectoryField.text

    Kirigami.FormLayout {
        QQC2.GroupBox {
            title: i18n("Cleanup Settings")
            Layout.fillWidth: true
            ColumnLayout {
                QQC2.CheckBox {
                    id: cleanOldCheckBox
                    text: i18n("Automatically remove old versions")
                }
                RowLayout {
                    enabled: cleanOldCheckBox.checked
                    QQC2.Label { text: i18n("Keep last:") }
                    QQC2.SpinBox {
                        id: maxVersionsSpinBox
                        from: 1
                        to: 10
                        value: 3
                    }
                    QQC2.Label { text: i18n("versions") }
                }
            }
        }

        QQC2.GroupBox {
            title: i18n("GitHub Settings")
            Layout.fillWidth: true
            ColumnLayout {
                QQC2.TextField {
                    id: githubTokenField
                    Layout.fillWidth: true
                    placeholderText: i18n("Personal Access Token (optional)")
                    echoMode: TextInput.Password
                }
                QQC2.Button {
                    text: i18n("How to get a token")
                    icon.name: "help-hint"
                    onClicked: Qt.openUrlExternally("https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token")
                }
            }
        }

        QQC2.GroupBox {
            title: i18n("Network Settings")
            Layout.fillWidth: true
            ColumnLayout {
                RowLayout {
                    QQC2.Label { text: i18n("Download timeout (seconds):") }
                    QQC2.SpinBox {
                        id: timeoutSpinBox
                        from: 30
                        to: 600
                        stepSize: 30
                        value: 300
                    }
                }
                QQC2.CheckBox {
                    id: proxyCheckBox
                    text: i18n("Use system proxy settings")
                }
            }
        }

        QQC2.GroupBox {
            title: i18n("Debug")
            Layout.fillWidth: true
            ColumnLayout {
                QQC2.CheckBox {
                    id: debugCheckBox
                    text: i18n("Enable debug logging")
                }

                // --- MODIFICA QUI ---
                // Abbiamo ora una riga con il campo di testo e il pulsante
                RowLayout {
                    Layout.fillWidth: true
                    enabled: debugCheckBox.checked

                    QQC2.TextField {
                        id: logDirectoryField
                        Layout.fillWidth: true
                        placeholderText: i18n("Please enter a path to save log files")
                    }

                    QQC2.Button {
                        icon.name: "folder-open"
                        onClicked: folderDialog.open()
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    // --- FINESTRA DI DIALOGO PER LA SELEZIONE DELLA CARTELLA ---
    Platform.FolderDialog {
        id: folderDialog
        title: i18n("Select Log Directory")
        folder: logDirectoryField.text || Platform.StandardPaths.writableLocation(Platform.StandardPaths.HomeLocation)

        onAccepted: {
            // Rimuoviamo il prefisso "file://" se presente
            logDirectoryField.text = folder.toString().replace(/^file:\/\//, '')
        }
    }
}
