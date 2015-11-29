import QtQuick 2.0
import QtQuick.Controls 1.2
import codeviz 1.0

import codeviz 1.0

Item {
    id: root

    property real zoom: 1.0
    readonly property real maximumZoom: 4.0
    readonly property real minimumZoom: 1.0
    readonly property real zoomOffset: 1.5

    property real distanceFromCenter: 350 * zoom

    Component.onCompleted: {
        console.debug("Data = " + JSON.stringify(DataModel.queryClasses()))
        classListModel.append(DataModel.queryClasses());

        /*for (var i = 0; i < listModel.count; ++i){
            listInheritance.append(DataModel.queryInherits(listModel.get(i).name))
            console.debug(listInheritance.get(0).name, "------")
        }*/



    }



    ListModel {
        id: classListModel
    }

    ListModel {
        id: listInheritance
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
        contentWidth: parent.width * zoom
        contentHeight: parent.height * zoom

        Rectangle {
            width: flickable.contentWidth
            height: flickable.contentHeight
            color: "red"
            opacity: 0.7
        }

        MouseArea {
            width: flickable.contentWidth
            height: flickable.contentHeight
            onClicked: {
                if (mouse.button === Qt.RightButton) {
                    console.debug("Click right on blank")
                } else if (mouse.button === Qt.LeftButton) {
                    console.debug("Click left on blank")
                }
            }

            onDoubleClicked: {
                var mousePoint = Qt.point(mouse.x, mouse.y);
                console.debug("MAP " + mapToItem(flickable.contentItem, mouse.x, mouse.y))
                console.debug("double click " + mouse.x + " ; " + mouse.y);
                ++zoom;
            }

            onWheel: {
                if(wheel.angleDelta.y > 0) {
                    zoom = Math.min(root.maximumZoom, zoom + zoomOffset);
                } else {
                    zoom = Math.max(root.minimumZoom, zoom - zoomOffset);
                }
            }
        }


        Repeater {
            id: repeaterLinks
            model: DataModel.queryInherits("Filiere")[0].classTo
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
                color: "green"
            }
        }

        Repeater {
            id: repeater
            model: classListModel
            anchors.fill: parent
            delegate: ClassBox {
                zoom: root.zoom
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
                x: (flickable.contentWidth - width) / 2.0 -
                   + Math.cos((2 * index + 0.5) * Math.PI / repeater.count) * distanceFromCenter
                y: (flickable.contentHeight - height) / 2.0
                    + Math.sin((2 * index + 0.5) * Math.PI / repeater.count) * distanceFromCenter
                title: name
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
