import QtQuick 2.0
import QtQuick.Controls 1.2
import codeviz 1.0

import codeviz 1.0

Item {
    id: root

    property real zoom: 1.0
    readonly property real maximumZoom: 4.0
    readonly property real minimumZoom: 1.0
    readonly property real zoomOffset: 0.4

    property real distanceFromCenter: 350 * zoom

    Component.onCompleted: {
        console.debug("Data = " + JSON.stringify(DataModel.queryClasses()))
        classListModel.append(DataModel.queryClasses());
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



        Repeater {
            id: repeater
            model: classListModel
            anchors.fill: parent
            delegate: Item{

                /*Path{
                    id: myPath
                    startX: classBox.x
                    startY: classBox.y

                    PathArc{
                        x: classBox.inheritsListModel[0].x
                        y: classBox.inheritsListModel[0].y
                Behavior on scale {
                    NumberAnimation {
                        easing.type: Easing.OutQuint
                        duration: 1000
                    }

                }*/

                Canvas {
                    width: 1000
                    height: 1000

                    onPaint: {
                        // Get drawing context
                        var context = getContext("2d");

                        // Draw a line
                        context.beginPath();
                        context.lineWidth = 2;
                        context.moveTo(toto1.x, toto1.y);
                        context.strokeStyle = "blue"
                        context.lineTo(toto2.x, toto2.y);
                        context.stroke();
                    }
                }

                ClassBox {
                    zoom: root.zoom
                    scale: zoom
                    id: classBox

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
