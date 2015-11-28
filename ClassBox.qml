import QtQuick 2.0

Item {
    id: root
    property alias title: titleText.text
    property double zoom: 6
    property var methods: ListModel{
        id:listMethods
        ListElement{
            name:"blabla"
            visibility:"machin"
        }
        ListElement{
            name:"method"
            visibility:"public2"
        }
    }//dataModel.queryMethods(title)


    /*states: [State {name: "zeroZoom"
                    when: zoom > 5},
             State {name: "firstZoom"
                    when: zoom <= 5 && zoom > 2.5},
             State {name: "secondZoom"
                    when: zoom <= 2.5}]*/




    property var attributes: ListModel{
        id:listAttributes
        ListElement{
            name:"blabla"
            type:"public"
        }
        ListElement{
            name:"method"
            type:"truc"
        }
    }//dataModel.queryAttributes(title)

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
                //visible: states == "zeroZoom"
                width: titleContainer.width / 2
                id: attributesContainer
                Repeater{
                    model: attributes
                    delegate:
                        Row{
                        Text{
                            text: name + ":"+ type
                        }
                    }
                }
            }
            Column{
                width: titleContainer.width / 2//states == "zeroZoom" ? (titleContainer.width / 2) : titleContainer.width
                //visible: !states == "secondZoom"
                id: methodsContainer
                Repeater{
                    model: methods
                    delegate:
                        Row{
                        Text{
                            text: name + ":" + visibility//states == "oneZoom" ? (visibility == "public" ? name : "") : name + ":" + visibility
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

