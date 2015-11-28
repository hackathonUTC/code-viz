import QtQuick 2.0

Item {
    id: root
    property alias title: titleText.text
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


/*    states: [State {name: "zeroZoom"},
             State {name: "firstZoom"},
             State {name: "secondZoom"}]
*/
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
                width: titleContainer.width / 2
                id: attributesContainer
                //color: "green"
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
                width: titleContainer.width / 2
                id: methodsContainer
                //color: "green"
                Repeater{
                    model: methods
                    delegate:
                        Row{
                        Text{
                            text: name + ":"+ visibility
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

