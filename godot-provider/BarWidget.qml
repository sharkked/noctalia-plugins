import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

Rectangle {
    id: root

    property var pluginApi: null

    // Required properties for bar widgets
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    implicitWidth: row.implicitWidth + Style.marginM * 2
    implicitHeight: Style.barHeight

    color: Style.capsuleColor
    radius: Style.radiusM

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Style.marginS

        Nicon {
            icon: "heart"
            color: Color.mPrimary
        }

        NText {
            text: "My Plugin"
            color: Color.mOnSurface
            pointSize: Style.fontSizeS
        }
    }
}
