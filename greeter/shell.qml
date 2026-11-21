// Nocturne login screen: the lock screen's sibling (see DESIGN.md).
// The wallpaper, blurred; the date and a large clock; your name, a line to
// type on, and one line below it for anything that needs saying. The session
// to start sits in the bottom-left corner when there is more than one.
//
// greetd starts it inside labwc, a small compositor that is there for this
// one window and for the touchpad: see nocturne/templates/greeter.sh and
// rc.xml. `nocturne greeter install` copies this
// folder to /etc/greetd/nocturne, because the greeter's user cannot read a
// home folder. `nocturne greeter preview` opens it in a window.

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Greetd
import Quickshell.Services.UPower

ShellRoot {
    id: shell

    // What starts after a successful login: session.sh, next to this file,
    // with the session picked in the bottom-left corner. Hyprland comes first
    // and is where every boot starts; the others appear when installed.
    // `env` reaches logind, which records the session's type the way GDM
    // would. Hyprland gets none, as it always has.
    readonly property var sessions: {
        const found = [{ id: "hyprland", name: "Hyprland", env: [] }];
        if (gnomeSession.text() !== "")
            found.push({ id: "gnome", name: "GNOME", env: ["XDG_SESSION_TYPE=wayland", "XDG_CURRENT_DESKTOP=GNOME", "XDG_SESSION_DESKTOP=gnome"] });
        if (i3Session.text() !== "" && startx.text() !== "")
            found.push({ id: "i3", name: "i3", env: ["XDG_SESSION_TYPE=x11", "XDG_CURRENT_DESKTOP=i3", "XDG_SESSION_DESKTOP=i3"] });
        return found;
    }
    property int sessionIndex: 0
    readonly property var session: sessions[sessionIndex] ?? sessions[0]

    // greetd joins these words into one shell line, so they are kept plain.
    function launch() {
        const command = ["sh", Quickshell.shellPath("session.sh"), session.id];
        if (session.env.length > 0)
            Greetd.launch(command, session.env);
        else
            Greetd.launch(command);
    }

    // Installed sessions, found by the files their packages install.
    FileView {
        id: gnomeSession
        path: "/usr/share/wayland-sessions/gnome.desktop"
        blockLoading: true
        printErrors: false
    }
    FileView {
        id: i3Session
        path: "/usr/share/xsessions/i3.desktop"
        blockLoading: true
        printErrors: false
    }
    FileView {
        id: startx
        path: "/usr/bin/startx"
        blockLoading: true
        printErrors: false
    }

    // People who can log in: regular accounts with a real shell.
    readonly property var users: {
        const found = [];
        for (const line of passwd.text().split("\n")) {
            const [name, , uid, , gecos, , loginShell] = line.split(":");
            if (uid >= 1000 && uid < 60000 && loginShell && !/(nologin|false)$/.test(loginShell))
                found.push({ name: name, label: (gecos || "").split(",")[0] || name });
        }
        return found;
    }
    property int userIndex: 0
    readonly property var user: users[userIndex] ?? null

    FileView {
        id: passwd
        path: "/etc/passwd"
        blockLoading: true
        printErrors: false
    }

    // ---- The conversation with greetd ---------------------------------
    // Enter sends the password. greetd may then ask something else (a
    // one-time code, a new password); that question takes the name's place
    // and the same field answers it.
    property string password: ""    // typed, not yet asked for
    property bool checking: false   // between Enter and the answer
    property bool slow: false       // still checking after a moment
    property string question: ""    // a follow-up question from greetd
    property bool showAnswer: false // whether the answer may be read on screen
    property string trouble: ""     // why it did not work
    property string notice: ""      // something greetd wants read
    property bool capsLock: false

    readonly property bool preview: !Greetd.available

    function submit(text) {
        if (question !== "") {
            question = "";
            checking = true;
            patience.restart();
            Greetd.respond(text);
            return;
        }
        if (checking || text === "" || user === null)
            return;
        trouble = "";
        notice = "";
        if (preview) {
            notice = "This is a preview. It cannot log you in.";
            field.clear();
            return;
        }
        password = text;
        checking = true;
        patience.restart();
        Greetd.createSession(user.name);
    }

    function settle() {
        password = "";
        question = "";
        showAnswer = false;
        checking = false;
        slow = false;
        patience.stop();
        field.clear();
        field.takeFocus();
    }

    function power(action) {
        if (preview) {
            notice = "This is a preview. The power buttons do nothing here.";
            return;
        }
        // The greeter's session may use the power keys; sudo is the fallback
        // for setups that allowed it there instead.
        Quickshell.execDetached(["sh", "-c", "systemctl " + action + " || sudo -n systemctl " + action]);
    }

    Timer {
        id: patience
        interval: 400
        onTriggered: shell.slow = true
    }

    Connections {
        target: Greetd

        function onAuthMessage(message, error, responseRequired, echoResponse) {
            if (!responseRequired) {
                if (error)
                    shell.trouble = message;
                else
                    shell.notice = message;
                return;
            }
            if (shell.password !== "") {
                const answer = shell.password;
                shell.password = "";
                Greetd.respond(answer);
                return;
            }
            shell.question = message.replace(/[:\s]+$/, "");
            shell.showAnswer = echoResponse;
            shell.checking = false;
            shell.slow = false;
            patience.stop();
            field.clear();
            field.takeFocus();
        }

        function onAuthFailure(message) {
            // greetd's own words are for logs. Keep what it said before
            // failing, such as a locked account, if it said anything.
            const said = shell.trouble;
            shell.settle();
            shell.trouble = said || "That password did not work.";
        }

        function onError(error) {
            shell.settle();
            shell.trouble = "Login is not working: " + error;
        }

        function onReadyToLaunch() {
            shell.launch();
        }
    }

    FloatingWindow {
        id: window
        title: "Nocturne login"
        color: Nocturne.ink0
        implicitWidth: 1536
        implicitHeight: 960
        // Only a preview window can be closed. Do not linger without one.
        onClosed: Qt.quit()

        Item {
            id: view
            anchors.fill: parent
            focus: true

            // Sizes are in units. A unit is one pixel at the scale the screen
            // has on the desktop, which outputs.sh sets before this starts,
            // so everything is the size it is on the lock screen.
            // If a tall screen was left unscaled (wlr-randr is missing), a
            // unit grows with the screen's height instead, so the login
            // screen is never tiny: 960 units tall, like the laptop at 2.
            readonly property real u: window.devicePixelRatio <= 1 && height > 1600 ? height / 960 : 1
            readonly property real hairline: Math.max(1, Math.round(u))

            // Motion: one curve and three durations (DESIGN.md).
            readonly property var settleCurve: [0.16, 1, 0.3, 1, 1, 1]
            readonly property int fast: 120

            // The wallpaper, already blurred and dimmed by greeter/background
            // so that every colour used over it stays readable.
            Image {
                anchors.fill: parent
                source: "background.png"
                fillMode: Image.PreserveAspectCrop
                smooth: true
            }

            // A click on the empty screen returns to the field.
            MouseArea {
                anchors.fill: parent
                onClicked: field.takeFocus()
            }

            // Typing while a button has the focus still reaches the field.
            Keys.onPressed: event => {
                if (event.text.length === 1 && event.text >= " " && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) {
                    field.takeFocus();
                    field.type(event.text);
                    event.accepted = true;
                }
            }

            SystemClock {
                id: clock
                precision: SystemClock.Minutes
            }

            Column {
                id: column
                anchors.horizontalCenter: parent.horizontalCenter
                // A little above the middle, where the eye rests.
                y: Math.round(parent.height * 0.44 - height / 2)
                width: 360 * view.u

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(clock.date, "ddd d MMM").toUpperCase()
                    color: Nocturne.text
                    font.family: "Lilex Nerd Font"
                    font.weight: Font.Medium
                    font.pixelSize: 15 * view.u
                    font.letterSpacing: 3 * view.u
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(clock.date, "HH:mm")
                    color: Nocturne.bright
                    // The Light face is registered as its own family.
                    font.family: "IBM Plex Sans Light"
                    font.pixelSize: 140 * view.u
                    renderType: Text.NativeRendering
                    // Pull the light digits in to their neighbours.
                    topPadding: -12 * view.u
                    bottomPadding: -16 * view.u
                }

                Item {
                    width: 1
                    height: 48 * view.u
                }

                // Whose password, or what greetd is asking for. With more
                // than one account, Up and Down change it.
                Text {
                    id: nameLabel
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    text: shell.question !== "" ? shell.question : (shell.user?.label ?? "No account can log in here")
                    color: Nocturne.text
                    font.family: "IBM Plex Sans"
                    font.pixelSize: 15 * view.u
                }

                Item {
                    width: 1
                    height: 8 * view.u
                }

                PasswordField {
                    id: field
                    anchors.horizontalCenter: parent.horizontalCenter
                    u: view.u
                    hairline: view.hairline
                    fast: view.fast
                    curve: view.settleCurve
                    name: nameLabel.text
                    busy: shell.checking
                    visibleAnswer: shell.showAnswer
                    onSubmitted: text => shell.submit(text)
                    onEdited: {
                        shell.trouble = "";
                        shell.notice = "";
                    }
                    onCapsLockSeen: on => shell.capsLock = on
                    onPreviousUser: if (!shell.checking && shell.users.length > 1) shell.userIndex = (shell.userIndex + shell.users.length - 1) % shell.users.length
                    onNextUser: if (!shell.checking && shell.users.length > 1) shell.userIndex = (shell.userIndex + 1) % shell.users.length
                }

                Item {
                    width: 1
                    height: 12 * view.u
                }

                // Room for two lines, always present, so nothing moves when it
                // speaks. What went wrong comes first, then a warning, then
                // progress.
                Text {
                    width: parent.width
                    height: 40 * view.u
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    lineHeight: 20 * view.u
                    lineHeightMode: Text.FixedHeight
                    elide: Text.ElideRight
                    text: shell.trouble || shell.notice || (shell.capsLock ? "Caps Lock is on" : shell.slow ? "Checking" : "")
                    color: shell.trouble ? Nocturne.red : shell.notice ? Nocturne.text : shell.capsLock ? Nocturne.gold : Nocturne.text
                    font.family: "IBM Plex Sans"
                    font.pixelSize: 13 * view.u
                }
            }

            // Battery, as on the lock screen.
            Text {
                readonly property var battery: UPower.displayDevice
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 24 * view.u
                height: 32 * view.u
                verticalAlignment: Text.AlignVCenter
                visible: battery !== null && battery.ready && battery.isLaptopBattery
                text: visible ? Math.round(battery.percentage * 100) + "%" + (battery.state === UPowerDeviceState.Charging ? " charging" : "") : ""
                color: Nocturne.text
                font.family: "Lilex Nerd Font"
                font.pixelSize: 13 * view.u
            }

            // The session, in the opposite corner to the power buttons. Only
            // there when there is a choice. Each press moves to the next one;
            // anything but Hyprland is gold, a mode you could forget you chose.
            PowerButton {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.leftMargin: 24 * view.u
                anchors.bottomMargin: 24 * view.u
                visible: shell.sessions.length > 1
                u: view.u
                hairline: view.hairline
                fast: view.fast
                curve: view.settleCurve
                hint: "Session"
                label: shell.session.name
                textColor: shell.sessionIndex === 0 ? Nocturne.text : Nocturne.gold
                description: "Session: " + shell.session.name + ". Press to change."
                onActivated: {
                    if (!shell.checking)
                        shell.sessionIndex = (shell.sessionIndex + 1) % shell.sessions.length;
                }
            }

            Row {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 24 * view.u
                anchors.bottomMargin: 24 * view.u
                spacing: 4 * view.u

                PowerButton {
                    u: view.u
                    hairline: view.hairline
                    fast: view.fast
                    curve: view.settleCurve
                    label: "Sleep"
                    onActivated: shell.power("suspend-then-hibernate")
                }
                PowerButton {
                    u: view.u
                    hairline: view.hairline
                    fast: view.fast
                    curve: view.settleCurve
                    label: "Restart"
                    onActivated: shell.power("reboot")
                }
                PowerButton {
                    u: view.u
                    hairline: view.hairline
                    fast: view.fast
                    curve: view.settleCurve
                    label: "Shut down"
                    onActivated: shell.power("poweroff")
                }
            }
        }
    }
}
