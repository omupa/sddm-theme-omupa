import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: container
    width: 1024
    height: 768

    property int sessionIndex: session.index

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        function onLoginSucceeded() {
        }

        function onLoginFailed() {
            txtMessage.text = textConstants.loginFailed
            passwordInput.text = ""
        }
    }

    Repeater {
        model: screenModel
        Background {
            x: geometry.x; y: geometry.y; width: geometry.width; height:geometry.height
            source: config.background
            fillMode: Image.PreserveAspectCrop

            function onStatusChanged() {
                if (status == Image.Error && source != config.defaultBackground) {
                    source = config.defaultBackground
                }
            }
        }
    }

    Rectangle {
        id: actionBar
        anchors.top: parent.top;
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width; height: 64
        color: 'transparent'

        Row {
            anchors.left: parent.left
            anchors.margins: 5
            height: parent.height
            spacing: 5

            Text {
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                text: textConstants.session
                font.pixelSize: 14
                color: "white"
                verticalAlignment: Text.AlignVCenter
            }

            ComboBox {
                id: session
                width: 245
                anchors.verticalCenter: parent.verticalCenter
                arrowIcon: "angle-down.png"
                model: sessionModel
                index: sessionModel.lastIndex
                font.pixelSize: 14
                color: "white"
                borderColor: "transparent"
                textColor: "black"
                KeyNavigation.backtab: btnShutdown; KeyNavigation.tab: layoutBox
            }

            Text {
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                text: textConstants.layout
                font.pixelSize: 14
                color: "white"
                verticalAlignment: Text.AlignVCenter
            }

            LayoutBox {
                id: layoutBox
                width: 90
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14
                arrowIcon: "angle-down.png"
                borderColor: "transparent"
                KeyNavigation.backtab: session; KeyNavigation.tab: btnShutdown
            }
        }

        Row {
            height: parent.height
            anchors.right: parent.right
            anchors.margins: 5
            spacing: 5

            ImageButton {
			    id: btnSuspend
			    height: parent.height
			    source: "suspend.svg"
			    visible: sddm.canSuspend
			    KeyNavigation.backtab: layoutBox; KeyNavigation.tab: btnReboot
			    
                function onClicked() {
			        sddm.suspend()
			    }
            }

            ImageButton {
			    id: btnReboot
			    height: parent.height
			    source: "reboot.svg"
			    visible: sddm.canReboot
			    KeyNavigation.backtab: btnSuspend; KeyNavigation.tab: btnShutdown


			    function onClicked() {
			        sddm.reboot()
			    }
            }

            ImageButton {
			    id: btnShutdown
			    height: parent.height
			    source: "shutdown.svg"
			    visible: sddm.canPowerOff
			    KeyNavigation.backtab: btnReboot; KeyNavigation.tab: usernameInput

			    function onClicked() {
			        sddm.powerOff()
			    }
            }
        }
    }

    Rectangle {
        property variant geometry: screenModel.geometry(screenModel.primary)
        x: geometry.x; y: geometry.y; width: geometry.width; height: geometry.height
        color: "transparent"

        Column {
            anchors.centerIn: parent
            spacing: 20
            width: 350

            Rectangle {
                id: usernameBox
                width: parent.width
                height: 40
                color: '#b4000000'
                radius: 3
                border.color: "transparent"
                border.width: 0
                anchors.horizontalCenter: parent.horizontalCenter

                TextInput {
                    id: usernameInput
                    anchors.fill: parent
                    anchors.margins: 10
                    color: "white"
                    font.pixelSize: 14
                    focus: true
                    KeyNavigation.tab: passwordInput
                }

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 10
                    text: "Username"
                    color: "#888888"
                    font.pixelSize: 12
                    visible: usernameInput.text === ""
                }
            }

            Rectangle {
                id: passwordBox
                width: parent.width
                height: 40
                color: '#b4000000'
                radius: 3
                border.color: "transparent"
                border.width: 0
                anchors.horizontalCenter: parent.horizontalCenter

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.margins: 10
                    color: "white"
                    font.pixelSize: 14
                    echoMode: TextInput.Password
                    KeyNavigation.backtab: usernameInput; KeyNavigation.tab: loginButton

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            performLogin()
                        }
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 10
                    text: "Password"
                    color: "#888888"
                    font.pixelSize: 12
                    visible: passwordInput.text === ""
                }
            }

            Rectangle {
                id: loginButton
                width: parent.width
                height: 40
                color: '#d7000000'
                radius: 3
                anchors.horizontalCenter: parent.horizontalCenter

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }

                Text {
                    anchors.centerIn: parent
                    text: "Login"
                    color: "white"
                    font.pixelSize: 14
                    font.bold: false
                    font.family: "Ubuntu"
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = '#000000'
                    onExited: parent.color = "#d7000000"
                    onClicked: performLogin()
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "transparent"

                Text {
                    id: txtMessage
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: '#ffcc5d'
                    text: ""
                    font.bold: true
                    font.pixelSize: 14
                    font.family: "Ubuntu"
                    visible: text !== ""
                }
            }
        }
    }

    function performLogin() {
        if (usernameInput.text === "" || passwordInput.text === "") {
            txtMessage.text = "Please enter both username and password"
            return
        }
        sddm.login(usernameInput.text, passwordInput.text, sessionIndex)
    }
}
