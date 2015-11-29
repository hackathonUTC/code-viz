import QtQuick 2.0
import codeviz 1.0

Item {
    id: root

    height: classContent.height
    clip: true
    property real baseSize: 25
    property real coefficientSize: baseSize + centralityCoefficient * baseSize
    property real centralityCoefficient: 1.0
    property double zoom: 1.0

    property alias title: classNamePlaceHolder.text
    property alias inheritsListModel:inheritageListModel
    property alias callOutsideListModel: callOutsideListModel

    property var focusedMethod: ""


    Behavior on width {
        NumberAnimation { }
    }

    Behavior on height {
        NumberAnimation { }
    }

    Rectangle {
        color: "grey"
        opacity: 0.5
        anchors.fill: parent
    }

    ListModel {
        id: lineList;
    }

    function getAttributePoint(attrName)
    {
        for(var i = 0 ; i < attributeRepeater.model.count ; ++i)
        {
            if(attributeRepeater.itemAt(i).attributeName === attrName)
            {
                return attributeRepeater.itemAt(i);
            }
        }
    }

    function getMethodPoint(methodName)
    {
        for(var i = 0 ; i < methodRepeater.model.count ; ++i)
        {
            if(methodRepeater.itemAt(i).methodName === methodName)
            {
                return methodRepeater.itemAt(i);
            }
        }
    }

    function refreshLinks()
    {
        console.log(referenceListModel.count)
        lineList.clear();
        for(var i = 0 ; i < referenceListModel.count ; ++i)
        {
            var ref = referenceListModel.get(i);
            var methodObj = getMethodPoint(ref.method);
            var attrObj = getAttributePoint(ref.attribute)

            var pointFrom = mapToItem(attributeRepeater, attrObj.x + attrObj.width, attrObj.y + contentContainer.height)
            var pointTo = mapToItem(methodRepeater, methodObj.x + root.width/2, methodObj.y + contentContainer.height)
            console.log("***************" + pointFrom.x + " " + pointFrom.y + " " + pointTo.x + " " + pointTo.y)

            lineList.append({
                           "fromX":pointFrom.x,
                           "fromY":pointFrom.y,
                           "toX":pointTo.x,
                           "toY":pointTo.y
                       });
        }
    }

    Component.onCompleted: {
        methodListModel.append(DataModel.queryMethods(root.title))
        attributeListModel.append(DataModel.queryAttributes(root.title))
        callInsideListModel.append(DataModel.queryCallsInsideClass(root.title))
        callOutsideListModel.append(DataModel.queryCallsOutsideClass(root.title))
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
                referenceListModel.append(tmp[j++])
            }
        } // Ranger les noms de fonction 1 à 1 dans la ListModel
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
        id: callOutsideListModel
    }

    ListModel {
        id: inheritageListModel
    }

    states: [
        State {
            name: "zeroZoom"
            when: zoom > 3
            PropertyChanges {
                target: root
                width: 450 // Math.min(classNamePlaceHolder.implicitWidth, 400)
            }
        },
        State {
            name: "firstZoom"
            when: zoom <= 3 && zoom > 2
            PropertyChanges {
                target: root
                width: 300 // Math.min(classNamePlaceHolder.implicitWidth, 300)
            }
        },
        State {
            name: "secondZoom"
            when: zoom <= 2
            PropertyChanges {
                target: root
                width: Math.min(classNamePlaceHolder.implicitWidth, 200)
            }
        }
    ]

    Column {
        id: classContent
        anchors.left: parent.left
        anchors.right: parent.right

        Rectangle {
            id: titleContainer
            anchors.left: parent.left
            anchors.right: parent.right
            height: coefficientSize
            color: "steelblue"
            opacity: 0.8
            Text {
                id: classNamePlaceHolder
                anchors.fill: parent
                elide: Text.ElideRight
                font.pixelSize: titleContainer.height - 10
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Row {
            id: classRow
            height: attributesContainer.height > methodsContainer.height
            ? attributesContainer.height
            : methodsContainer.height
            Column {
                id: attributesContainer
                visible: opacity > 0.0
                opacity: root.state === "zeroZoom" ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation {}
                }

                width: root.state === "zeroZoom" ? titleContainer.width / 2 : 0

                onWidthChanged: refreshLinks();

                Repeater{
                    id: attributeRepeater
                    model: attributeListModel
                    width: parent.width
                    delegate:
                        Row {
                        width: parent.width
                        property string attributeName: name
                        Text {
                            text: name + ":"+ type
                            width: parent.width
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
            Column {
                id: methodsContainer
                width: /*titleContainer.width / 2*/ root.state === "zeroZoom" ? titleContainer.width / 2 : titleContainer.width
                visible: opacity > 0.0
                opacity: !(root.state === "secondZoom") ? 1.0 : 0.0
                Behavior on opacity {
                    NumberAnimation {}
                }

                Repeater {                    
                    id: methodRepeater
                    model: methodListModel
                    width: parent.width
                    delegate:
                        Row {
                        property string methodName: name
                        width: parent.width
                        Text {
                            id: textField
                            font.pixelSize: 15
                            width: parent.width
                            text: root.state === "firstZoom" ? (visibility === "public" ? name : "") : name + ":" + visibility
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            color: methodName == root.focusedMethod ? "red" : "black"
                        }
                    }
                }
            }
        }
    }

    Repeater {
        id:linksRepeater
        model: lineList
        anchors.fill: parent;
        delegate: Rectangle {
            id: rec

            transform: Rotation {
                angle: Math.atan((toY - fromY)/(toX - fromX))*180/Math.PI
            }

            x: fromX
            y: fromY
            z: classContent.z + 1
            height: 2
            color: "green"
            width: Math.sqrt((fromX - toX)*(fromX - toX) + (fromY - toY)*(fromY - toY))


        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.debug("Click on box " + title)
        }
    }
}

