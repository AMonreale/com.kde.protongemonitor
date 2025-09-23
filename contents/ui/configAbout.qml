import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        // Logo/Icon section
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 128
            Layout.preferredWidth: 128

            Kirigami.Icon {
                anchors.fill: parent
                source: "application-x-ms-dos-executable"

                // Version badge
                Rectangle {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    width: 48
                    height: 20
                    radius: 10
                    color: Kirigami.Theme.positiveBackgroundColor

                    QQC2.Label {
                        anchors.centerIn: parent
                        text: "v1.0"
                        font.pointSize: 9
                        font.bold: true
                        color: Kirigami.Theme.positiveTextColor
                    }
                }
            }
        }

        // Title
        QQC2.Label {
            Layout.alignment: Qt.AlignHCenter
            text: i18n("Proton GE Monitor")
            font.pointSize: 16
            font.bold: true
        }

        // Description
        QQC2.Label {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            text: i18n("Automatically monitor and download Proton GE releases")
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        // Info cards
        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing

            QQC2.GroupBox {
                title: i18n("About")
                Layout.fillWidth: true

                GridLayout {
                    columns: 2
                    columnSpacing: Kirigami.Units.largeSpacing

                    QQC2.Label {
                        text: i18n("Version:")
                        font.bold: true
                    }
                    QQC2.Label {
                        text: "1.0.0"
                        Layout.fillWidth: true
                    }

                    QQC2.Label {
                        text: i18n("Author:")
                        font.bold: true
                    }
                    QQC2.Label {
                        text: "Your Name"
                        Layout.fillWidth: true
                    }

                    QQC2.Label {
                        text: i18n("License:")
                        font.bold: true
                    }
                    QQC2.Label {
                        text: "GPL v3"
                        Layout.fillWidth: true
                    }
                }
            }

            QQC2.GroupBox {
                title: i18n("Resources")
                Layout.fillWidth: true

                ColumnLayout {
                    QQC2.Button {
                        text: i18n("Proton GE on GitHub")
                        icon.name: "github-mark"
                        Layout.fillWidth: true
                        onClicked: Qt.openUrlExternally("https://github.com/GloriousEggroll/proton-ge-custom")
                    }

                    QQC2.Button {
                        text: i18n("Report a Bug")
                        icon.name: "tools-report-bug"
                        Layout.fillWidth: true
                        onClicked: Qt.openUrlExternally("https://github.com/yourusername/proton-ge-monitor/issues")
                    }

                    QQC2.Button {
                        text: i18n("Widget Documentation")
                        icon.name: "help-contents"
                        Layout.fillWidth: true
                        onClicked: Qt.openUrlExternally("https://github.com/yourusername/proton-ge-monitor/wiki")
                    }
                }
            }

            QQC2.GroupBox {
                title: i18n("Support")
                Layout.fillWidth: true

                ColumnLayout {
                    QQC2.Label {
                        text: i18n("If you find this widget useful, consider:")
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        QQC2.Button {
                            text: i18n("⭐ Star on GitHub")
                            Layout.fillWidth: true
                            onClicked: Qt.openUrlExternally("https://github.com/yourusername/proton-ge-monitor")
                        }

                        QQC2.Button {
                            text: i18n("☕ Buy me a coffee")
                            Layout.fillWidth: true
                            onClicked: Qt.openUrlExternally("https://ko-fi.com/yourusername")
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
