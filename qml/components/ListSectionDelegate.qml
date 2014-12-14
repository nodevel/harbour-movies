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


Item {
    property alias sectionName: sectionDelegateText.text

    id: sectionDelegate

    anchors {
        left: parent.left
        right: parent.right
        leftMargin: Theme.paddingLarge
        rightMargin: Theme.paddingLarge
    }

    height: sectionDelegateText.height + Theme.paddingLarge

    Rectangle {
        id: sectionDelegateDivider
        width: parent.width -
               sectionDelegateText.width -
               Theme.paddingLarge
        height: 3
        color: Theme.primaryColor
        anchors.verticalCenter: parent.verticalCenter
    }

    Label {
        id: sectionDelegateText
        color: Theme.primaryColor
        anchors {
            left: sectionDelegateDivider.right
            leftMargin: Theme.paddingLarge
            verticalCenter: sectionDelegateDivider.verticalCenter
        }
        width: Math.min(2 * parent.width / 3, helperText.width)
        wrapMode: Text.WordWrap
    }

    Label {
        id: helperText
        text: sectionDelegateText.text
        visible: false
    }
}
