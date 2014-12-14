import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    id: col
    property alias title: header.title
    property alias modelXml: banner.flowModelXml
    property alias modelSt: banner.flowModel
    property alias previewedField: banner.previewedField
    property alias highlighted: banner.highlighted
    property alias randomColors: banner.randomColors
    property alias xml: banner.xml
    width: parent.width

    anchors {
        left: parent.left
        right: parent.right
        top: parent.top
        margins: Theme.paddingMedium
    }

    PageHeader {
        id: header
    }

    InfoBanner {
        id: banner
        width: parent.width
    }
    Item {
        height: Theme.paddingMedium
    }
}
