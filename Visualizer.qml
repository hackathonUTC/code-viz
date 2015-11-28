import QtQuick 2.0
import QtQuick.Controls 1.2

Item {
    id: root

    property real zoom
    property real distanceFromCenter: 400


    ListModel {
        id: listModel
    }

    Component {
        id: cListElement

        ListElement {
            property string className;
            property var attributes;
            property var methods;
            property var inheritsFrom;

        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: 1000
        contentHeight: 1000
        Repeater {
            id: repeater
            model: listModel
            anchors.fill: parent
            delegate: ClassBox {
                width: 150
                height: 250
                x: (root.width - width) / 2.0 -
                   + Math.cos((2 * index + 0.5) * Math.PI / repeater.count) * distanceFromCenter
                y: (root.height - height) / 2.0
                    + Math.sin((2 * index + 0.5) * Math.PI / repeater.count) * distanceFromCenter
                title: className
            }
        }
    }


    Button {
        anchors.centerIn: parent
        width: 50
        height: 50

        onClicked: {
            console.debug("clicked")
            var newAttributes = {"test": "real",
                    "aaa":"string"};
            var newMethods = {
                "foo": "bar"
            };
            var newElement = cListElement.createObject(root, {
                className: "firstClass",
                attributes: newAttributes,
                methods: newMethods
            });
            listModel.append(newElement);

            console.debug(JSON.stringify(newElement))
        }
    }
}
