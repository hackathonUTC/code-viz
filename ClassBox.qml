import QtQuick 2.0
import codeviz 1.0

Item {
    id: root
    property alias title: titleText.text

    property double zoom: 1.0
    property alias inheritsListModel:inheritageListModel

    Rectangle {
        color: "grey"
        opacity: 0.5
        anchors.fill: parent
    }

    Component.onCompleted: {
        methodListModel.append(DataModel.queryMethods(root.title))
        attributeListModel.append(DataModel.queryAttributes(root.title))
        callInsideListModel.append(DataModel.queryCallsInsideClass(root.title))
        inheritageListModel.append(DataModel.queryInherits(root.title))

        // Récupérer les références
        var i = 0
        var j
        for (; i < methodListModel.count; ++i)
        { var tmp = DataModel.queryMethodReferences(root.title, methodListModel.get(i).name)
            j = 0
            while (tmp[j])
            {
                console.debug(tmp[j])
                referenceListModel.append(tmp[j++])}} // Ranger les noms de fonction 1 à 1 dans la ListModel
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
                        property string attributeName: name
                        Text {
                            text: name + ":"+ type
                        }
                    }
                }
            }
            Column{
                id: methodsContainer
                width: /*titleContainer.width / 2*/ root.state === "zeroZoom" ? titleContainer.width / 2 : titleContainer.width
                visible: opacity > 0.0
                opacity: !(root.state === "secondZoom") ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation {}
                }

                Repeater {
                    model: methodListModel
                    delegate:
                        Row {
                        property string methodName: name
                        Text {
                            id: textField

                            text: root.state === "firstZoom" ? (visibility === "public" ? name : "") : name + ":" + visibility
                        }
                    }
                }
            }
        }
    }


        Canvas {
            width: 1000
            height: 1000
            onPaint: {
                var j = 0
                // Get drawing context
                var context = getContext("2d");
                var methodposX
                var methodposY
                var attributeposX
                var attributeposY
                for (; j < referenceListModel.count; ++j)
                {
                    var i = 0

                    while (i < methodsContainer.children.length && methodsContainer.children[i].methodName !== referenceListModel.get(i).method)
                    {
                        console.debug(referenceListModel.get(i).method)
                        ++i;}
                    if (methodsContainer.children[i].methodName == referenceListModel.get(i).method)
                    {
                        methodposX = methodsContainer.children.mapToItem(null, 0, 0).x
                        methodposY = methodsContainer.children.mapToItem(null, 0, 0).y
                    }
                    i = 0
                    while (i < attributesContainer.children.length && attributesContainer.children.attributeName != attribute)
                        ++i;
                    if (attributesContainer.children.attributeName == attribute)
                    {
                        attributeposX = attributesContainer.children[i].mapToItem(null, 0, 0).x
                        attributeposY = attributesContainer.children[i].mapToItem(null, 0, 0).y
                    }

                    console.debug("Tracer une ligne de (" + methodposX + ", " + methodposY + ") vers (" + attributeposX + ", " + attributeposY + ").")
                    // Draw a line
                    context.beginPath();
                    context.lineWidth = 2;
                    context.moveTo(methodposX, methodposY);
                    context.strokeStyle = "blue"
                    context.lineTo(attributeposX, attributeposY);
                    context.stroke();
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

