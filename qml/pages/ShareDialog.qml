import QtQuick 2.0
import Sailfish.Silica 1.0
import '../js/moviesutils.js' as Util

Dialog {
    property string homepage
    property string imdbId
    property string url
    property string imdbUrl: Util.IMDB_BASE_URL + 'title/' + imdbId
    property string name
    property string year

    Column {
        spacing: Theme.paddingSmall
        anchors.centerIn: parent
        Button {
            //: This visits the The Movie Database page of this content (movie or person)
            text: qsTr('View in TMDb')
            onClicked: Qt.openUrlExternally(url)
        }
        Button {
            //: This visits the Internet Movie Database page of this content (movie or person)
            text: qsTr('View in IMDb')
            onClicked: Qt.openUrlExternally(imdbUrl)
        }
        Button {
            //: This opens a website displaying the movie homepage
            text: qsTr('Open homepage')
            visible: homepage
            onClicked: Qt.openUrlExternally(homepage)
        }
        Button {
            //: This plays the movie in Kodi
            text: qsTr('Play in Kodi')
            visible: enableKodi
            onClicked: {
                if (enableKodi) {
                    var kodiIpTmp = storage.getSetting('kodiIp', '')
                    var kodiPortTmp = storage.getSetting('kodiPort', '')
                    var kodiUsernameTmp = storage.getSetting('kodiUsername', '')
                    var kodiPasswordTmp = storage.getSetting('kodiPassword', '')
                    var kodi_address = kodiUsernameTmp+":"+kodiPasswordTmp+"@"+kodiIpTmp+":"+kodiPortTmp
                    var http = new XMLHttpRequest()
                    var url = "http://" + kodi_address + "/jsonrpc";
                    var name_adj = name.split(' ').join('+');
                    var video_url = "pl
ugin://plugin.video.genesis/?action=play&name="+name_adj+"+%28"+year+"%29&title="+name_adj+"&year="+year+"&imdb="+imdbId+"&url="+imdbUrl
                    var params = '{"jsonrpc": "2.0", "method": "Player.Open", "params":{ "item": {"file" : "' + video_url + '" }}, "id" : 1}';
                    http.open("POST", url, true);

                    http.setRequestHeader("Content-type", "application/json");
                    http.setRequestHeader("Content-length", params.length);
                    http.setRequestHeader("Connection", "close");

                    http.onreadystatechange = function() {
                                if (http.readyState == 4) {
                                    if (http.status == 200) {
                                        console.log("ok")
                                    } else {
                                        console.log("error: " + http.status)
                                    }
                                }
                            }
                    http.send(params);
                }
            }
        }
    }
}
