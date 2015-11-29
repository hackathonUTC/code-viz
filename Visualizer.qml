import QtQuick 2.0
import QtQuick.Controls 1.2

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

    }

    ListModel {
        id: classListModel
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
            id: repeater
            model: classListModel
            anchors.fill: parent
            delegate: ClassBox {
                zoom: root.zoom
                scale: zoom * (0.5 + 1.1*centrality)

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
