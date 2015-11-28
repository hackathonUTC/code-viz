import QtQuick 2.0

Rectangle {
    id: root

    property string title
    property var methods
    property var attributes

    Rectangle {
        id: titleContainer
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        color: "purple"
    }

    Rectangle {
        id: classContent
        anchors.top: titleContainer.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        color: "green"
    }
}

