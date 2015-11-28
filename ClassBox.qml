import QtQuick 2.0
import Material 0.1


View {
    id: root

    elevation: 2
    property string title
    property var methods
    property var attributes

    Rectangle {
        id: titleContainer
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        color: "purple"
        Text {
            text: root.title
        }
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
