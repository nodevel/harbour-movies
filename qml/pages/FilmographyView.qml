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
    id: filmographyView
    allowedOrientations: Orientation.Landscape | Orientation.Portrait

    property string personName: ''
    property ListModel filmographyModel

    SilicaListView {
        id: filmographyList
        anchors {
            fill: parent
        }
        model: filmographyModel
        header: PageHeader {
            //: This appears in the filmography view header
            title: qsTr('%1\'s filmography').arg(personName)
//            showDivider: false
        }
        delegate: MyListDelegate {
            width: filmographyList.width
            title: model.name +
                   (model.date ? ' (' + Util.getYearFromDate(model.date) + ')' : '')
            subtitle: model.subtitle
            iconSource: model.img ?
                            TMDB.image(TMDB.IMAGE_POSTER, 0, model.img, { app_locale: appLocale }) :
                            '../resources/movie-placeholder.svg'

            onClicked: {
                if (model.type === 'TMDbFilmographyMovie')
                    pageStack.push(movieView,
                                   {
                                       movie: model,
                                       loading: true
                                   })
                else

                    pageStack.push(tvView,
                                   {
                                       movie: model,
                                       loading: true
                                   })
            }
        }

        section.property: 'department'
        section.delegate: ListSectionDelegate { sectionName: section }
        VerticalScrollDecorator { flickable: filmographyList }
    }
    Component.onCompleted: {
        coverChange(filmographyModel, "list")
    }

}
