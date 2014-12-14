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
    id: personView

    allowedOrientations: Orientation.Landscape | Orientation.Portrait

//    tools: MoviesToolBar {
//        content: ({
//                      id: parsedPerson.tmdbId,
//                      url: parsedPerson.url,
//                      title: parsedPerson.name,
//                      icon: parsedPerson.profile,
//                      type: Util.PERSON
//                  })
//        isFavorite: welcomeView.indexOf({
//                                            id: tmdbId,
//                                            type: Util.PERSON
//                                        }) >= 0
//        menu: personMenu
//    }

//    Menu {
//        id: personMenu
//        visualParent: pageStack
//        MenuLayout {
//            MenuItem {
//                text: qsTr('View in IMDb')
//                onClicked: Qt.openUrlExternally(Util.IMDB_BASE_URL + 'name/' + parsedPerson.imdbId)
//            }
//            MenuItem {
//                text: qsTr('View in TMDb')
//                onClicked: Qt.openUrlExternally(parsedPerson.url)
//            }
//        }
//    }

    property variant person: ''
    property alias tmdbId: parsedPerson.tmdbId
    property bool loading: false
    property bool loadingExtended: false

    QtObject {
        id: parsedPerson

        // Part of the lightweight person
        property string tmdbId: ''
        property string name: ''
        property string profile: '../resources/person-placeholder.svg'
        property string url: '' // implicit: base url + person id
        // also available: popularity

        // Part of the full person object
        property string birthday: ''
        property string birthplace: ''
        property string biography: ''
        property string imdbId: ''
        // also available: adult, also_known_as, deathday, homepage

        // parses TMDBObject
        function updateWithLightWeightPerson(person) {
            tmdbId = person.id
            name = person.name
            url = 'http://www.themoviedb.org/person/' + tmdbId
            if (person.img)
                profile = TMDB.image(TMDB.IMAGE_PROFILE, 1,
                                     person.img, { app_locale: appLocale })
        }

        // parses JSON response
        function updateWithFullWeightPerson(person) {
            name = person.name
            url = 'http://www.themoviedb.org/person/' + tmdbId
            if (person.profile_path)
                profile = TMDB.image(TMDB.IMAGE_PROFILE, 1,
                                     person.profile_path, { app_locale: appLocale })
            if (person.biography)
                biography = person.biography
            if (person.birthday)
                birthday = person.birthday
            if (person.place_of_birth)
                birthplace = person.place_of_birth
            if (person.imdb_id)
                imdbId = person.imdb_id

            var credits = new Array()
            py.call('tmdblib.people_movie_credits', [person.id], function(result) {
                Util.populateArrayFromArray(result.cast, credits, Util.TMDbFilmographyMovie)
                Util.populateArrayFromArray(result.crew, credits, Util.TMDbFilmographyMovie)
                py.call('tmdblib.people_tv_credits', [person.id], function(result) {
                    Util.populateArrayFromArray(result.cast, credits, Util.TMDbFilmographyTv)
                    Util.populateArrayFromArray(result.crew, credits, Util.TMDbFilmographyTv)
                    credits.sort(sortByDepartmentAndDate)
                    Util.populateModelFromArray(credits, filmographyModel)
                })
            });

            py.call('tmdblib.people_images', [person.id], function(result) {
                Util.populateModelFromArray(result.profiles, picturesModel)
            })
        }

        function sortByDate(oneItem, theOther) {
            var oneDate = Util.getDateFromString(oneItem.date)
            var theOtherDate = Util.getDateFromString(theOther.date)

            return (oneDate > theOtherDate ? -1 : 1)
        }

        function sortByDepartmentAndDate(oneItem, theOther) {
            var result = oneItem.department.localeCompare(theOther.department)
            if (result !== 0) {
                // pull directors and writers to the top
                if (oneItem.department === 'Directing')
                    return -1
                else if (theOther.department === 'Directing')
                    return 1
                else if (oneItem.department === 'Writing')
                    return -1
                else if (theOther.department === 'Writing')
                    return 1
            } else {
                result = sortByDate(oneItem, theOther)
            }

            return result
        }
    }

    ListModel {
        id: filmographyModel
    }

    ListModel {
        id: picturesModel
    }

    Component {
        id: galleryView

        MediaGalleryView {
            imgType: TMDB.IMAGE_PROFILE
            gridSize: 1
            fullSize: 2
            saveSize: 100
        }
    }

    Component { id: filmographyView; FilmographyView { } }

    Component.onCompleted: {
        if (person)
            parsedPerson.updateWithLightWeightPerson(person)
            py.call('tmdblib.people_info', [person.id], function(result) {
                parsedMovie.updateWithFullWeightPerson(result)
                coverChange(filmographyModel, "list")
            })

//        if (tmdbId)
//            fetchExtendedContent()


    }

    function fetchExtendedContent() {
        loadingExtended = true
        Util.asyncQuery({
                            url: TMDB.person_info(tmdbId, 'movie_credits,tv_credits,images', { app_locale: appLocale }),
                            response_action: Util.FETCH_RESPONSE_TMDB_PERSON
                        },
                        handleMessage)
    }

    SilicaFlickable {
        id: personFlickableWrapper

        anchors {
            fill: parent
            margins: Theme.paddingLarge
        }
        contentHeight: personContent.height
        visible: !loading

        Column {
            id: personContent
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: parsedPerson.name
            }

            Label {
                id: extendedContentLabel
                text: qsTr('Loading content')
                visible: loadingExtended
                anchors.horizontalCenter: parent.horizontalCenter

                BusyIndicator {
                    visible: running
                    running: loadingExtended
                    anchors {
                        left: extendedContentLabel.right
                        leftMargin: Theme.paddingLarge
                        verticalCenter: extendedContentLabel.verticalCenter
                    }
                }
            }

            Row {
                id: row
                width: parent.width

                Image {
                    id: image
                    width: 160
                    height: 236
                    source: parsedPerson.profile
                    fillMode: Image.PreserveAspectFit
                }

                Column {
                    width: parent.width - image.width

                    MyEntryHeader {
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: Theme.paddingLarge
                        }
                        headerFontSize: Theme.fontSizeLarge
                        text: parsedPerson.name
                    }

                    Item {
                        height: Theme.paddingLarge
                        width: parent.width
                    }

                    MyEntryHeader {
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: Theme.paddingLarge
                        }
                        visible: parsedPerson.birthday
                        //: Header shown for the born details of a person
                        text: qsTr('Born')
                    }

                    Label {
                        id: birthdayLabel
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: Theme.paddingLarge
                        }
                        wrapMode: Text.WordWrap
                        text: Qt.formatDate(Util.parseDate(parsedPerson.birthday), Qt.DefaultLocaleLongDate)
                    }

                    Label {
                        id: birthplaceLabel
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: Theme.paddingLarge
                        }
                        wrapMode: Text.WordWrap
                        text: parsedPerson.birthplace
                    }

                    Item {
                        height: Theme.paddingLarge
                        width: parent.width
                    }

                    Label {
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: Theme.paddingLarge
                        }
                        wrapMode: Text.WordWrap
                        text: qsTr('Known for %Ln movie(s)',
                                   'Text shown in the person view displaying the number of movies a person is known for',
                                   filmographyModel.count)
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.secondaryColor
            }

            MyGalleryPreviewer {
                width: parent.width

                galleryPreviewerModel: picturesModel
                previewerDelegateType: TMDB.IMAGE_PROFILE
                visible: picturesModel.count > 0

                onClicked: {
                    appWindow.pageStack.push(galleryView, { galleryViewModel: picturesModel })
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.secondaryColor
                visible: picturesModel.count > 0
            }

            MyTextExpander {
                width: parent.width
                visible: parsedPerson.biography
                //: Label acting as the header for the biography
                textHeader: qsTr('Biography')
                textContent: parsedPerson.biography
            }

            MyModelPreviewer {
                width: parent.width
                previewedModel: filmographyModel
                previewerHeaderText:
                    //: Header for the filmography preview shown in the person view
                    qsTr('Filmography')
                previewerDelegateTitle: 'name'
                previewerDelegateSubtitle: 'subtitle'
                previewerDelegateIcon: 'img'
                previewerDelegatePlaceholder: '../resources/movie-placeholder.svg'
                previewerFooterText:
                    //: Footer for the filmography preview shown in the person view. When clicked, shows the full filmography
                    qsTr('Full filmography')
                visible: filmographyModel.count > 0

                onClicked: {
                    if (filmographyModel.get(modelIndex).type === 'TMDbFilmographyMovie')
                        appWindow.pageStack.push(movieView,
                                                 {
                                                     movie: filmographyModel.get(modelIndex),
                                                     loading: true
                                                 })
                    else
                        appWindow.pageStack.push(tvView,
                                                 {
                                                     movie: filmographyModel.get(modelIndex),
                                                     loading: true
                                                 })
                }

                onFooterClicked: {
                    appWindow.pageStack.push(filmographyView,
                                             {
                                                 personName: parsedPerson.name,
                                                 filmographyModel: filmographyModel
                                             })
                }
            }
        }
        VerticalScrollDecorator { flickable: personFlickableWrapper }
    }


    function handleMessage(messageObject) {
        var objectArray = JSON.parse(messageObject.response)
        if (objectArray.errors !== undefined) {
            console.debug("Error parsing JSON: " + objectArray.errors[0].message)
            return
        }

        if (messageObject.action === Util.FETCH_RESPONSE_TMDB_PERSON) {
            parsedPerson.updateWithFullWeightPerson(objectArray)
            loading = loadingExtended = false
        } else {
            console.debug('Unknown action response: ', messageObject.action)
        }
    }

    BusyIndicator {
        id: personBusyIndicator
        anchors.centerIn: parent
        visible: running
        running: loading
    }
}
