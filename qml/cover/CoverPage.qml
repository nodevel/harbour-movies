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

CoverBackground {
    property bool coverTypeBool: true // 1 for movie image, 0 for movie list
    property alias model: coverList.model
    property alias image: coverPic.source
    height: parent.height
    width: parent.width
    Image {
        id: coverPic
        visible: coverTypeBool
        anchors.fill: parent
        source: '../resources/movie-placeholder.svg'
    }
    SilicaListView {
        id: coverList
        visible: !coverTypeBool
        anchors.fill: parent
        model: coverModel
        delegate: Item {
            height: 40
            Label {
                x: Theme.paddingLarge
                text: name ? name : ''
                height: 40
                anchors.verticalCenter: parent.verticalCenter
                wrapMode: Text.WordWrap
                color: Theme.secondaryColor
                width: parent.width - 2*Theme.paddingLarge
            }
        }
    }

//    CoverActionList {
//        id: coverAction

//        CoverAction {
//            iconSource: "image://theme/icon-cover-next"
//        }

//        CoverAction {
//            iconSource: "image://theme/icon-cover-pause"
//        }
//    }
    states: [
        State {
            name: 'watchlist'
            PropertyChanges {
                target: favoritesView
                holdsMixedContent: false
            }
            PropertyChanges {
                target: noContentItem
                //: Shown as a placeholder in the watchlist view, when empty
                text: qsTr('Movies in your watchlist will appear here')
            }
            StateChangeScript {
                script: loadContent(false)
            }
        },
        State {
            name: 'favorites'
            PropertyChanges {
                target: favoritesView
                holdsMixedContent: true
            }
            PropertyChanges {
                target: noContentItem
                text: qsTr('Your favorite content will appear here')
            }
            StateChangeScript {
                script: loadContent(true)
            }
        }

    ]
}


