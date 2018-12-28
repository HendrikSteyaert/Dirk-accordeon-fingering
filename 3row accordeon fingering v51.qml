//______________________________________________________________________________________________
//
// v5.1.1 28.12.2018 by Hendrik Steyaert
// Based on inputs from Kris Bruggeman
//
// Write the accordeon fingering to a score according the Corgeron notation. 
// See http://www.accordeondiatonique.fr/comment-lire-une-tablature-accordeon-diatonique/ 
//______________________________________________________________________________________________

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import MuseScore 1.0

MuseScore {
    menuPath: "Plugins.Dirk 3 row accordeon"
    version: "5.1.1"
    description: qsTr("Add accordeon fingering to the score. Based on Dirk's 3 row accordeon layout.")
//    pluginType: "dialog"

    Window {
      id: window
      width: 450
      height: 180
      minimumWidth: 350
      minimumHeight: 170
      visible: false
      title: titleText
      
      onClosing: { Qt.quit();}
      
        
      Label {
        id: firstLabel
        text: 'Enter position of the first row (10-19.99)'
       // width: 100
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 10
        anchors.leftMargin: 10
        font.family: "Verdana"
        font.pointSize: 12
      }

      TextField {
        id: positionButtonOne
        text: "15.1"
        //placeholderText: qsTr("Enter pos")
        validator: RegExpValidator{regExp: /(1\d)([.]\d{1,2})?$/}
        anchors.right: parent.right
        anchors.verticalCenter: firstLabel.verticalCenter
        anchors.rightMargin: 10
        width: 50
        height: 25
      }

      Label {
        id: secondLabel
        text: 'Enter space between rows (1-4.99)'
 //       width: 25
        anchors.top: firstLabel.bottom
        anchors.left: parent.left
        anchors.topMargin: 10
        anchors.leftMargin: 10
        font.family: "Verdana"
        font.pointSize: 12
      }

      TextField {
        id: offsetRows
        text: "2.25"
        validator: RegExpValidator{regExp: /([1234])([.]\d{1,2})?$/}
        anchors.right: parent.right
        anchors.verticalCenter: secondLabel.verticalCenter
        anchors.rightMargin: 10
        width: 50
        height: 25
      }

      Label {
        id: thirdLabel
        text: 'Select the separater to use'
        anchors.top: secondLabel.bottom
        anchors.left: parent.left
        anchors.topMargin: 10
        anchors.leftMargin: 10
        font.family: "Verdana"
        font.pointSize: 12
      }

      ComboBox {
        id: separatorToUse
        model: ["/", "-", "\\", "+", "|"]
        anchors.right: parent.right
        anchors.verticalCenter: thirdLabel.verticalCenter
        anchors.rightMargin: 10
        width: 50
        height: 25
        Component.onCompleted: {
            currentIndex = 0
        }
//        onActivated: {
//           buttonOK.focus = true
//      }
      }

      Label {
        id: infoLabel
        text: 'This will write fingersettings below the staff.\nExisting annotations will be overwritten. '
       // width: 100
        anchors.top: separatorToUse.bottom
        anchors.left: parent.left
        anchors.topMargin: 10
        anchors.leftMargin: 10
        color: "steelblue"
        font.family: "Helvetica"
        font.italic: true
      }


      Rectangle {
        x: 8
        y: window.height - 35
        width: window.width - 16
        height: 1
        color: "steelblue"
      }

      Button {
        id: buttonOK
        isDefault: true
        width: 75
        text: qsTr("OK")
        anchors.bottom: parent.bottom
        anchors.right: buttonCancel.left
        anchors.bottomMargin: 5
        anchors.rightMargin: 5
        onClicked: {
            window.close();
            curScore.startCmd();
            applyToNotesInSelection(addButton);
//console.log("OK was pressed");
            curScore.endCmd();
            Qt.quit();
        }
      }

      Button {
        id: buttonCancel
        width: 75
        text: qsTr("Cancel")
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 5
        anchors.rightMargin: 5
        onClicked: {
            window.close();
            Qt.quit()
        }
      }
    } // Window

    function showMessageDialog(message, detailedText) {
      messageDialog.text = message
      messageDialog.detailedText = detailedText
      messageDialog.open()
      }

    MessageDialog {
      id: messageDialog
      title: titleText
      icon: StandardIcon.Warning
      text: ''
      detailedText: ''
      standardButtons: StandardButton.Ok
//        Component.onCompleted: visible = false
    }


property var bSeparator : separatorToUse.currentText;  /* separator used if 2 possible buttons have to be indicated on a line */
property var bPosition : (positionButtonOne.text * 1);  /* position under the staff to draw the buttons of the first row */
property var bOffset : (offsetRows.text * 1);    /* distance between the rows */
property var buttonFont : "\"Tahoma\"";
property var fontSize : "\"10\"";
property var buttonColor : "#000000"; /* see https://html-color.codes for codes to use */
property var keys :  ["","",""];  /* keys is used getKeys to store the buttonpositions */
property var titleText : "Dirk's 3 row accordeon."

/*=====================================================================================================
This function translates the note on the staff to the possible button(s) to press.
In midi, pitch 60 is the middle C (C4)
The 3 entries in keys, represent the three button rows on an accordeon.
The value of the entry indicates the button in that row counting from the top.
When the accordeon must be pulled to sound the note, add a 'T' to the note.
If there's more than 1 possibility to play the note on an accordeon row, the entry must start with a '*'
and the possibilities must be separated by a '-'.
This getKeys is based on the following layout

               row1         row2        row3
               P    T       P    T       P    T      (P=pousser, T= tirer)
            +----+----+  +----+----+  +----+----+
position 1  | G# | G# |  | E  | G  |  | Bb | Bb |
            +----+----+  +----+----+  +----+----+
position 2  | D  | F# |  | A  | B  |  | C# | C# |
            +----+----+  +----+----+  +----+----+
position 3  | G  | A  |  | C  | D  |  | Eb | Eb |
            +----+----+  +----+----+  +----+----+
position 4  | B  | C  |  | E  | F  |  | G# | G# |
            +----+----+  +----+----+  +----+----+
position 5  | D  | E  |  | A  | G  |  | Bb | Bb |
            +----+----+  +----+----+  +----+----+
position 6  | G  | F# |  | C  | B  |  | Eb | C# |
            +----+----+  +----+----+  +----+----+
position 7  | B  | A  |  | E  | D  |  | G# | C  |
            +----+----+  +----+----+  +----+----+
position 8  | D  | C  |  | G  | F  |  | Bb | G# |
            +----+----+  +----+----+  +----+----+
position 9  | G  | E  |  | C  | A  |  | Eb | Bb |
            +----+----+  +----+----+  +----+----+
position 10 | B  | F# |  | E  | B  |  | G# | C# |
            +----+----+  +----+----+  +----+----+
position 11 | D  | A  |  | F  | D  |
            +----+----+  +----+----+
position 12 | G  | C  |
            +----+----+

Example1: To play a C4 one can push the button on the 4th position of the first row while pulling
          the accordeon . Because C4 is pitch 60, fill in 4T in the first entry of keys for case 60.
          The same C4 can also be played by pushing the button on the 3th position of the second row
          while pushing the accordeon. Therefor 3 is entered in the second entry of keys for case 60.
Example2: G#4 can be played by pushing the button on the 4th position of the third row while pulling
          or pushing the accordeon . G#4 is pitch 68, therefor *4-4T must be filled in the 3th entry
          of keys for case 68.
         
=====================================================================================================*/
    function getKeys(pitch){
        switch(pitch){
            case 50: keys=["2",     "",     ""      ]; break; //D3
            case 51: keys=["",      "",     ""      ]; break; //Eb3
            case 52: keys=["",      "1",    ""      ]; break; //E3
            case 53: keys=["",      "",     ""      ]; break; //F3
            case 54: keys=["2T",    "",     ""      ]; break; //F#3
            case 55: keys=["3",     "1T",   ""      ]; break; //G3
            case 56: keys=["*1-1T", "",     ""      ]; break; //G#3
            case 57: keys=["3T",    "2",    ""      ]; break; //A3
            case 58: keys=["",      "",     "*1-1T" ]; break; //Bb3
            case 59: keys=["4",     "2T",   ""      ]; break; //B3
            case 60: keys=["4T",    "3",    ""      ]; break; //C4
            case 61: keys=["",      "",     "*2-2T" ]; break; //C#4
            case 62: keys=["5",     "3T",   ""      ]; break; //D4
            case 63: keys=["",      "",     "*3-3T" ]; break; //Eb4
            case 64: keys=["5T",    "4",    ""      ]; break; //E4
            case 65: keys=["",      "4T",   ""      ]; break; //F4
            case 66: keys=["6T",    "",     ""      ]; break; //F#4
            case 67: keys=["6",     "5T",   ""      ]; break; //G4
            case 68: keys=["",      "",     "*4-4T" ]; break; //G#4
            case 69: keys=["7T",    "5",    ""      ]; break; //A4
            case 70: keys=["",      "",     "*5-5T" ]; break; //Bb4
            case 71: keys=["7",     "6T",   ""      ]; break; //B4
            case 72: keys=["8T",    "6",    ""      ]; break; //C5
            case 73: keys=["",      "",     "6T"    ]; break; //C#5
            case 74: keys=["8",     "7T",   ""      ]; break; //D5
            case 75: keys=["",      "",     "6"     ]; break; //Eb5
            case 76: keys=["9T",    "7",    ""      ]; break; //E5
            case 77: keys=["",      "8T",   ""      ]; break; //F5
            case 78: keys=["10T",   "",     ""      ]; break; //F#5
            case 79: keys=["9",     "8",    "7T"    ]; break; //G5
            case 80: keys=["",      "",     "*7-8T" ]; break; //G#5
            case 81: keys=["11T",   "9T",   ""      ]; break; //A5
            case 82: keys=["",      "",     "8"     ]; break; //Bb5
            case 83: keys=["10",    "10T",  ""      ]; break; //B5
            case 84: keys=["12T",   "9",    ""      ]; break; //C6
            case 85: keys=["",      "",     "10T"   ]; break; //C#6
            case 86: keys=["11",    "11T",  ""      ]; break; //D6
            case 87: keys=["",      "",     "9"     ]; break; //Eb6
            case 88: keys=["",      "10",   ""      ]; break; //E6
            case 89: keys=["",      "11",   ""      ]; break; //F6
            case 90: keys=["",      "",     ""      ]; break; //F#6
            case 91: keys=["12",    "",     ""      ]; break; //G6
            case 92: keys=["",      "",     "10"    ]; break; //G#6
            case 93: keys=["",      "",     ""      ]; break; //A6
            case 94: keys=["",      "",     "9T"    ]; break; //Bb6
            case 95: keys=["",      "",     ""      ]; break; //B6
            default: keys=["","",""];
        }
    }
/*=====================================================================================================
This function checks fromatst the button text. 
If the string ends in 'T', remove the T and underline the string.
Add font parameters.
=====================================================================================================*/
    function formatButton (temp) { 
        var tempChanged; 
        if (temp.substr(temp.length-1,1)==="T") {
            tempChanged= "<font face="+buttonFont+"><font size="+fontSize+"><u> "+temp.substr(0, temp.length-1)+" </u></font>"; 
        } else { 
            tempChanged= "</u><font face="+buttonFont+"><font size="+fontSize+"> "+temp+" </font>"; 
        } 
    return tempChanged; 
    } 

/*=====================================================================================================
Function to extract the different parts from the keys entry and put them into the button text
=====================================================================================================*/
    function getButtonText(temp) {
        var buttonText, hyphenPosition, buttonFirstOption, buttonSecondOption;
        var buttonText;
        if (temp.substr(0,1)==="*") {           //If the entry starts with an asterix 
            hyphenPosition = temp.search("-");  //Find the position of the hyphen
            if (hyphenPosition===-1) // this should not happen but just in case. 
            {  
                hyphenPosition = temp.length; 
            } 
        buttonFirstOption = temp.substr(1, (hyphenPosition-1)); 
        buttonSecondOption = temp.substr((hyphenPosition+1), temp.length-1); 
        buttonText = formatButton(buttonFirstOption)+bSeparator+formatButton(buttonSecondOption); 
        } else { 
            buttonText = formatButton(temp);
        } 
        return buttonText;
   }
    
/*=====================================================================================================
This function places the number of the button(s) to press in the staff text of a chord.    
=====================================================================================================*/
    function addButton(cursor, note) {
        var pitch = note.pitch;
        var buttonExists = false;
        var skip = false;
        
        getKeys(pitch, keys); //Get the possible button positions for this specific tonepitch.
//console.log("pitch = "+pitch+" :key0 = "+keys[0]+" :key1 = "+keys[1]+" :key2 = "+keys[2]);
       /* If there are no annotations for this chord, skip the check to replace the existing annotations
          for the complete for loop.
       */
         if (cursor.segment.annotations.length === 0) {
            var skip = true;
        }
        //Write the fingering of the buttons below the staff
        for (var j=0 ; j<keys.length ; j++) {
        
            var buttonText = getButtonText(keys[j]);
            
            if (!skip){
            //If there is at least 1 annotation for this chord, we enter here.
                buttonExists = false;
//console.log("\t j = "+j+"  annotations do exist. length = "+cursor.segment.annotations.length);
                for (var i=0; i<cursor.segment.annotations.length ; i++) {
                    /* Check if there's already a button annotated in the score
                       This is not a foolproof method but it's the best i can do with the current API.
                       The reason i am substracting 1.5 from the y position is because Musescore seems to add 1.5 to the position when you read it out. Don't ask me why.
                    */
                    var pos = cursor.segment.annotations[i].pos.y-1.5;
                    var posmin = bPosition - j*bOffset - bOffset/4;
                    var posmax = bPosition -j*bOffset + bOffset/4;
//console.log("\t i = "+i+" position = "+pos+": max = "+posmax+": min = "+posmin);
                    if (pos > posmin && pos < posmax){
                        //An element already exists around this position. Overwrite it.
                        cursor.segment.annotations[i].text= buttonText;
//console.log("\tOVERWRITE i = "+i+" :text = "+buttonText);
                        buttonExists = true;
                    } // endif
                } //end for
            } // endif

            if (!buttonExists){
                var newButton = newElement(Element.STAFF_TEXT);
                newButton.text = buttonText;
                newButton.pos.y = bPosition-j*bOffset;
                newButton.pos.x = -1;
                newButton.color = buttonColor;
                cursor.add(newButton);
//console.log("\tNEW j = "+j+" :position = "+newButton.pos.y+" :text = "+buttonText);                
            }
        } //end for loop
   }
    
/*=====================================================================================================
Main entry point.    
=====================================================================================================*/
    function applyToNotesInSelection(funktie) {

    var cursor = curScore.newCursor()
    var startStaff;
    var endStaff;
    var endTick;
    var fullScore = false;
//console.log("separator = "+bSeparator+" : pos = "+bPosition+" : offset = "+bOffset);

    cursor.rewind(1);
    if (!cursor.segment) {
        // Nothing was selected on the score
        fullScore = true;
        startStaff = 0;                  // start with 1st staff
        endStaff = curScore.nstaves - 1; // and end with last
    } else {
        startStaff = cursor.staffIdx
        cursor.rewind(2)                 //go to end of selection
        if (cursor.tick == 0) {
            /* this happens when the selection includes
               the last measure of the score.
               rewind(2) goes behind the last segment (where
               there's none) and sets tick=0
            */
            endTick = curScore.lastSegment.tick + 1
        } else {
            endTick = cursor.tick
        }
        endStaff = cursor.staffIdx
    } //endif
    
//console.log("Staff from = "+startStaff + " till  " + endStaff + ": last tick = " + endTick)

       for (var staff = startStaff; staff <= endStaff; staff++) {
          /* No need to do this for all 4 voices
          for (var voice = 0; voice < 4; voice++) {
             cursor.voice = voice
          */
//console.log("staff = "+staff);     
          cursor.rewind(1) // beginning of selection
          cursor.staffIdx = staff

          // If nothing was selected, set cursor at the beginning of the score.
          if (fullScore) cursor.rewind(0);

          while (cursor.segment && (fullScore || cursor.tick < endTick)) {
              if (cursor.element && cursor.element.type == Element.CHORD) {
                  var graceChords = cursor.element.graceNotes
                  for (var i = 0; i < graceChords.length; i++) {
                      // iterate through all grace chords
                      var notes = graceChords[i].notes
                      funktie(cursor, notes[0])
                  }
                  var notes = cursor.element.notes
//console.log("-->tick = "+cursor.tick);                        
                  funktie(cursor, notes[0])
              } // end if CHORD
              cursor.next()
          } // end while segment
//        } // end for voice
        } // end for staff
    } //end applyToNotesInSelection
        
    onRun: {
        if (!curScore) {
            Qt.quit()
            showMessageDialog('Geen partituur open', 'Open een partituur en probeer het dan nog eens😉')
        } else {
            window.visible = true;
            window.requestActivate(); // Make this the active window.
        }
        
    }
}
