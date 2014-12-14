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
import "../components"

Page {

    allowedOrientations: Orientation.Landscape | Orientation.Portrait

    Component { id: multipleMovieView; MultipleMoviesView {  } }

    JSONListModel {
        id: genresModel
//        json: py.call_sync('tmdblib.genres_list', [], function(result) {return result});
//        source: TMDB.genres_list({ app_locale: appLocale })
        query: TMDB.query_path(TMDB.GENRES_LIST)
        Component.onCompleted: py.call('tmdblib.genres_list', [], function(result) {json = result})
    }

    SilicaGridView {
        model: genresModel.model
        id: list
        anchors.fill: parent
        cellWidth: list.width / (isLandscape ? 2 : 1)
        header: InfoHeader {
            modelSt: genresModel.model
            previewedField: 'name'
            //: This appears in the browse view header
            title: qsTr('Movie genres')
        }

        InfoBanner {
            flowModelXml: theaterModel
            width: parent.width
            previewedField: 'name'
        }
        delegate: MyGridDelegate {
            id: gridDelegate
            title: model.name

            onClicked: {
                pageStack.push(multipleMovieView ,
                               {genre: id, genreName: name})
            }
        }
    }

    VerticalScrollDecorator { flickable: list }

    BusyIndicator {
        id: busyIndicator
        visible: running
        running: genresModel.json === ""
        anchors.centerIn: parent
    }
    Component.onCompleted: {
        coverChange(genresModel.model, "list")
    }
}
