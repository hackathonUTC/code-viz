import QtQuick 2.0
import QtQuick.Controls 1.2

Item {
    id: root

    property real zoom: 1.0
    property real distanceFromCenter: 400 * zoom

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
        focus: true
        anchors.fill: parent
        contentWidth: 1000 * zoom
        contentHeight: contentWidth
        onContentWidthChanged: {
            console.debug("content width = " + contentWidth);
        }

//        Rectangle {
//            width: flickable.contentWidth
//            height: flickable.contentHeight
//            color: "red"
//            opacity: 0.7
//        }

        MouseArea {
            width: flickable.contentWidth
            height: flickable.contentHeight
            onClicked: {
                console.debug("Click on blank")
            }

            onDoubleClicked: {
                console.debug("double click")
                ++zoom;
            }

            onWheel: {
                console.debug("wheel = " + JSON.stringify(wheel.angleDelta))
            }
        }

        Repeater {
            id: repeater
            model: listModel
            anchors.fill: parent
            delegate: ClassBox {
                scale: zoom
                Behavior on scale {
                    NumberAnimation {

                    }
                }

                Behavior on x {
                    NumberAnimation { }
                }

                Behavior on y {
                    NumberAnimation { }
                }

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
