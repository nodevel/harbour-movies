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
import '../js/youtube.js' as YT
import "../components"

Page {
    id: movieView

    allowedOrientations: Orientation.Landscape | Orientation.Portrait

    property variant movie: ''
    property var movieObj
    property alias tmdbId: parsedMovie.tmdbId
    property alias imdbId: parsedMovie.imdbId
    property bool loading: false
    property bool loadingExtended: false
    property bool inWatchlist: tmdbId ? storage.inWatchlist({ 'id': tmdbId }) : false

    QtObject {
        id: parsedMovie

        // Part of the lightweight movie object
        property string tmdbId: ''
        property string name: ''
        property string poster: '../resources/movie-placeholder.svg'
        property string backdrop: '../resources/movie-placeholder.svg'
        property string url: '' // implicit: base url + movie id
        // also available: backdrop, adult, popularity

        // Part of the full movie object
        property string originalName: ''
        property string released: ''
        property double rating: 0
        property int votes: 0
        property string imdbId: ''
        property string overview: ''
        property string tagline: ''
        property string trailer: ''
        property string revenue: ''
        property string budget: ''
        property int runtime: 0
        property string certification: '-'
        property string homepage: ''
        property string trailervideo: ''
        property string trailerthumb: ''
        // also available: belongs_to_collection, spoken_languages, status

        // parses TMDBObject
        function updateWithLightWeightMovie(movie) {
            tmdbId = movie.id
            name = movie.name
            url = 'http://www.themoviedb.org/movie/' + tmdbId
            if (movie.img)
                poster = TMDB.image(TMDB.IMAGE_POSTER, 2, movie.img, { app_locale: appLocale });
                backdrop = TMDB.image(TMDB.IMAGE_BACKDROP, 2, movie.img, { app_locale: appLocale });
                console.log(backdrop)
        }

        // parses JSON response
        function updateWithFullWeightMovie(movie) {
            name = movie.title
            url = 'http://www.themoviedb.org/movie/' + tmdbId
            if (movie.poster_path)
                poster = TMDB.image(TMDB.IMAGE_POSTER, 2,
                                    movie.poster_path, { app_locale: appLocale })
            if (movie.original_title)
                originalName = movie.original_title
            if (movie.release_date)
                released = movie.release_date
            if (movie.vote_average)
                rating = movie.vote_average
            if (movie.vote_count)
                votes = movie.vote_count
            if (movie.imdb_id)
                imdbId = movie.imdb_id
            if (movie.overview)
                overview = movie.overview
//            if (movie.trailers.youtube[0] && movie.trailers.youtube[0].source) // can't deal with quicktime
//                trailer = 'http://www.youtube.com/watch?v=' + movie.trailers.youtube[0].source
//                YT.getVideoThumbnailAndLink(data, movie.trailers.youtube[0].source, function(thumb, rstpLink) {
//                        trailerthumb = thumb;
//                        trailervideo = rstpLink;
//                        console.log(trailervideo)
//                    })
            if (movie.homepage)
                homepage = movie.homepage
            if (movie.revenue)
                revenue = movie.revenue
            if (movie.budget)
                budget = movie.budget
            if (movie.tagline)
                tagline = movie.tagline
            if (movie.runtime)
                runtime = movie.runtime
            py.call('tmdblib.movies_alternative_titles', [movie.id], function(result) {
                Util.populateModelFromArray(result.titles, altTitlesModel)
            });
            Util.populateModelFromArray(movie.genres, genresModel)
            Util.populateModelFromArray(movie.production_companies, studiosModel)
            py.call('tmdblib.movies_images', [movie.id], function(result) {
                Util.populateModelFromArray(result.posters, postersModel)
                Util.populateModelFromArray(result.backdrops, backdropsModel)
            });

            py.call('tmdblib.movies_releases', [movie.id], function(result) {
                for (var i = 0; i < result['countries'].length; i++)
                    if (movie.releases.countries[i].iso_3166_1 == appLocale.toUpperCase())
                        certification = result.countries[i].certification
            });
            py.call('tmdblib.movies_credits', [movie.id], function(result) {
                console.log(result)
                var cast = new Array()
                Util.populateArrayFromArray(result.cast, cast, Util.TMDbCredit)
                cast.sort(sortByCastId)
                Util.populateModelFromArray(cast, castModel)

                var crew = new Array()
                Util.populateArrayFromArray(result.crew, crew, Util.TMDbCredit)
                crew.sort(sortByDepartmentAndCastId)
                Util.populateModelFromArray(crew, crewModel)

                Util.populateModelFromArray(crew, creditsModel)
                Util.populateModelFromArray(cast, creditsModel)
            })



        }
    }

    function sortByCastId(oneItem, theOther) {
        return oneItem.cast_id - theOther.cast_id
    }

    function sortByDepartmentAndCastId(oneItem, theOther) {
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
            result = sortByCastId(oneItem, theOther)
        }
        return result
    }

    Component.onCompleted: {
        if (movie) {
            parsedMovie.updateWithLightWeightMovie(movie)
            py.call('tmdblib.movies_info', [movie.id], function(result) {
                parsedMovie.updateWithFullWeightMovie(result)
            })
        }

//        if (tmdbId)
//            fetchExtendedContent(TMDB.movie_info(tmdbId,
//                             'alternative_titles,credits,images,trailers,releases',
//                             { app_locale: appLocale }),
//             Util.FETCH_RESPONSE_TMDB_MOVIE)
        coverChange(parsedMovie.poster, "image")
    }

    // Several ListModels are used.
    // * Genres stores the genres / categories which best describe the movie. When
    //   browsing by genre, the movie will have at least the genre we were navigating
    // * Studios stores the company which produced the film
    // * Posters stores all the poster images for this particular film. By using the
    //   resolutions in the API configuration, all quality levels can be accessed
    // * Backdrops stores all the backdrop images for this particular film. By using the
    //   resolutions in the API configuration, all quality levels can be accessed
    // * Cast and crew are separated from each other, so we can be more specific
    //   in the movie preview
    // * AltTitles stores the alternative titles of the film

    ListModel {
        id: genresModel
    }

    ListModel {
        id: studiosModel
    }

    ListModel {
        id: postersModel
    }

    ListModel {
        id: backdropsModel
    }

    ListModel {
        id: creditsModel
    }

    ListModel {
        id: castModel
    }

    ListModel {
        id: crewModel
    }

    ListModel {
        id: altTitlesModel
    }

    Component {
        id: galleryView

        MediaGalleryView {
            gridSize: 0
            saveSize: 100
        }
    }

    Component { id: castView; CastView { } }

    SilicaFlickable {
        id: movieFlickableWrapper
        anchors {
            fill: parent
//            margins: Theme.paddingLarge
        }
        contentHeight: movieContent.height
        visible: !loading

        pullDownMenu: movieMenu
        PullDownMenu {
            id: movieMenu
            MenuItem {
                //: Shares the item
                text: qsTr('Share')
                onClicked: {
                    var dialog = pageStack.push("ShareDialog.qml", {"homepage": parsedMovie.homepage, "imdbId": parsedMovie.imdbId, 'url': parsedMovie.url, 'name': parsedMovie.name, 'year': Util.getYearFromDate(parsedMovie.released)})
                    dialog.accepted.connect(function() {
                        Qt.openUrlExternally(parsedMovie.url)
                    })
                }
            }
            MenuItem {
             //   //: Title for the about entry in the main page object menu
//                enabled: !movieView.loading
                text: !inWatchlist ?
                          //: This adds the movie to the watch list
                          qsTr('Add to watchlist') :
                          //: This removes the movie from the watch list
                          qsTr('Remove from watchlist')
                onClicked: {
                    if (inWatchlist) {
                        storage.removeFromWatchlist({
                            'id': tmdbId
                        })
                    } else {
                        storage.addToWatchlist({
                           'id': tmdbId,
                           'name': parsedMovie.name,
                           'year': Util.getYearFromDate(parsedMovie.released),
                           'iconSource': parsedMovie.poster,
                           'rating': parsedMovie.rating,
                           'votes': parsedMovie.votes
                       })
                    }
                }
            }
        }
        Column {
            id: movieContent
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
//                title: parsedMovie.name
                height: Theme.itemSizeLarge * 2

                Image {
                    id: backdropImg
                    width: parent.width
                    source: parsedMovie.backdrop
                    height: parent.width
                    clip: true
                    fillMode: Image.PreserveAspectCrop
                }
                OpacityRampEffect {
                    sourceItem: backdropImg
                    direction: OpacityRamp.TopToBottom
                    slope: 2
                    }
                Rectangle {
                    height: Theme.itemSizeLarge
                    width: Theme.itemSizeLarge
                    color: Theme.secondaryHighlightColor
                    radius: Theme.paddingSmall
                    anchors {
                        top: parent.top
                        right: parent.right
                        margins: Theme.paddingLarge
                    }

                    Text {
                        anchors.centerIn: parent
                        text: parsedMovie.rating.toFixed(1)
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeExtraLarge
                        font.bold: true
                    }
                }
            }

            Label {
                id: extendedContentLabel
                //: This indicates that the extended info for a content (person or movie) is still loading
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
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2*Theme.paddingLarge
                height: image.paintedHeight
                radius: Theme.paddingSmall
                color: Theme.secondaryHighlightColor
                Row {
                    id: row
                    width: parent.width
                    BackgroundItem {
                        width: image.width
                        height: image.height
                        Image {
                            id: image
                            anchors.fill: parent
                            width: 160
                            height: 236
                            source: parsedMovie.poster
                            fillMode: Image.PreserveAspectFit
                        }
                        onClicked: {
                            appWindow.pageStack.push(galleryView,
                             {
                                 galleryViewModel: postersModel,
                                 imgType: TMDB.IMAGE_POSTER,
                                 fullSize: 3
                             })
                        }
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
                            text: parsedMovie.originalName +
                                  (parsedMovie.released ? ' (' + Util.getYearFromDate(parsedMovie.released) + ')' : '')
                        }

                        Label {
                            id: ratedAndRuntimeLabel
                            anchors {
                                left: parent.left
                                right: parent.right
                                margins: Theme.paddingLarge
                            }
                            wrapMode: Text.WordWrap
                            //: This shows the classification of a movie and its runtime (duration)
                            text: qsTr('Rated %1, %2').arg(parsedMovie.certification).arg(Util.parseRuntime(parsedMovie.runtime))
                        }

                        Item {
                            height: Theme.paddingLarge
                            width: parent.width
                        }

                        Label {
                            id: taglineLabel
                            anchors {
                                left: parent.left
                                right: parent.right
                                margins: Theme.paddingLarge
                            }
                            font.italic: true
                            wrapMode: Text.WordWrap
                            text: parsedMovie.tagline
                        }
                    }
                }
            }

            Row {
                id: movieRatingSection

                Label {
                    id: ratingLabel
                    text: parsedMovie.rating.toFixed(1)
                }

                Label {
                    anchors.verticalCenter: ratingLabel.verticalCenter
                    color: Theme.secondaryColor
                    text: '/10'
                }

                Item {
                    height: Theme.paddingLarge
                    width: Theme.paddingLarge
                }

                MyRatingIndicator {
                    anchors.verticalCenter: ratingLabel.verticalCenter
                    ratingValue: parsedMovie.rating
                    maximumValue: 10
                    count: parsedMovie.votes
                }
            }

            MyTextExpander {
                width: parent.width
                visible: parsedMovie.overview
                //: Label acting as the header for the overview
                textHeader: qsTr('Overview')

                textContent: parsedMovie.overview
            }

            Column {
                width: parent.width

                MyGalleryPreviewer {
                    width: parent.width

                    galleryPreviewerModel: backdropsModel
                    previewerDelegateType: TMDB.IMAGE_BACKDROP
                    previewedItems: 3
//                    previewerDelegateIconWidth: 92 * 2
                    visible: backdropsModel.count

                    onClicked: {
                        appWindow.pageStack.push(galleryView,
                                                 {
                                                     galleryViewModel: backdropsModel,
                                                     imgType: TMDB.IMAGE_BACKDROP,
                                                     fullSize: 1
                                                 })
                    }
                }


                MyListDelegate {
                    width: parent.width
                    //: Opens the movie trailer for viewing
                    title: qsTr('Watch trailer')
                    titleSize: Theme.fontSizeLarge

                    iconSource: parsedMovie.trailerthumb ? parsedMovie.trailerthumb : "image://theme/icon-cover-play"
                    visible: parsedMovie.trailer

                    onClicked: parsedMovie.trailervideo ? Qt.openUrlExternally(parsedMovie.trailervideo) : Qt.openUrlExternally(parsedMovie.trailer)
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.secondaryColor
                    visible: parsedMovie.trailer
                }
            }
            Column {
                id: movieReleasedSection
                width: parent.width

                SectionHeader {
                    //: Label acting as the header for the release date
                    text: qsTr('Release date')
                }

                Label {
                    id: release
                    width: parent.width
                    text: Qt.formatDate(Util.parseDate(parsedMovie.released), Qt.DefaultLocaleLongDate)
                }
            }

            Column {
                id: movieGenresSection
                width: parent.width
                visible: genresModel.count > 0

                SectionHeader {
                    //: Label acting as the header for the genres
                    text: qsTr('Genre')
                }

                MyModelFlowPreviewer {
                    width: parent.width
                    flowModel: genresModel
                    previewedField: 'name'
                }
            }

            Column {
                id: movieAltTitlesSection
                width: parent.width
                visible: altTitlesModel.count > 0

                SectionHeader {
                    //: Label acting as the header for the alternative titles
                    text: qsTr('Alternative titles')
                }

                MyModelFlowPreviewer {
                    width: parent.width
                    flowModel: altTitlesModel
                    previewedField: 'title'
                }
            }

            Column {
                id: movieStudiosSection
                width: parent.width
                visible: studiosModel.count > 0

                SectionHeader {
                    //: Label acting as the header for the studios
                    text: qsTr('Studios')
                }

                MyModelFlowPreviewer {
                    width: parent.width
                    flowModel: studiosModel
                    previewedField: 'name'
                }
            }

            Column {
                id: movieBudgetSection
                width: parent.width
                visible: parsedMovie.budget

                SectionHeader {
                    //: Label acting as the header for the movie budget
                    text: qsTr('Budget')
                }


                Label {
                    width: parent.width
//                    text: controller.formatCurrency(parsedMovie.budget)
                    text:parsedMovie.budget
                }
            }

            Column {
                id: movieRevenueSection
                width: parent.width
                visible: parsedMovie.revenue

                SectionHeader {
                    //: Label acting as the header for the movie revenue
                    text: qsTr('Revenue')
                }

                Label {
                    width: parent.width
//                    text: controller.formatCurrency(parsedMovie.revenue)
                    text: parsedMovie.revenue
                }
            }

            MyModelPreviewer {
                width: parent.width
                previewedModel: castModel
                previewerHeaderText:
                    //: Header for the cast preview shown in the movie view
                    qsTr('Cast')
                previewerDelegateTitle: 'name'
                previewerDelegateSubtitle: 'subtitle'
                previewerDelegateIcon: 'img'
                previewerDelegatePlaceholder: '../resources/person-placeholder.svg'
                previewerFooterText:
                    //: Footer for the cast preview shown in the movie view. When clicked, shows the full cast.
                    qsTr('Full cast')
                visible: castModel.count > 0

                onClicked: {
                    appWindow.pageStack.push(personView,
                                             {
                                                 person: castModel.get(modelIndex),
                                                 loading: true
                                             })
                }
                onFooterClicked: {
                    appWindow.pageStack.push(castView,
                                             {
                                                 movieName: parsedMovie.name,
                                                 castModel: castModel
                                             })
                }
            }

            MyModelPreviewer {
                width: parent.width
                previewedModel: crewModel
                previewerHeaderText:
                    //: Header for the crew preview shown in the movie view
                    qsTr('Crew')
                previewerDelegateTitle: 'name'
                previewerDelegateSubtitle: 'subtitle'
                previewerDelegateIcon: 'img'
                previewerDelegatePlaceholder: '../resources/person-placeholder.svg'
                previewerFooterText:
                    //: Footer for the crew preview shown in the movie view. When clicked, shows the full cast and crew.
                    qsTr('Full cast & crew')
                visible: crewModel.count > 0

                onClicked: {
                    appWindow.pageStack.push(personView,
                                             {
                                                 person: crewModel.get(modelIndex),
                                                 loading: true
                                             })
                }
                onFooterClicked: {
                    appWindow.pageStack.push(castView,
                                             {
                                                 movieName: parsedMovie.name,
                                                 castModel: creditsModel,
                                                 showsCast: false
                                             })
                }
            }
        }
        VerticalScrollDecorator { flickable: movieFlickableWrapper }
    }


    function fetchExtendedContent(contentUrl, action) {
        loadingExtended = true
        Util.asyncQuery({
                            url: contentUrl,
                            response_action: action
                        },
                        handleMessage)
    }

    function handleMessage(messageObject) {
        var objectArray = JSON.parse(messageObject.response)
        if (objectArray.errors !== undefined) {
            console.debug("Error parsing JSON: " + objectArray.errors[0].message)
            return
        }

        switch (messageObject.action) {
        case Util.FETCH_RESPONSE_TMDB_MOVIE:
            parsedMovie.updateWithFullWeightMovie(objectArray)
            loading = loadingExtended = false
            break

        default:
            console.debug('Unknown action response: ', messageObject.action)
            break
        }
    }

    BusyIndicator {
        id: movieBusyIndicator
        anchors.centerIn: parent
        visible: running
        running: loading
    }
}
