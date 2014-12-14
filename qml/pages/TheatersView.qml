import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0

import "../js/moviesutils.js" as Util
import "../components"

Page {
    id: cinemasView
    allowedOrientations: Orientation.Landscape | Orientation.Portrait

    property string extendedSection: ''
    property string location
    property string daysAhead
    property bool showShowtimesFilter: false
    property real contentYPos: list.visibleArea.yPosition *
                                   Math.max(list.height, list.contentHeight)

    Component.onCompleted: {
        currentLocation = storage.getSetting('location', 'Los Angeles')
        refresh(contentType);
        coverChange(theaterModel, "list")
    }
    function refresh(contentTypeTmp) {
        listLoading = true;
        contentType = contentTypeTmp
        py.importModule('gmovies', function () {
            py.call('gmovies.parse', [currentLocation, currentDay, 0, contentType, appLang, 0, 0], function(result) {
                if (contentTypeTmp === 0) {
                    theatersList = result.toString()
                } else if (contentTypeTmp === 1) {
                    moviesList = result.toString()
                }
                listLoading = false;
            });
        });

    }
    SilicaListView {
        id: list
        model: (contentType == 0) ? theaterModel : moviesModel
        anchors.fill: parent
        header: InfoHeader {
            modelXml: theaterModel
            previewedField: 'name'
            xml: true
            title: currentLocation

            SearchField {
                id: filter
                width: parent.width
                placeholderText: "Search in "+currentLocation

                inputMethodHints: Qt.ImhNoPredictiveText
                Timer{
                   id: filterTimer
                   interval:500
                   running: false
                   repeat: false

                   onTriggered: {
                       theaterModel.searchString = filter.text;
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
        ViewPlaceholder {
            id: noTheaterResults
            text: (location ?
                       //: Message shown when no results are found for a given location
                       qsTr('No results for %1').arg(location) :
                       //: Message shown when no results are found for the automatic location
                       qsTr('No results for your location'))
            enabled: !listLoading * !list.count
        }
        pullDownMenu: pulleyMenu
        delegate: MyListDelegate {
            width: list.width
            title: name
            subtitle: info
//                subtitle: model.playing
            subtitleSize: Theme.fontSizeExtraSmall

            onClicked: {
                appWindow.pageStack.push(showtimesView,
                 {
                     cinemaName: name,
                     cinemaInfo: info,
                     theaterIndex: index
                 });
            }
        }
        BusyIndicator {
            anchors.centerIn: parent
            running: listLoading
        }
        PullDownMenu {
            id: pulleyMenu
            MenuItem {
                property int otherType: (contentType == 0 ) ? 1 : 0
                text: (contentType == 0 ) ? qsTr("Show Movies") : qsTr("Show Theaters")
                onClicked: {
                    refresh(otherType);
                }
            }
        }
        VerticalScrollDecorator {}
    }
    Component { id: showtimesView; ShowtimesView { } }

    XmlListModel {
        property string searchString: ''
        id: theaterModel
        xml: theatersList
        query: "/theaters/theater[contains(lower-case(child::name),lower-case('"+searchString+"'))]"

        XmlRole { name: "name"; query: "name/string()" }
        XmlRole { name: "url"; query: "url/string()" }
        XmlRole { name: "info"; query: "info/string()" }
    }
}
