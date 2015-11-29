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

    ListModel {
        id: lineList
    }

    function refreshInheritance()
    {
        lineList.clear()
        for(var i = 0; i < repeater.model.count; ++i){
            var childAt = repeater.itemAt(i)
            var motherList = childAt.inheritsListModel;
            if(motherList.count > 0)
            {
                var motherClass = getChildFromName(motherList.get(0).classTo)
                lineList.append({

                    "fromX": childAt.x,
                    "fromY": childAt.y,
                    "toX": motherClass.x,
                    "toY": motherClass.y
                });
            }
        }
    }

    property real zoom: 1.0
    readonly property real maximumZoom: 7.0
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
        boundsBehavior: Flickable.StopAtBounds

        Rectangle {
            width: flickable.contentWidth
            height: flickable.contentHeight
            color: "white"
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
                        var newCenter = Qt.point(wheel.x, wheel.y);
                        flickable.resizeContent(newZoom * root.width,
                                                newZoom * root.height,
                                                newCenter)
                        flickable.returnToBounds();
                    }
                } else {
                    var newZoom = Math.max(root.minimumZoom, zoom - zoomOffset);
                    if (zoom != newZoom) {
                        zoom = newZoom;
                        var newCenter = Qt.point(wheel.x, wheel.y);
                        flickable.resizeContent(newZoom * root.width,
                                                    newZoom * root.height,
                                                    newCenter)
                        flickable.returnToBounds();
                    }
                }

                refreshInheritance()
            }
        }




        Repeater {
            id: repeater
            model: classListModel
            anchors.fill: parent


            delegate: ClassBox {
                id: classBox
                zoom: root.zoom
                centralityCoefficient: centrality

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


        Repeater{
            id: repeaterLinksClasses
            model: lineList
            anchors.fill: parent

            property Rectangle recColored : null

            delegate: Rectangle {
                id: rec

                property point to: Qt.point(toX, toY)
                transform: Rotation {
                    angle: fromX < toX ? Math.atan((toY - fromY)/(toX - fromX))*180/Math.PI : 180 + Math.atan((toY - fromY)/(toX - fromX))*180/Math.PI
                }

                x: fromX
                y: fromY
                z: flickable.z + 1

                color: "grey"
                opacity: 0.3


                height: 2
                width: Math.sqrt((fromX - toX)*(fromX - toX) + (fromY - toY)*(fromY - toY))


                MouseArea {

                    anchors.centerIn: parent
                    height: parent.height * 4.0
                    width: parent.width
                    hoverEnabled: true
                    onEntered: {
                        linkHighlight.visible = true;
                    }

                    onExited: {
                        linkHighlight.visible = false;
                    }

                    onClicked: {
                        var deltaX = rec.to.x - (flickable.contentX + root.width / 2.0)
                        var deltaY = rec.to.y - (flickable.contentY + root.height / 2.0)
                        flickable.contentX += deltaX
                        flickable.contentY += deltaY
                        flickable.returnToBounds();
                        if (repeaterLinksClasses.recColored)
                        {
                            repeaterLinksClasses.recColored.color = "grey"
                            repeaterLinksClasses.recColored.opacity = 0.2
                        }

                        rec.color = "red"
                        rec.opacity = 1
                        repeaterLinksClasses.recColored = rec
                    }

                    Rectangle {
                        id: linkHighlight
                        anchors.fill: parent
                        visible: false
                        color: "yellow"
                        opacity: 0.9
                        antialiasing: true
                        radius: height / 2.0
                    }
                }
            }
        }
    }
}
