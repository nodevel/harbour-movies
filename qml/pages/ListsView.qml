import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: listsView
    allowedOrientations: Orientation.Landscape | Orientation.Portrait

    Component.onCompleted: {
        // Due to a limitation in the ListModel, translating its elements
        // must be done this way

        //: Shown as the title for the favorites menu entry
        listsModel.get(0).title = qsTr('Favorites')
        //: Shown as the subtitle for the favorites menu entry
        listsModel.get(0).subtitle = qsTr('Your favorite movies and celebrities')

        //: Shown as the title for the watchlist menu entry
        listsModel.get(1).title = qsTr('Watchlist')
        //: Shown as the subtitle for the watchlist menu entry
        listsModel.get(1).subtitle = qsTr('Movies you\'ve saved to watch later')

        coverChange(listsModel, "list")
    }

    property string headerText: ''

    ListModel {
        id: listsModel

        ListElement {
            title: 'Favorites'
            subtitle: 'Your favorite movies and celebrities'
            action: 0
        }

        ListElement {
            title: 'Watchlist'
            subtitle: 'Movies you\'ve saved to watch later'
            action: 1
        }
    }

    Component { id: favoritesView; FavoritesView { } }

    Column {
        anchors.fill: parent
        spacing: 100

        SilicaListView {
            id: list
            width: parent.width
            height: headerItem.height + listsModel.count * Theme.itemSizeMedium
            model: listsModel
            clip: true
            interactive: false
            delegate: MyListDelegate {
                width: parent.width
                title: model.title
                subtitle: model.subtitle

                onClicked: {
                    switch (action) {
                    case 0:
                        appWindow.pageStack.push(favoritesView, {
                                                     headerText: model.title,
                                                     state: 'favorites'
                                                 })
                        break;
                    case 1:
                        appWindow.pageStack.push(favoritesView, {
                                                     headerText: model.title,
                                                     state: 'watchlist'
                                                 })
                        break;
                    default:
                        console.debug('Action not available')
                        break
                    }
                }
            }
            header: PageHeader {
                title: headerText
            }
        }

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 360
            opacity: 0.5
            source: '../resources/icon-bg-cinema.png'
            fillMode: Image.PreserveAspectFit
        }
    }
}
