/**************************************************************************
 *   Butaca
 *   Copyright (C) 2011 - 2012 Simon Pena <spena@igalia.com>
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 **************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0


BackgroundItem {
    id: textContainer
    width: parent.width
    height: expanded ? actualSize : Math.min(actualSize, collapsedSize)
    clip: true
    property string textHeader: ''
    property string textContent: ''

    Behavior on height {
        NumberAnimation { duration: 200 }
    }

    property int actualSize: innerColumn.height
    property int collapsedSize: 160
    property bool expanded: false

    Column {
        id: innerColumn
        width: parent.width

        SectionHeader {
            id: header
            text: textHeader
        }

        Label {
            id: contentLabel
            width: parent.width
            text: textContent
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignJustify
        }
    }

//    OpacityRampEffect {
//        id: expandEffect
//        visible: !expanded
//        sourceItem: contentLabel
//        direction: OpacityRampEffect.TopToBottom
//        offset: 0.3
//        slope: 2
//        Behavior on visible {
//            NumberAnimation { duration: 200 }
//        }
//    }
//    Rectangle {
//        anchors.bottom: parent.bottom
//        width: parent.width
//        height: parent.height / 3
//        visible: !expanded
//        opacity: 0.5
//        gradient: Gradient {
//             GradientStop { position: 0.0; color: "transparent" }
//             GradientStop { position: 1.0; color: Theme.highlightColor }
//         }
//        Behavior on visible {
//            NumberAnimation { duration: 200 }
//        }
//    }

    onClicked: textContainer.expanded = !textContainer.expanded
}

