import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0

Rectangle {
    id: infoBanner

    color: 'transparent'

    property XmlListModel flowModelXml
    property ListModel flowModel
    property bool xml: false

    property int previewedItems: xml ?  flowModelXml.count : flowModel.count
    property string previewedField: ''

    property string highlighted : ''
    property bool randomColors: true
    property int animDuration: 1000

    height: Theme.itemSizeExtraLarge * 2
    width: parent.width

    visible: (orientation == 1)

    Label {
        anchors.centerIn: parent
        font.pixelSize: Theme.fontSizeExtraLarge * 3
        text: previewedItems
        opacity: 0
        color: Theme.highlightColor
        NumberAnimation on opacity { from: 0; to: 1; duration: animDuration*2 }
        z: 3
        visible: (previewedItems > 0)
    }


    Repeater {
        model: Math.min(previewedItems,15)
        delegate: Label {
                property int x_target: 0
                property int y_target: 0
                color: randomColors ? getRandomColor() : Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                opacity: 1-(Math.random()/5)
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    horizontalCenterOffset: x_target
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: y_target
                }
                NumberAnimation on x_target { from: 0; to: randomIntFromInterval(-Math.floor(parent.width/2), Math.floor(parent.width/2)); duration: animDuration }
                NumberAnimation on y_target { from: 0; to: randomIntFromInterval(-Math.floor(parent.height/2), Math.floor(parent.height/2)); duration: animDuration }
                text: modelGet(index)
            }
    }
    function randomIntFromInterval(min,max)
    {
        return Math.floor(Math.random()*(max-min+1)+min);
    }
    function getRandomColor() {
        var letters = '0123456789ABCDEF'.split('');
        var color = '#';
        for (var i = 0; i < 6; i++ ) {
            color += letters[Math.floor(Math.random() * 16)];
        }
        return color;
    }
    function modelGet(index) {
        if (xml) {
            return flowModelXml.get(index)[previewedField]
        } else {
            return flowModel.get(index)[previewedField]
        }
    }
}
