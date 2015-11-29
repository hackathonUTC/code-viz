import QtQuick 2.0
import codeviz 1.0

Item {
    id: root
    property alias title: titleText.text
    property double zoom: 1.0
    property alias inheritsListModel:inheritsListModel



    Component.onCompleted: {
        methodListModel.append(DataModel.queryMethods(root.title))
        attributeListModel.append(DataModel.queryAttributes(root.title));
        inheritsListModel.append(DataModel.queryInherits(root.title));
    }

    ListModel {
        id: methodListModel
    }

    ListModel {
        id: inheritsListModel
    }

    ListModel {
        id: attributeListModel
    }

    states: [State {name: "zeroZoom"
                    when: zoom > 3},
             State {name: "firstZoom"
                    when: zoom <= 3 && zoom > 2},
             State {name: "secondZoom"
                    when: zoom <= 2}]


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
                visible: root.state === "zeroZoom"
                width: root.state === "zeroZoom" ? titleContainer.width / 2 : 0
                id: attributesContainer
                Repeater{
                    model: attributeListModel
                    delegate:
                        Row{
                        Text{
                            text: name + ":"+ type
                        }
                    }
                }
            }
            Column{
                width: /*titleContainer.width / 2*/ root.state === "zeroZoom" ? titleContainer.width / 2 : titleContainer.width
                visible: !(root.state === "secondZoom")
                id: methodsContainer
                Repeater{
                    model: methodListModel
                    delegate:
                        Row{
                        Text{
                            text: root.state === "firstZoom" ? (visibility === "public" ? name : "") : name + ":" + visibility
                        }
                    }
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

