import QtQuick 2.0
import QtQuick.Controls 1.2
import codeviz 1.0

Item {
    id: root

    property string focusedMethodFrom: ""
    property string focusedMethodTo: ""
    property string focusedClass: ""

    states: [
        State {
            name: "zeroZoom"
            when: zoom > 3
        },
        State {
            name: "firstZoom"
            when: zoom <= 3 && zoom > 2
        },
        State {
            name: "secondZoom"
            when: zoom <= 2
        }
    ]

    function getChildFromName(name){
        for(var i = 0; i < repeater.count; ++i){
            if (repeater.itemAt(i).title === name)
                return repeater.itemAt(i);
        }
    }

    function getIndexMethodFromClass(className, methodName){

        var methods = DataModel.queryMethods(className)

        for(var i = 0; i < methods.length; ++i){
            if (methods[i].name === methodName)
                return i;
        }
    }

    ListModel {
        id: lineList
    }

    ListModel {
        id: lineMethodsList
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

    function refreshMethods()
    {
        lineMethodsList.clear()
        for(var i = 0; i < repeater.model.count; ++i){
            var childAt = repeater.itemAt(i)
            var methodList = childAt.callOutsideListModel;
            if(methodList.count > 0)
            {
                for (var j = 0; j < methodList.count; ++j){

                    var pointFrom = getChildFromName(methodList.get(j).classFrom)
                    var pointTo = getChildFromName(methodList.get(j).classTo)


                    lineMethodsList.append({

                        "nameClassFrom":  methodList.get(j).classFrom,
                        "nameClassTo":  methodList.get(j).classTo,
                        "nameMethodFrom":  methodList.get(j).methodFrom,
                        "nameMethodTo":  methodList.get(j).methodTo,
                        "fromX": pointFrom.x + pointFrom.width/2,
                        "fromY": pointFrom.y,
                        "toX": pointTo.x  + pointTo.width/2,
                        "toY": pointTo.y
                    });
                }


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

        Behavior on contentX {
            NumberAnimation { }
        }
        Behavior on contentY {
            NumberAnimation { }
        }

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
                } else if (mouse.button === Qt.LeftButton) {
                }
            }

            onDoubleClicked: {
                var mousePoint = Qt.point(mouse.x, mouse.y);
                ++zoom;
            }

            onWheel: {
                if (wheel.angleDelta.y > 0) {
                    var scrollPoint = root.mapFromItem(flickable.contentItem, wheel.x, wheel.y);

                    var newZoom = Math.min(root.maximumZoom, zoom + zoomOffset);
                    var currentWidth = flickable.contentWidth;
                    var currentHeight = flickable.contentHeight;
                    var newWidth = root.width * newZoom;
                    var newHeight = root.height * newZoom;
                    var offsetWidth = (newWidth - currentWidth) / 2.0
                    var offsetHeight = (newHeight - currentHeight) / 2.0

                    var scrollOffset = Qt.point(newZoom * (scrollPoint.x - root.width / 2.0),
                                                newZoom * (scrollPoint.y - root.height / 2.0))


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
                focusedMethodFrom: root.focusedMethodFrom
                focusedMethodTo: root.focusedMethodTo


                centralityCoefficient: centrality


                    x: (flickable.contentWidth - width) / 2.0 -
                       + Math.cos((2 * index + 0.5) * Math.PI / repeater.count) * distanceFromCenter
                    y: (flickable.contentHeight - height) / 2.0
                        + Math.sin((2 * index + 0.5) * Math.PI / repeater.count) * distanceFromCenter
                    title: name

                    onXChanged: {
                        refreshInheritance()
                        refreshMethods()
                    }

                    onYChanged: {
                        refreshInheritance()
                        refreshMethods()
                    }

            }

        }



        Repeater{
            id: repeaterLinksClasses
            model: lineList
            anchors.fill: parent

            property int focusedLinkIndex: -1

            delegate: Rectangle {
                id: rec

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right

                    color:parent.color;
                    height: 15
                    width: 15
                }

                property point to: Qt.point(toX, toY)
                transform: Rotation {
                    angle: fromX < toX ? Math.atan((toY - fromY)/(toX - fromX))*180/Math.PI : 180 + Math.atan((toY - fromY)/(toX - fromX))*180/Math.PI
                }

                x: fromX
                y: fromY
                z: flickable.z + 1

                color: index === repeaterLinksClasses.focusedLinkIndex ? "red" : "grey"
                opacity: index === repeaterLinksClasses.focusedLinkIndex ? 1.0 : 0.2


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
                        if (repeaterLinksClasses.focusedLinkIndex === index) {
                            repeaterLinksClasses.focusedLinkIndex = -1;
                        } else {
                            repeaterLinksClasses.focusedLinkIndex = index;
                        }
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

        Repeater{
            id: repeaterLinksMethods
            model: lineMethodsList
            anchors.fill: parent            

            property int focusedLinkIndex: -1


            delegate: Rectangle {
                id: recMethods

                property point to: Qt.point(toX, toY)
                transform: Rotation {
                    angle: fromX < toX ? Math.atan((toY - fromY)/(toX - fromX))*180/Math.PI : 180 + Math.atan((toY - fromY)/(toX - fromX))*180/Math.PI
                }

                x: fromX
                y: fromY
                z: flickable.z + 1

                visible: opacity > 0.0

                color: index === repeaterLinksMethods.focusedLinkIndex ? "red" : "green"
                opacity: (index === repeaterLinksMethods.focusedLinkIndex ? 1.0 : 0.2)


                Behavior on opacity {
                    NumberAnimation { }
                }

                height: 2
                width: Math.sqrt((fromX - toX)*(fromX - toX) + (fromY - toY)*(fromY - toY))


                MouseArea {

                    anchors.centerIn: parent
                    height: parent.height * 4.0
                    width: parent.width
                    hoverEnabled: true
                    onEntered: {
                        root.focusedMethodFrom = nameMethodFrom
                        root.focusedMethodTo = nameMethodTo
                        repeaterLinksMethods.focusedLinkIndex = index
                    }

                    onExited: {
                        root.focusedMethodFrom = ""
                        root.focusedMethodTo = ""
                        repeaterLinksMethods.focusedLinkIndex = -1
                    }

                    onClicked: {
                        var deltaX = rec.to.x - (flickable.contentX + root.width / 2.0)
                        var deltaY = rec.to.y - (flickable.contentY + root.height / 2.0)
                        flickable.contentX += deltaX
                        flickable.contentY += deltaY
                        flickable.returnToBounds();

                    }

                    Rectangle {
                        id: linkHighlightMethods
                        anchors.fill: parent
                        visible: false
                        opacity: 1
                        antialiasing: true
                        radius: height / 2.0
                    }
                }
            }
        }
    }
}
