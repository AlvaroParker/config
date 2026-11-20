// The line you type on. No box: a hairline that takes the accent while the
// field has the focus, and a dot per character above it, as on the lock
// screen. A hidden TextInput does the editing, so the usual keys work.

import QtQuick

Item {
    id: root

    required property real u
    required property real hairline
    required property int fast
    required property var curve

    property string name: ""            // what this field is for, read aloud
    property bool busy: false           // waiting for an answer: no typing
    property bool visibleAnswer: false  // show the text itself, not dots

    signal submitted(string text)
    signal edited
    signal capsLockSeen(bool on)
    signal previousUser
    signal nextUser

    function clear() {
        input.clear();
    }
    function takeFocus() {
        input.forceActiveFocus();
    }
    function type(text) {
        if (!busy)
            input.insert(input.length, text);
    }

    width: 280 * u
    height: 32 * u

    TextInput {
        id: input
        anchors.fill: parent
        opacity: 0
        focus: true
        readOnly: root.busy
        echoMode: root.visibleAnswer ? TextInput.Normal : TextInput.Password
        inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
        activeFocusOnTab: true
        Accessible.role: Accessible.EditableText
        Accessible.name: root.name
        Accessible.passwordEdit: !root.visibleAnswer

        onTextEdited: root.edited()
        onAccepted: root.submitted(text)

        Keys.onPressed: event => {
            // There is no direct way to ask for Caps Lock here, but a letter
            // gives it away: upper case without Shift, or lower case with it.
            if (event.text.length === 1 && event.text.toLowerCase() !== event.text.toUpperCase()) {
                const upper = event.text === event.text.toUpperCase();
                const shift = (event.modifiers & Qt.ShiftModifier) !== 0;
                root.capsLockSeen(upper !== shift);
            }
            if (event.key === Qt.Key_Escape) {
                input.clear();
                root.edited();
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                root.previousUser();
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                root.nextUser();
                event.accepted = true;
            }
        }
    }

    // One dot per character. The gap closes up for long passwords, so the
    // row always fits and every keypress still shows.
    Row {
        id: dots
        readonly property real size: 8 * root.u
        readonly property int count: root.visibleAnswer ? 0 : input.length
        anchors.centerIn: parent
        spacing: count > 1 ? Math.min(size, (root.width - count * size) / (count - 1)) : 0

        Repeater {
            model: dots.count

            Rectangle {
                width: dots.size
                height: dots.size
                radius: dots.size / 2
                // Gold while the password is being checked, as on the lock screen.
                color: root.busy ? Nocturne.gold : Nocturne.accent
            }
        }
    }

    // Answers that may be read, such as a one-time code.
    Text {
        anchors.centerIn: parent
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideLeft
        visible: root.visibleAnswer
        text: input.text
        color: Nocturne.bright
        font.family: "Lilex Nerd Font"
        font.pixelSize: 15 * root.u
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: root.hairline
        color: input.activeFocus ? Nocturne.accent : Nocturne.line

        Behavior on color {
            ColorAnimation {
                duration: root.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.curve
            }
        }
    }
}
