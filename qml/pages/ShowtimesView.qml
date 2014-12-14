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
import "../components"
import QtQuick.XmlListModel 2.0
import org.nemomobile.dbus 1.0

Page {

    allowedOrientations: Orientation.Landscape | Orientation.Portrait

//    property alias showtimesModel: list.model
    property string cinemaName: ''
    property string cinemaInfo: ''
    property int theaterIndex

    SilicaListView {
        id: list
        anchors.fill: parent
        clip: true
        model: inTheaterModel
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
                text: qsTr("Show on map")
                onClicked: mapsInterface.search(cinemaInfo)
            }
        }
        header: Item {
            width: parent.width
            height: col.height + Theme.paddingLarge

            Column {
                id: col
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                PageHeader {
                    title: cinemaName
                }

                SearchField {
                    id: filter
                    width: parent.width
                    placeholderText: "Search in "+cinemaName

                    inputMethodHints: Qt.ImhNoPredictiveText
                    Timer {
                       id: filterTimer
                       interval:500
                       running: false
                       repeat: false

                       onTriggered: {
                           inTheaterModel.searchString = filter.text;
                       }
                    }
                    onTextChanged: {
                        if(filterTimer.running){
                            filterTimer.restart()
                        } else {
                            filterTimer.start()
                        }
                    }
                }
            }
        }
        delegate: MyListDelegate {
            width: parent.width
            title: name
            titleWraps: true
            subtitle: times
            subtitleSize: Theme.fontSizeSmall
            subtitleWraps: true

            onClicked: {
                if (imdb)
                    appWindow.pageStack.push(movieView, { imdbId: imdb, loading: true })
                else
                    appWindow.pageStack.push(searchView, { searchTerm: name })
            }
        }
        VerticalScrollDecorator { flickable: list }
    }

    XmlListModel {
        id: inTheaterModel
        xml: theatersList
        property string searchString: ''
        query: "/theaters/theater["+(theaterIndex+1)+"]/movies/movie[contains(lower-case(child::name),lower-case('"+searchString+"'))]"

        XmlRole { name: "name"; query: "name/string()" }
        XmlRole { name: "url"; query: "url/string()" }
        XmlRole { name: "info"; query: "info/string()" }
        XmlRole { name: "times"; query: "times/string()" }
        XmlRole { name: "imdb"; query: "imdb/string()" }
    }

    Component.onCompleted: {
        coverChange(inTheaterModel, "list")

        console.log(theatersList)
    }
    DBusInterface {
        id: mapsInterface
        destination: "org.sailfishos.maps"
        path: "/"
        iface: "org.sailfishos.maps"
        function search(searchText) {
            call('openSearch', searchText)
        }
    }
}
