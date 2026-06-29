import QtQuick.LocalStorage 2.0
import Ubuntu.Components 1.3 as UBC
import QtQuick.Window 2.8
import Ubuntu.Content 1.3
import QtQuick 2.9
import QtQuick.Controls 2.9

UBC.MainView {
    id: appWindow
    applicationName: "justnote.pparent"
    visible: true
    
    property int currentNoteId: -1  // -1 = pas de note active
    property bool disableCommit: false

    // --- Base de données ---
    Component.onCompleted: {
        var db = LocalStorage.openDatabaseSync("NotesDB", "1.0", "Notes DB", 10000)
        db.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS notes(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, content TEXT)")
        })
        noteInput.forceActiveFocus()
    }

    // --- PAGE PRINCIPALE ---
    Item {
        anchors.bottomMargin:  UbuntuApplication.inputMethod.visible ? UbuntuApplication.inputMethod.keyboardRectangle.height/(units.gridUnit / 8) : 0
        anchors.fill: parent
        id: mainPage

        // Bouton historique stylé
    Button {
    id: buttonHistory
    height: units.gu(6)
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top


    contentItem:Item {
        anchors.fill: parent   // occupe toute la surface du bouton
        Row {            // ← contenu = icône + texte
        spacing: 8 
        anchors.margins: 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        
        Image {
            id: mynotesimage
            source: "Icons/mynotes.png"
            width: units.gu(3.6)
            height: units.gu(3.6)
            fillMode: Image.PreserveAspectFit
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: mynotestext
            text: qsTr("My notes")
            color: "black"
            font.pixelSize: 16
            font.bold: true       // rend le texte gras
            anchors.verticalCenter: parent.verticalCenter
        }
       }
    }
     onClicked: {loadNotes(); historyPage.visible = true; mainPage.visible = false; }
    }

        UBC.TextArea {
            id: noteInput
            focus: true
            property bool changed;
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: buttonHistory.bottom   // ← corrigé
            anchors.bottom: parent.bottom
            placeholderText: "Type your note here..."
            wrapMode: Text.Wrap
            font.pixelSize: 18
            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoEditMenu
            
            onTextChanged: {
                changed=true;
                statusIcon.source="Icons/save-orange.png"  
                if ( disableCommit != true )
                {
                var db = LocalStorage.openDatabaseSync("NotesDB", "1.0", "Notes DB", 10000)
                if (text.length === 0) {
                    if (currentNoteId > 0) {
                        db.transaction(function(tx) {
                            tx.executeSql("DELETE FROM notes WHERE id = ?", [currentNoteId])
                        })
                        currentNoteId = -1
                    }
                } else {
                    if (currentNoteId < 0) {
                        var now = new Date().toLocaleString()
                        db.transaction(function(tx) {
                            tx.executeSql("INSERT INTO notes(date, content) VALUES (?, ?)", [now, text])
                            var res = tx.executeSql("SELECT last_insert_rowid() AS id")
                            currentNoteId = res.rows.item(0).id
                        })
                    } else {
                        db.transaction(function(tx) {
                            tx.executeSql("UPDATE notes SET content = ? WHERE id = ?", [text, currentNoteId])
                        })
                    }
                }
              }
            }
        }
                        // --- BARRE D’ACTIONS EN BAS ---
                Rectangle {
                    id: bottomBar
                    height: units.gu(4.75)
                    width: parent.width
                    color: "#333"
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    z: 200

                    // --- BOUTON AJOUTER ---
                    Button {
                        id: addButton
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        
                        background: null      // ← enlève tout le fond
                        padding: 0            // ← enlève les marges internes

                        contentItem: Image {  // ← contenu = icône PNG
                        source: "Icons/New.png"
                        width: units.gu(2.85)
                        height: units.gu(2.85)
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width: units.gu(2.85)
                        sourceSize.height: units.gu(2.85)
                        }

                        onClicked: {
                                var oldid=currentNoteId;
                                currentNoteId = -1
                                var db = LocalStorage.openDatabaseSync("NotesDB", "1.0", "Notes DB", 10000)
                                        if (oldid < 0) {
                                            var now = new Date().toLocaleString()
                                            db.transaction(function(tx) {
                                                var res=tx.executeSql("INSERT INTO notes(date, content) VALUES (?, ?)", [now, noteInput.text])
                                                noteInput.text = ""
                                                noteInput.focus = true 
                                            })
                                        } else {
                                            db.transaction(function(tx) {
                                                tx.executeSql("UPDATE notes SET content = ? WHERE id = ?", [noteInput.text, oldid])
                                                noteInput.text = ""
                                                noteInput.focus = true 
                                            })
                                        }
  
                                 
                        }
                    }

                    // --- BOUTON SUPPRIMER ---
                    Button {
                        id: deleteButton
                        anchors.left: addButton.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                                
                                
                        background: null      // ← enlève tout le fond
                        padding: 0            // ← enlève les marges internes

                        contentItem: Image {  // ← contenu = icône PNG
                        source: "Icons/trash.png"
                        width: units.gu(2.85)
                        height: units.gu(2.85)
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width: units.gu(2.85)
                        sourceSize.height: units.gu(2.85)
                        }
                        
                        onClicked: {
                            if (currentNoteId > 0) {
                                var db = LocalStorage.openDatabaseSync("NotesDB", "1.0", "Notes DB", 10000)
                                db.transaction(function(tx) {
                                    tx.executeSql("DELETE FROM notes WHERE id = ?", [currentNoteId])
                                })
                                noteInput.text = ""
                                currentNoteId = -1
                            }
                        }
                    }

                    // --- ICÔNE STATUT (DISQUETTE) ---
                        Image {  // ← contenu = icône PNG
                        id: statusIcon
                        source: "Icons/save-green.png"  
                        width: units.gu(2.85)
                        height: units.gu(2.85)
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width: units.gu(2.85)
                        sourceSize.height: units.gu(2.85)
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        }
                }
    }
    
    Timer {
    id: myTimer
    interval: 1000        // 1000 ms = 1 seconde
    running: true         // démarre automatiquement
    repeat: true          // boucle indéfiniment

    onTriggered: {
          var db = LocalStorage.openDatabaseSync("NotesDB", "1.0", "Notes DB", 10000);
          db.transaction(function(tx) {
          var res = tx.executeSql("SELECT * FROM notes WHERE id = ?", [currentNoteId]);
           if (res.rows.length >= 1 )
           {
                var row = res.rows.item(0);
                if ( row.content == noteInput.text )
                {
                     statusIcon.source="Icons/save-green.png"  
                }
                else
                {
                    statusIcon.source="Icons/save-red.png"  
                }
           }
           else
           {
               if ( noteInput.text == "" )
               {
                    statusIcon.source="Icons/save-green.png"  
               }
               else
               {
                    statusIcon.source="Icons/save-red.png" 
               }
           }
          })

        }
    }


    // --- PAGE HISTORIQUE ---
    Item {
        id: historyPage
        visible: false
        anchors.fill: parent

        // Bouton retour stylé
        Button {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            id: back
            height: units.gu(6)


            contentItem:Item {
                anchors.fill: parent   // occupe toute la surface du bouton
                Row {            // ← contenu = icône + texte
                spacing: 8 
                anchors.margins: 0
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                
                Image {
                    source: "Icons/New-black.png"
                    width: units.gu(3.6)
                    height: units.gu(3.6)
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: i18n.tr("New Note")
                    color: "black"
                    font.pixelSize: 16
                    font.bold: true       // rend le texte gras
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            }
            
            onClicked: {
                                    currentNoteId = -1
                                    noteInput.text = ""
                                    historyPage.visible = false; mainPage.visible = true; noteInput.focus = true 
                        }
        }


        Flickable {
            id: flick
            clip: true
            anchors.top: back.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            contentHeight: notesList.implicitHeight

            Column {
                id:notesList
                width: parent.width
                spacing: units.gu(2)
                padding: units.gu(1)  // ← simplifié
            }
        }
    }

    function loadNotes() {
        // Vider la liste
        for (var i = notesList.children.length - 1; i >= 0; i--)
            notesList.children[i].destroy();

        var db = LocalStorage.openDatabaseSync("NotesDB", "1.0", "Notes DB", 10000);

        // Charger les notes depuis la base de données
        db.readTransaction(function(tx) {
            var res = tx.executeSql("SELECT * FROM notes ORDER BY id DESC");

            // Créer un composant Note.qml
            var noteComponent = Qt.createComponent("Note.qml");
            if (noteComponent.status === Component.Error) {
                console.log("Erreur lors du chargement de Note.qml:", noteComponent.errorString());
                return;
            }

            for (var i = 0; i < res.rows.length; i++) {
                var row = res.rows.item(i);

                // Créer un objet Note.qml et définir ses propriétés
                var noteObject = noteComponent.createObject(notesList, {
                    date: row.date,
                    content: row.content,
                    id: "note_" + row.id, // optionnel pour debug
                    rowid:row.id
                });

                if (noteObject === null) {
                    console.log("Erreur lors de la création de la note ", row.id);
                    continue;
                }
                // Tu peux aussi connecter les boutons ici si tu veux gérer via JS
            }
        });
    }


    

}
