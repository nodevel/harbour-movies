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
import '../components'

import '../js/moviesutils.js' as Util
import '../js/moviedbwrapper.js' as TMDB

Page {
    id: welcomeView

    allowedOrientations: Orientation.Landscape | Orientation.Portrait

    Component.onCompleted: {
        storage.initialize()
        var favorites = storage.getFavorites()
        for (var i = 0; i < favorites.length; i ++) {
            favoritesModel.append(favorites[i])
        }

        // Due to a limitation in the ListModel, translating its elements
        // must be done this way

        //: Shown as the title for the browse view menu entry
        menuModel.get(0).title = qsTr('Movie genres')
        //: Shown as the subtitle for the browse view menu entry
        menuModel.get(0).subtitle = qsTr('Explore movie genres')

        //: Shown as the title for the showtimes menu entry
        menuModel.get(1).title = qsTr('Showtimes')
        //: Shown as the subtitle for the browse view menu entry
        menuModel.get(1).subtitle = qsTr('What\'s on in cinemas near you')

        //: Shown as the title for the search view menu entry
        menuModel.get(2).title = qsTr('Search')
        //: Shown as the subtitle for the search view menu entry
        menuModel.get(2).subtitle = qsTr('Search movies and celebrities')

        //: Shown as the title for the lists view menu entry
        menuModel.get(3).title = qsTr('Lists')
        //: Shown as the subtitle for the lists view menu entry
        menuModel.get(3).subtitle = qsTr('Favorites and watchlist')

        Util.asyncQuery({
                            url: TMDB.configuration_getUrl({ app_locale: appLocale }),
                            response_action: 0
                        },
                        handleMessage)
    }


    Component { id: browseView; GenresView { } }

    Component { id: searchView; SearchView { } }

    Component { id: showtimesView; TheatersView { } }

    Component { id: settingsView; SettingsView { } }

    Component { id: movieView; MovieView { } }

    Component { id: tvView; TvView { } }

    Component { id: personView; PersonView { } }

    Component { id: aboutView; AboutView { } }

    Component { id: listsView; ListsView { } }

    ListModel {
        id: menuModel

        ListElement {
            title: 'Movie genres'
            subtitle: 'Explore movie genres'
            action: 0
        }

        ListElement {
            title: 'Cinemas'
            subtitle: 'What\'s on cinemas near you'
            action: 1
        }

        ListElement {
            title: 'Search'
            subtitle: 'Search people, movies and shows'
            action: 2
        }

        ListElement {
            title: 'Lists'
            subtitle: 'Favorites, watchlists and others'
            action: 3
        }
    }
    SilicaFlickable {
        anchors.fill: parent

        pullDownMenu: welcomeMenu
        PullDownMenu {
            id: welcomeMenu
            MenuItem {
                //: Title for the about entry in the main page object menu
                text: qsTr("About")
                onClicked: appWindow.pageStack.push(aboutView)
            }
            MenuItem {
                //: Title for the settings entry in the main page object menu
                text: qsTr("Settings")
                onClicked: appWindow.pageStack.push(settingsView)
            }
        }
        SilicaGridView {
            id: list
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: cellWidth*(isLandscape ? 1 : 2) + headerItem.height
            width: parent.width
            cellWidth: welcomeView.width / (isLandscape ? 4 : 2)
            cellHeight: cellWidth
            model: menuModel
    //        clip: true
    //        interactive: false
            delegate: MyGridDelegate {
    //            width: parent.width
                title: model.title
                subtitle: model.subtitle
                height: width
                texture: true
                columnsPortrait: 2
                columnsLandscape: 4

                onClicked: {
                    switch (action) {
                    case 0:
                        appWindow.pageStack.push(browseView)
                        break;
                    case 1:
                        appWindow.pageStack.push(showtimesView)
                        break;
                    case 2:
                        appWindow.pageStack.push(searchView)
                        break;
                    case 3:
                        appWindow.pageStack.push(listsView, { headerText: model.title })
                        break;
                    default:
                        console.debug('Action not available')
                        break
                    }
                }
            }
            header: PageHeader {
                id: welcomeHeader
                //: Shown in the main view header
                title: qsTr('Enjoy the show!')
            }
        }

        Item {
            id: favorites
            anchors { top: list.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
            anchors {
                leftMargin: 30
                rightMargin: 30
            }

            ListModel {
                id: favoritesModel
            }

            GridView {
                id: view
                anchors.fill: parent
                clip: true
                cellWidth: 140
                cellHeight: 210

                model: favoritesModel
                delegate: FavoriteDelegate {
                    source: icon ? icon :
                                   (type == Util.MOVIE ?
                                        '../resources/movie-placeholder.svg' :
                                        '../resources/person-placeholder.svg')
                    text: title
                    onClicked: {
                        if (type == Util.MOVIE) {
                            appWindow.pageStack.push(movieView,
                                                     { tmdbId: id,
                                                       loading: true })
                        } else if (type == Util.TV) {
                            appWindow.pageStack.push(tvView,
                                                     { tmdbId: id,
                                                       loading: true })
                        } else {
                            appWindow.pageStack.push(personView,
                                                     { tmdbId: id,
                                                       loading: true })
                        }
                    }
                }
                VerticalScrollDecorator { flickable: view }
            }


            NoContentItem {
                anchors {
                    fill: parent
                    margins: Theme.paddingLarge
                }
                //: Shown as a placeholder in the favorites area of the main view while no favorites are there
                text: qsTr('Your favorite content will appear here')
                visible: favoritesModel.count == 0
            }
        }
    }

    function addFavorite(content) {
        var insertId = storage.saveFavorite(content)
        content.rowId = insertId
        favoritesModel.append(content)
    }

    function removeFavorite(content) {
        var idx = indexOf(content)
        removeFavoriteAt(idx)
    }

    function removeFavoriteAt(idx) {
        if (idx != -1) {
            var rowId = favoritesModel.get(idx).rowId
            favoritesModel.remove(idx)
            storage.removeFavorite(rowId)
        }
    }

    function indexOf(content) {
        for (var i = 0; i < favoritesModel.count; i ++) {
            if (favoritesModel.get(i).id == content.id &&
                    favoritesModel.get(i).type == content.type) {
                return i
            }
        }
        return -1
    }

    function handleMessage(messageObject) {
        var jsonResponse = JSON.parse(messageObject.response)
        if (jsonResponse.errors === undefined)
            TMDB.configuration_set(jsonResponse, { app_locale: appLocale })
    }
}
