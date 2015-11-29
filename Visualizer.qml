import QtQuick 2.0
import QtQuick.Controls 1.2
import codeviz 1.0

Item {
    id: root

    function getChildFromName(name){
        for(var i = 0; i < repeater.count; ++i){
            if (repeater.itemAt(i).title === name)
                return repeater.itemAt(i);
        }
    }

    function refreshInheritance()
    {
        canvas.lineList = [];
        for(var i = 0; i < repeater.model.count; ++i){
            var childAt = repeater.itemAt(i)
            var motherList = childAt.inheritsListModel;
            if(motherList.count > 0)
            {
                var motherClass = getChildFromName(motherList.get(0).classTo)
//                console.log("from : " + childAt.x + ";" + childAt.y)
//                console.log("to : " + motherClass.x + ";" + motherClass.y)
                canvas.lineList.push({

                    "fromX": childAt.x,
                    "fromY": childAt.y,
                    "toX": motherClass.x,
                    "toY": motherClass.y
                });
            }
        }

        canvas.requestPaint()
    }

    property real zoom: 1.0
    readonly property real maximumZoom: 4.0
    readonly property real minimumZoom: 1.0
    readonly property real zoomOffset: 1.5

    property real distanceFromCenter: 350 * zoom

    Component.onCompleted: {
        classListModel.append(DataModel.queryClasses());
        refreshInheritance();
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
        contentWidth: parent.width// * zoom
        contentHeight: parent.height //* zoom

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
//                    console.debug("Click right on blank")
                } else if (mouse.button === Qt.LeftButton) {
//                    console.debug("Click left on blank")
                }
            }

            onDoubleClicked: {
                var mousePoint = Qt.point(mouse.x, mouse.y);
//                console.debug("MAP " + mapFromItem(flickable.contentItem, mouse.x, mouse.y))
//                console.debug("double click " + mouse.x + " ; " + mouse.y);
                ++zoom;
            }

            onWheel: {
                if (wheel.angleDelta.y > 0) {
                    var scrollPoint = root.mapFromItem(flickable.contentItem, wheel.x, wheel.y);

                    var newZoom = Math.min(root.maximumZoom, zoom + zoomOffset);
                    console.debug("newZoom " + newZoom)
                    var currentWidth = flickable.contentWidth;
                    console.debug("currentWidth " + currentWidth)
                    var currentHeight = flickable.contentHeight;
                    console.debug("currentHeight " + currentHeight)
                    var newWidth = root.width * newZoom;
                    console.debug("newWidth " + newWidth)
                    var newHeight = root.height * newZoom;
                    console.debug("newHeight " + newHeight)
                    var offsetWidth = (newWidth - currentWidth) / 2.0
                    var offsetHeight = (newHeight - currentHeight) / 2.0

                    var scrollOffset = Qt.point(newZoom * (scrollPoint.x - root.width / 2.0),
                                                newZoom * (scrollPoint.y - root.height / 2.0))

                    console.debug("scroll " + scrollPoint.x + ";" + scrollPoint.y)
                    console.debug("scrollOffset = " + scrollOffset.x + ";" + scrollOffset.y)

                    if (zoom != newZoom) {
                        zoom = newZoom;
                        var newCenter = Qt.point(flickable.contentWidth / 2.0,
                                             flickable.contentHeight / 2.0)
                        flickable.resizeContent(newZoom * root.width,
                                                newZoom * root.height,
                                                newCenter)
                    }
                } else {
                    var newZoom = Math.max(root.minimumZoom, zoom - zoomOffset);
                    if (zoom != newZoom) {
                        zoom = newZoom;
                        var newCenter = Qt.point(flickable.contentWidth / 2.0,
                                                 flickable.contentHeight / 2.0)
                            flickable.resizeContent(newZoom * root.width,
                                                    newZoom * root.height,
                                                    newCenter)
                    }
                }
            }
        }

        Canvas {
            id: canvas
            height: flickable.contentHeight;
            width: flickable.contentWidth;
            anchors.fill: parent;

            property var context: getContext("2d");
            property var lineList;

            onPaint: {


                // Draw a line
                context.reset()
                context.beginPath();
                context.lineWidth = 2;
                context.strokeStyle = "grey"
                for(var i = 0 ; i < lineList.length ; ++i)
                {
                    var line = lineList[i];
                    //console.log("line from " + line.fromX + ";" + line.fromY)
                    //console.log("line to " + line.toX + ";" + line.toY)
                    context.moveTo(line.fromX, line.fromY);
                    context.lineTo(line.toX, line.toY);
                    context.arc(line.toX, line.toY, 10, 0, 2*Math.PI, true)
                }
                context.stroke();
            }

        }


        Repeater {
            id: repeater
            model: classListModel
            anchors.fill: parent

            delegate: ClassBox {
                id: classBox
                    zoom: root.zoom


//                    Behavior on width {
//                        NumberAnimation { }
//                    }

//                    Behavior on height {
//                        NumberAnimation { }
//                    }

//                    Behavior on x {
//                        NumberAnimation { }
//                    }

//                    Behavior on y {
//                        NumberAnimation { }
//                    }

                    width: 150 * zoom
                    height: 250 * zoom
                    x: (flickable.contentWidth - width) / 2.0 -
                       + Math.cos((2 * index + 0.5) * Math.PI / repeater.count) * distanceFromCenter
                    y: (flickable.contentHeight - height) / 2.0
                        + Math.sin((2 * index + 0.5) * Math.PI / repeater.count) * distanceFromCenter
                    title: name

                    onXChanged: {
                        refreshInheritance()
                    }

                    onYChanged: {
                        refreshInheritance()
                    }



            }


        }
    }
}
