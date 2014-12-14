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
import '../js/moviedbwrapper.js' as TMDB
import "../components"

Page {
//    tools: ToolBarLayout {
//        ToolIcon {
//            iconId: 'toolbar-back'
//            onClicked: {
//                appWindow.pageStack.pop()
//            }
//        }
//        ToolIcon {
//            enabled: moviesModel.json !== ""
//            iconId: 'toolbar-refresh' + (enabled ? '' : '-dimmed')
//            anchors.horizontalCenter: parent.horizontalCenter
//            onClicked: {
//                var page = 1
//                var includeAll = storage.getSetting('includeAll', 'true')
//                var includeAdult = storage.getSetting('includeAdult', 'true')

//                if (moviesModel.page !== page) {
//                    localModel.clear()
//                    moviesModel.json = ''
//                    moviesModel.page = page
//                } else if (moviesModel.includeAll !== includeAll) {
//                    localModel.clear()
//                    moviesModel.json = ''
//                    moviesModel.includeAll = includeAll
//                } else if (moviesModel.includeAdult !== includeAdult) {
//                    localModel.clear()
//                    moviesModel.json = ''
//                    moviesModel.includeAdult = includeAdult
//                }
//            }
//        }
//        ToolIcon {
//            iconId: 'toolbar-settings'
//            onClicked: {
//                appWindow.pageStack.push(settingsView, { state: 'showBrowsingSection' })
//            }
//            anchors.right: parent.right
//        }
//    }
    allowedOrientations: Orientation.Landscape | Orientation.Portrait

    property string genre: ''
    property string genreName:  ''

    JSONListModel {
        id: moviesModel
        property int page: 1
        property string includeAll: storage.getSetting('includeAll', 'true')
        property string includeAdult: storage.getSetting('includeAdult', 'true')
//        source: TMDB.movie_browse(genre, {
//            app_locale: appLocale,
//            'page_value': page,
//            'includeAll_value': includeAll,
//            'includeAdult_value': includeAdult
//        })
        query: TMDB.query_path(TMDB.MOVIE_BROWSE)
        onJsonChanged: {
            Util.populateModelFromModel(model, localModel, Util.TMDBSearchresult)
        }
        Component.onCompleted: py.call('tmdblib.genres_movies', [genre], function(result) {json = result})
    }

    ListModel {
        id: localModel
    }

    Component { id: movieView; MovieView { } }

    SilicaGridView {
        id: list
        anchors.fill: parent
        model: localModel
        cellWidth: welcomeView.width / (isLandscape ? 2 : 1)
        cellHeight: isLandscape ? Theme.itemSizeLarge + 20 : Theme.itemSizeMedium*2
        delegate: MultipleMoviesDelegate {
            iconSource: model.img
            name: model.name
            rating: model.vote_avg
            votes: model.vote_cnt
            year: Util.getYearFromDate(model.date)

            onClicked: {
                pageStack.push(movieView,
                               {
                                   movie: localModel.get(index)
                               })
            }
        }

        header: InfoHeader {
            modelSt: localModel
            previewedField: 'name'
            //: This appears in the browse view header
            title: genreName
        }

        onMovementEnded: {
            if (atYEnd)
                moviesModel.page++
        }
        Component.onCompleted: {
            coverChange(localModel, "list")
        }
        BusyIndicator {
            id: busyIndicator
            visible: running
            running: moviesModel.json === ""
            anchors.centerIn: parent
        }
        VerticalScrollDecorator { flickable: list }
    }

    NoContentItem {
        id: noResults
        anchors {
            fill: parent
            margins: Theme.paddingLarge
        }
        //: When browsing movies, shown when no movies matched the browse criteria
        text: qsTr('No content found')
        visible: moviesModel.json !== "" &&
                 moviesModel.count === 0 &&
                 localModel.count === 0
    }

}
