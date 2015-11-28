import QtQuick 2.0
import QtQuick.Controls 1.2

Item {
    id: root

    property real zoom

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

    Repeater {
        model: listModel
        anchors.fill: parent
        delegate: ClassBox {
            width: 150
            height: 250
            x: index * 200
            title: className
        }
    }
}
