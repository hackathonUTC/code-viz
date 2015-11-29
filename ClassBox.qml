import QtQuick 2.0
import codeviz 1.0

Item {
    id: root
    property alias title: titleText.text

    property double zoom: 1.0

    Component.onCompleted: {
        methodListModel.append(DataModel.queryMethods(root.title))
        attributeListModel.append(DataModel.queryAttributes(root.title))
        callInsideListModel.append(DataModel.queryCallsInsideClass(root.title))
        inheritageListModel.append(DataModel.queryInherits(root.title))
    }

    ListModel {
        id: methodListModel
    }

    ListModel {
        id: attributeListModel
    }

    ListModel {
        id: referenceListModel
    }

    ListModel {
        id: callInsideListModel
    }

    ListModel {
        id: inheritageListModel
    }

    states: [State {name: "zeroZoom"
            when: zoom > 3},
        State {name: "firstZoom"
            when: zoom <= 3 && zoom > 2},
        State {name: "secondZoom"
            when: zoom <= 2}]

    Canvas {
    width: 200
    height: 300
    }

    Column {
        anchors.fill: parent

        Rectangle {
            id: titleContainer
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50
            color: "purple"
            Text {
                id: titleText
            }
        }

        Row {
            Column{
                visible: opacity > 0.0
                opacity: root.state === "zeroZoom" ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation {}
                }

                width: root.state === "zeroZoom" ? titleContainer.width / 2 : 0
                id: attributesContainer
                Repeater{
                    model: attributeListModel
                    delegate:
                        Row {
                        Text {
                            text: name + ":"+ type
                        }
                    }
                }
            }
            Column{
                width: /*titleContainer.width / 2*/ root.state === "zeroZoom" ? titleContainer.width / 2 : titleContainer.width
                visible: opacity > 0.0
                opacity: !(root.state === "secondZoom") ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation {}
                }

                id: methodsContainer
                Repeater {
                    model: methodListModel
                    delegate:
                        Row {
                        Text {
                            text: root.state === "firstZoom" ? (visibility === "public" ? name : "") : name + ":" + visibility
                        }
                    }



                    /*Repeater {
                        model: referenceListModel // Ne prend que les arcs avec les références
                        delegate:
                            Path {
                            startX: 0
                            startY: 100
                            PathLine {
                                x: 200
                                y: 300
                            }
                        }
                    }*/
                }
            }
        }

    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.debug("Click on box " + title)
        }
    }
}

