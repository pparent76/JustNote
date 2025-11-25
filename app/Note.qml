import QtQuick 2.9
import QtQuick.Controls 2.9
import QtQuick.LocalStorage 2.0

Rectangle {
    id: mainRect
    width: parent ? parent.width - units.gu(2): 200
    color: "#ffec20"
    radius: 10
    property var date
    property var content
    property var rowid


        Text {
            id: text1
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top:parent.top
            anchors.leftMargin:  units.gu(1.5)
            anchors.topMargin:  units.gu(1.5)
            text: "🕓 " + date
            font.bold: true
            font.pixelSize: 13
            color: "#6d6d6d"
            wrapMode: Text.Wrap
        }

        TextArea {
            id: text2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: lowrect.top
            anchors.rightMargin:  units.gu(0.5)
            anchors.leftMargin:  units.gu(0.5)
            anchors.bottomMargin:  units.gu(1)
            text: content
            font.pixelSize: 15
            font.italic: true
            readOnly: true
            wrapMode: TextEdit.Wrap
            color: "#222222"
            background: Rectangle { color: "transparent" }
            width: parent.width
        }

                Rectangle {
                    color:"#ffdd33"
                    height:units.gu(4.76)
                    width: parent.width
                    id:lowrect
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom:parent.bottom
                
                        
                    
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right 
                        anchors.rightMargin:  units.gu(0.7)
                        id: buttons
                        spacing: units.gu(0.8)

                        ToolButton {
                            id:toolButton1
                           contentItem: Image {
                                source:  "Icons/clipboard.png"
                                width: toolButton1.hovered || toolButton1.pressed ? units.gu(3): units.gu(2.5)
                                height: toolButton1.hovered || toolButton1.pressed ? units.gu(3): units.gu(2.5)
                                fillMode: Image.PreserveAspectFit
                                sourceSize.width: toolButton1.hovered || toolButton1.pressed ? units.gu(3): units.gu(2.5)
                                sourceSize.height: toolButton1.hovered || toolButton1.pressed ? units.gu(3): units.gu(2.5)
                                smooth: true   // interpolation haute qualité
                            }
                            onClicked: {                
                                textEdit.text  = text2.text
                                textEdit.selectAll()
                                textEdit.copy()
                                toast.show("Note copied to clipboard!") 
                                btn.checked = false
                            }
                            background: none;
                        }
                        ToolButton {
                            contentItem: Image {
                                        source:  "Icons/trash-grey.png"
                                        width: units.gu(2.5)
                                        height: units.gu(2.5)
                                        fillMode: Image.PreserveAspectFit
                                        sourceSize.width: units.gu(2.5)
                                        sourceSize.height: units.gu(2.5)                                        
                                        smooth: true   // interpolation haute qualité
                                    }
                            onClicked: {
                                var db = LocalStorage.openDatabaseSync("NotesDB", "1.0", "Notes DB", 10000)
                                db.transaction(function(tx) { tx.executeSql("DELETE FROM notes WHERE id = ?", [rowid]) })
                                mainRect.destroy()
                            }
                            background: none;
                        }
                        ToolButton {
                        contentItem: Image {
                                        source:  "Icons/edit.png"
                                        width: units.gu(2.5)
                                        height: units.gu(2.5)
                                        fillMode: Image.PreserveAspectFit
                                        sourceSize.width: units.gu(2.5)
                                        sourceSize.height: units.gu(2.5)                                        
                                        smooth: true   // interpolation haute qualité
                                    }
                         onClicked: {
                                currentNoteId = rowid
                                noteInput.text = text2.text
                                historyPage.visible = false; 
                                mainPage.visible =true;
                                noteInput.focus = true 
                          }
                          background: none;
                        }
                        ToolButton {
                        contentItem: Image {
                                        source:  "Icons/fork.png"
                                        width: units.gu(2.5)
                                        height: units.gu(2.5)
                                        fillMode: Image.PreserveAspectFit
                                        sourceSize.width: units.gu(2.5)
                                        sourceSize.height: units.gu(2.5)                                       
                                        smooth: true   // interpolation haute qualité
                                    }
                            onClicked: {
                                var db = LocalStorage.openDatabaseSync("NotesDB", "1.0", "Notes DB", 10000)
                                db.transaction(function(tx) {
                                    var now = new Date().toLocaleString()
                                    tx.executeSql("INSERT INTO notes(date, content) VALUES (?, ?)", [now, text2.text])
                                    var res = tx.executeSql("SELECT last_insert_rowid() AS id")
                                    currentNoteId = res.rows.item(0).id
                                    noteInput.text = text2.text
                                    historyPage.visible = false; mainPage.visible = true; noteInput.focus = true 
                                })
                                loadNotes()
                            }
                           background: none; 
                        }
                    }
                    }
                    
         height: text1.implicitHeight+text2.implicitHeight+lowrect.height + units.gu(2.5)
         
         
    //Dummy textedit to me able to copy to ClipBoard
     TextEdit{
        id: textEdit
        visible: false
      }
      
    Toast {
    id: toast
    }

}
