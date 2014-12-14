/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.2
import 'js/moviedbwrapper.js' as TMDB
import "pages"
import "components"
import "cover"

ApplicationWindow
{
    id: appWindow
    initialPage: Component { WelcomeView { } }
    cover: coverPage
    CoverPage { id: coverPage }
    property string appLocale: "cs_CZ"
    property string appLang: "cs"
    property string currentLocation
    property int contentType: 0
    property int currentDay: 0
    property string theatersList
    property string moviesList
    property bool listLoading: true
    property alias coverModel: coverPage.model
    property alias coverImage: coverPage.image
    property alias coverType: coverPage.coverTypeBool
    property var theMovieDbTmp
    property bool enableKodi

    function coverChange(data, type) {
        if (type === "list") {
            coverModel = data
            coverType = false
        } else if (type === "image") {
            coverImage = data
            coverType = true
        }
    }

    WelcomeView { id: mainPage }
    Python {
        id: py

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('./py'));
//            TMDB.tmdbApiKey = tmdbApiKey
            importModule('tmdblib', function () {
                py.call('tmdblib.set_keys', [tmdbApiKey], function() {});
                }
            )
//            importModule('gmovies', function () {})
            storage.initialize()
            var enableKodiTmp = storage.getSetting('enableKodi', 'false')
            enableKodi = (enableKodiTmp === 'true')
        }
    }

//    XmlListModel {
//        id: theaterModel
////        source: "http://" + currentFeed
//        xml: theatersList
//        query: "/theaters/theater"

//        XmlRole { name: "name"; query: "name/string()" }
//        XmlRole { name: "url"; query: "url/string()" }
//        XmlRole { name: "info"; query: "info/string()" }
//        XmlRole { name: "playing"; query: "movie_times_str/string()" }
//    }
    Storage { id: storage }
    Data {id: data }
}


