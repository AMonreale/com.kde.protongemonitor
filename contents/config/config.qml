import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    id: configModel

    ConfigCategory {
        name: i18n("General")
        icon: "configure"
        source: "configGeneral.qml"
    }

    ConfigCategory {
        name: i18n("Advanced")
        icon: "preferences-system"
        source: "configAdvanced.qml"
    }

    ConfigCategory {
        name: i18n("About")
        icon: "help-about"
        source: "configAbout.qml"
    }
}
