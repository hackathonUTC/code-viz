import QtQuick 2.0
//import Material 0.1


Column {
    id: root

    //elevation: 2
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

    Row {
        Rectangle {
            height: 100
            width: titleContainer.width / 2
            id: attributesContainer
            color: "green"
        }
        Rectangle {
            height: 100
            width: titleContainer.width / 2
            id: methodsContainer
            color: "red"
        }
    }

    Rectangle {
        id: instancesContainer
        height: 150
        width: titleContainer.width
        color: "yellow"
    }

}
