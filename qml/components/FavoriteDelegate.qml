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
    id: delegate

    property int tileWidth: 140
    property int tileHeight: 210

    property real labelBackgroundOpacity: 0.8
    property color labelBackgroundColor: 'grey'

    property alias text: delegateLabel.text
    property alias source: delegateImage.source

    property int labelMaximumLineCount: 3

    width: tileWidth
    height: tileHeight

    Image {
        id: delegateImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
    }

    Rectangle {
        id: delegateLabelBackground
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: delegateLabel.height
        color: labelBackgroundColor
        opacity: labelBackgroundOpacity
    }

    Label {
        id: delegateLabel
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        elide: Text.ElideRight
        anchors {
            verticalCenter: delegateLabelBackground.verticalCenter
            left: parent.left
            leftMargin: Theme.paddingSmall
            right: parent.right
            rightMargin: Theme.paddingSmall
        }
        color: Theme.primaryColor
        maximumLineCount: labelMaximumLineCount
    }
}
