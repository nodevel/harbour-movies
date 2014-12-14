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

import '../js/moviesutils.js' as Util
import "../components"

Page {
    id: favoritesView
    allowedOrientations: Orientation.Landscape | Orientation.Portrait

    property bool holdsMixedContent: false
    property string moviePlaceholderIcon: '../resources/movie-placeholder.svg'
    property string personPlaceholderIcon: '../resources/person-placeholder.svg'
    property string headerText: ''

    ListModel {
        id: localModel
    }

    PageHeader {
        id: favoritesHeader
        title: headerText
    }

    GridView {
        id: favoritesGrid
        anchors {
            top: favoritesHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 30
            rightMargin: 30
        }
        clip: true
        cellWidth: 140
        cellHeight: 210

        model: localModel
        delegate: FavoriteDelegate {

            source: model.icon ?
                        model.icon :
                        (type == Util.PERSON ? personPlaceholderIcon : moviePlaceholderIcon)

            text: title
            onClicked: {
                var pageConfig = { tmdbId: id, loading: true }
                var thePage = movieView

                if (holdsMixedContent) {
                    if (type == Util.PERSON)
                        thePage = personView
                    else if (type == Util.TV)
                        thePage = tvView
                }

                appWindow.pageStack.push(thePage, pageConfig)
            }
        }
        VerticalScrollDecorator { flickable: favoritesGrid }
    }


    NoContentItem {
        id: noContentItem
        anchors {
            fill: parent
            margins: Theme.paddingLarge
        }
        visible: localModel.count == 0
    }

    function loadContent(loadFavorites) {
        localModel.clear()
        var content = []

        if (loadFavorites) {
            content = storage.getFavorites()
        } else {
            content = storage.getWatchlist()
        }

        for (var i = 0; i < content.length; i ++) {
            localModel.append(content[i])
        }
    }

    states: [
        State {
            name: 'watchlist'
            PropertyChanges {
                target: favoritesView
                holdsMixedContent: false
            }
            PropertyChanges {
                target: noContentItem
                //: Shown as a placeholder in the watchlist view, when empty
                text: qsTr('Movies in your watchlist will appear here')
            }
            StateChangeScript {
                script: loadContent(false)
            }
        },
        State {
            name: 'favorites'
            PropertyChanges {
                target: favoritesView
                holdsMixedContent: true
            }
            PropertyChanges {
                target: noContentItem
                text: qsTr('Your favorite content will appear here')
            }
            StateChangeScript {
                script: loadContent(true)
            }
        }

    ]
    Component.onCompleted: {
        coverChange(localModel, "list")
    }
}
