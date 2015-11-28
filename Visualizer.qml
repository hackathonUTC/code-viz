import QtQuick 2.0

Item {
    id: root

    ListModel {
        id: listModel

        ListElement {

        }
        ListElement {

        }
        ListElement {

        }
        ListElement {

        }
        ListElement {

        }
    }

    Repeater {
        model: listModel
        anchors.fill: parent
        delegate: ClassBox {
            width: 150
            height: 250
            x: index * 200
            title: "index = " + index
        }

    }
}
