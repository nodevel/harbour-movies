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
import '../js/moviedbwrapper.js' as TMDB

Flow {
    id: modelPreviewer

    property string previewerHeaderText: ''
    property string previewerFooterText: ''
    property int previewedItems: 4
    property ListModel previewedModel
    property alias previewerDelegate: previewerRepeater.delegate

    property string previewerDelegateTitle: ''
    property string previewerDelegateSubtitle: ''
    property string previewerDelegateIcon: ''
    property string previewerDelegatePlaceholder: ''

    signal clicked(int modelIndex)
    signal footerClicked()

//    MyEntryHeader {
//        width: parent.width
//        text: previewerHeaderText
//    }
    PageHeader {
        title: previewerHeaderText
    }

    Repeater {
        id: previewerRepeater
        width: parent.width
        model: Math.min(previewedItems, previewedModel.count)
        delegate: MyGridDelegate {
            width: modelPreviewer.width/(isLandscape ? 2 : 1)
            smallSize: true

            iconSource: previewedModel.get(index)[previewerDelegateIcon] ?
                            TMDB.image(TMDB.IMAGE_PROFILE, 0,
                                       previewedModel.get(index)[previewerDelegateIcon],
                                       { app_locale: appLocale }) :
                            previewerDelegatePlaceholder

            title: previewedModel.get(index)[previewerDelegateTitle]
            titleFontFamily: Theme.fontFamilyHeading
            titleSize: Theme.fontSizeSmall

            subtitle: previewedModel.get(index)[previewerDelegateSubtitle]
            subtitleSize: Theme.fontSizeExtraSmall
            subtitleFontFamily: Theme.fontFamily

            onClicked: modelPreviewer.clicked(index)
        }
    }

    MyListDelegate {
        width: parent.width
        smallSize: true
        title: previewerFooterText
        titleSize: Theme.fontSizeSmall
        titleFontFamily: Theme.fontFamilyHeading

        onClicked: modelPreviewer.footerClicked()
    }
}
