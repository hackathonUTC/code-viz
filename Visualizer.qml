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
            width: 100
            height: 150
            x: index * 200
        }

    }
}
