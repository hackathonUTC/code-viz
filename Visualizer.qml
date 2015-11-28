import QtQuick 2.0
import QtQuick.Controls 1.2

Item {
    id: root

    property real zoom: 1.0
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

        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.debug("Click on blank")
            }

            onWheel: {
                console.debug("wheel = " + JSON.stringify(wheel.angleDelta))
            }
        }

        Repeater {
            id: repeaterLinks

            model: listModel
            anchors.fill: parent
            /*delegate: Rectangle {
                color: "blue"
                opacity: 0.7
                width: repeater.itemAt(index).x - repeater.itemAt(index+1).x
                height: repeater.itemAt(index).y - repeater.itemAt(index+1).y
                x:
                    repeater.itemAt(index).x
                y:
                    repeater.itemAt(index).y
                z:
                    repeater.itemAt(index).z + 1
            }*/
        }

        ClassBox {
            id: toto1
            width: 150
            height: 250
            x: 100
            y: 100
            title: className
        }

        ClassBox {
            id: toto2
            width: 50
            height: 150
            x: 450
            y: 200
            title: className
        }

        Item {
            id: myItem
            property real index : 2
            opacity: 0.7
            anchors.top: toto1.y < toto2.y ? toto1.top : toto2.top
            anchors.bottom: toto1.y < toto2.y ? toto2.top : toto1.top
            anchors.right: toto1.x < toto2.x ? toto2.left : toto1.left
            anchors.left: toto1.x < toto2.x ? toto1.left : toto2.left
            z:
                repeater.itemAt(index).z + 1

            onWidthChanged: {
                rec.width = Math.sqrt(myItem.height*myItem.height + myItem.width*myItem.width)
                rec.rotation = Math.atan(myItem.height/myItem.width)

            }
            onHeightChanged:{
                rec.width = Math.sqrt(myItem.height*myItem.height + myItem.width*myItem.width)
                rec.rotation = Math.atan(myItem.height/myItem.width)*180/Math.PI

            }

            Rectangle{
                id: rec
                anchors.centerIn: myItem
                antialiasing: true
                height: 1
                color: "blue"
            }
        }

        Repeater {
            id: repeater
            model: listModel
            anchors.fill: parent
            onCountChanged: {
                console.debug("count " + count)
                if (count === 3)
                {
                    rec.width = Qt.binding(function() { return repeater.itemAt(2).x - repeater.itemAt(1).x });
                    rec.height = Qt.binding(function() { return repeater.itemAt(2).y - repeater.itemAt(1).y });
                }
            }
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
