import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

import QtIf.Android.VehicleProperties

ApplicationWindow {
    id: root
    visible: true

    title: qsTr("Hello World")

    background: Rectangle {
        color: 'black'
    }

    header: Item {
        height: titleLabel.implicitHeight * 1.5

        Label {
            id: titleLabel

            anchors.centerIn: parent

            text: 'Example QtIF + AAOS'
            color: 'white'
        }
    }

    RowLayout{

        anchors.centerIn: parent

        Label {
            id: speedLabel

            text: "Speed (m/s):"
            color: 'white'
        }

        Label {
            id: speedValueLabel

            text: driveInfo.perfVehicleSpeed
            color: 'white'
        }
    }

    DriveInfo {
        id: driveInfo
    }
}
