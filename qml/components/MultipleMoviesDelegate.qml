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

BackgroundItem {
    id: movieDelegate

    property string iconSource: ''
    property string placeholderSource: '../resources/movie-placeholder.svg'
    property string name: ''
    property string year: ''
    property double rating: 0
    property int votes: 0
    property bool grid: false

    anchors {
        leftMargin: Theme.paddingLarge
        rightMargin: Theme.paddingLarge
    }

    width: GridView.view.cellWidth
    height: GridView.view.cellHeight


    Row {
        id: content
        spacing: 15
        anchors {
            top: parent.top
            topMargin: Theme.paddingLarge / 2
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge / 2
            right: parent.right
            rightMargin: Theme.paddingLarge
            left: parent.left
        }

        Image {
            id: moviePoster
            width: 95
            height: 140
            fillMode: Image.PreserveAspectFit
            source: iconSource ?
                        TMDB.image(TMDB.IMAGE_POSTER, 0, iconSource, { app_locale: appLocale }) :
                        placeholderSource
            onStatusChanged: {
                if (moviePoster.status == Image.Error) {
                    moviePoster.source = placeholderSource
                }
            }
        }

        Column {
            width: parent.width - moviePoster.width - 15
            height: parent.height
            spacing: 10

            Label {
                id: titleText
                color: Theme.primaryColor
                width: parent.width
                elide: Text.ElideRight
                textFormat: Text.StyledText
                maximumLineCount: 2
                wrapMode: Text.WordWrap
                text: name
            }

            Label {
                id: yearText
                color: Theme.secondaryColor
                width: parent.width
                text: '(%1)'.arg(year)
            }

            MyRatingIndicator {
                height: Theme.iconSizeSmall
                ratingValue: rating / 2
                maximumValue: 5
                count: votes
            }
        }
    }
}
