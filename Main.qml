import QtQuick
import QtQuick.Window
import QtQuick.Controls

ApplicationWindow {
    id: root
    visible: true

    title: qsTr("Hello World")

    readonly property int outerMargin: 10
    font.pointSize: Math.round(Math.min(width, height) / 1000 * 32)

    background: Rectangle {
        color: "black"
    }

    header: Item {
        height: titleLabel.implicitHeight * 1.5

        Label {
            id: titleLabel
            anchors.centerIn: parent
            text: 'Example application'

            Component.onCompleted: font.pointSize *= 1.5
        }
    }

    Label {
        id: contentLabel

        anchors.centerIn: parent
        text: 'Content'
    }
}
