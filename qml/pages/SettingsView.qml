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

Dialog {
    allowedOrientations: Orientation.Landscape | Orientation.Portrait
    property string showtimesDateTmp
    property alias locationTmp: locationInput.text
    property alias includeAllTmp: includeAllSwitch.checked
    property alias includeAdultTmp: includeAdultSwitch.checked
    property alias enableKodiTmp: kodiSwitch.checked
    property alias kodiIpTmp: kodiIpInput.text
    property alias kodiPortTmp: kodiPortInput.text
    property alias kodiUsernameTmp: kodiUsernameInput.text
    property alias kodiPasswordTmp: kodiPasswordInput.text

    Component.onCompleted: {
        storage.initialize()
        var includeAll = storage.getSetting('includeAll', 'true')
        var includeAdult = storage.getSetting('includeAdult', 'true')
        var date = new Date(storage.getSetting('showtimesDate', new Date().toString()))

        includeAllSwitch.checked = (includeAll === 'true')
        includeAdultSwitch.checked = (includeAdult === 'true')
        if (date < new Date())
            date = new Date() // now
        setDate(date)
        showtimesDateTmp = date.toString()

        var enableKodiVar = storage.getSetting('enableKodi', 'false')
        kodiSwitch.checked = (enableKodiVar === 'true')

        kodiIpTmp = storage.getSetting('kodiIp', '')
        kodiPortTmp = storage.getSetting('kodiPort', '')
        kodiUsernameTmp = storage.getSetting('kodiUsername', '')
        kodiPasswordTmp = storage.getSetting('kodiPassword', '')
    }

    SilicaFlickable {
        id: settingsContent
        anchors {
            fill: parent
        }
        width: parent.width
        contentHeight: settingsColumnContent.height



        Column {
            id: settingsColumnContent
            width: parent.width
            spacing: Theme.paddingLarge
            DialogHeader {
                acceptText: qsTr('Save')
                cancelText: qsTr('Cancel')
                title: qsTr('Settings')
            }

            SectionHeader {
                id: showtimesSectionHeader
                //: Label for the showtimes section in the settings view
                text: qsTr('Showtimes')
            }

            Row {
                id: showtimesLocation
                spacing: Theme.paddingLarge
                width: parent.width

                Label {
                    id: locationText
                    anchors.verticalCenter: locationInput.verticalCenter
                    color: Theme.primaryColor
                    //: Label for the default location setting to try for showtimes
                    text: qsTr('Default location')
                }

                TextField {
                    id: locationInput
                    //: Placeholder text for the default location. When visible, automatic location will be attempted
                    placeholderText: qsTr('Try automatically')
                    width: parent.width - locationText.width - parent.spacing
                    text: storage.getSetting('location', '')
                    Image {
                        id: clearLocationText
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        source: 'image://theme/icon-m-input-clear'
                        visible: locationInput.activeFocus
                    }

                    MouseArea {
                        id: locationInputMouseArea
                        anchors.fill: clearLocationText
                        onClicked: {
                            inputContext.reset()
                            locationInput.text = ''
                        }
                    }
                }
            }

            Row {
                id: showtimesDateItem
                width: parent.width
                spacing: Theme.paddingLarge

                Label {
                    id: showtimesDateLabel
                    width: locationText.width
                    anchors.verticalCenter: showtimesDateButton.verticalCenter
                    color: Theme.primaryColor
                    //: Label for the showtimes date setting
                    text: qsTr('Date')
                }

                Button {
                    id: showtimesDateButton
                    width: parent.width - showtimesDateLabel.width - parent.spacing
                    onClicked: showtimesDateDialog.open()
                }
            }
//                id: browsingSection
//                width: parent.width
//                spacing: Theme.paddingLarge

            SectionHeader {
                id: browsingSectionHeader
                //% "Browsing section"
                text: qsTr('Browsing')
            }


            TextSwitch {
                id: includeAllSwitch
                text: qsTr('Show unrated')
                description: qsTr('Include content with <10 votes')
            }
            TextSwitch {
                id: includeAdultSwitch
                text: qsTr('Adult content')
                description: qsTr('Include adult content')
            }

            SectionHeader {
                id: kodiSectionHeader
                //% "Kodi section"
                text: qsTr('Kodi')
            }
            TextSwitch {
                id: kodiSwitch
                text: qsTr('Kodi integration')
                description: qsTr('Needs plugin Genesis installed')
            }
            TextField {
                id: kodiIpInput

                visible: kodiSwitch.checked
                width: parent.width
                echoMode: TextInput.Normal
//                inputMask: "000.000.000.000;_"
                inputMethodHints: Qt.ImhDigitsOnly

                text: ''
                placeholderText: label
                //% "IP address input"
                label: qsTr("IP address")
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    parent.focus = true
                }
            }
            TextField {
                id: kodiPortInput

                visible: kodiSwitch.checked
                width: parent.width
                echoMode: TextInput.Normal
                inputMethodHints: Qt.ImhDigitsOnly

                placeholderText: label
                //% "Port input"
                label: qsTr("Port")
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    parent.focus = true
                }
            }
            TextField {
                id: kodiUsernameInput

                visible: kodiSwitch.checked
                width: parent.width
                echoMode: TextInput.Normal
                inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase

                text: ''
                placeholderText: label
                //% "Username input"
                label: qsTr("Username")
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    parent.focus = true
                }
            }
            TextField {
                id: kodiPasswordInput

                visible: kodiSwitch.checked
                width: parent.width
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase

                text: ''
                placeholderText: label
                //% "Password information"
                label: qsTr("Password. Will be saved in plain text.")
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {
                    parent.focus = true
                }
            }

        }
    }

    DatePickerDialog {
        id: showtimesDateDialog
//        titleText: "Showtimes date"
        onAccepted: {
            var date = new Date(showtimesDateDialog.year,
                                showtimesDateDialog.month - 1, // months are 0-based
                                showtimesDateDialog.day)
            if (date < new Date()) // accept future dates only
                date = new Date()
            showtimesDateTmp = date.toString()
            setDate(date)
        }
    }
    onAccepted: {
        storage.setSetting('showtimesDate', showtimesDateTmp)
        storage.setSetting('location', locationTmp)
        storage.setSetting('includeAll', includeAllTmp ? 'true' : 'false')
        storage.setSetting('includeAdult', includeAdultTmp ? 'true' : 'false')
        storage.setSetting('enableKodi', enableKodiTmp ? 'true' : 'false')
        enableKodi = enableKodiTmp
        storage.setSetting('kodiIp', kodiIpTmp)
        storage.setSetting('kodiPort', kodiPortTmp)
        storage.setSetting('kodiUsername', kodiUsernameTmp)
        storage.setSetting('kodiPassword', kodiPasswordTmp)
    }



    function setDate(date) {
        showtimesDateDialog.year = date.getFullYear()
        showtimesDateDialog.month = date.getMonth() + 1 // months are 0-based
        showtimesDateDialog.day = date.getDate()

        if (date.toDateString() === new Date().toDateString()) {
            //: Shown in a button when the date is set to Today.
            showtimesDateButton.text = qsTr('Today')
        } else {
            showtimesDateButton.text = Qt.formatDate(date, Qt.DefaultLocaleShortDate)
        }
    }
}
