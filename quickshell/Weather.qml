// Current weather from Open-Meteo (no account or API key), shared by every screen.
// The location is personal, so it lives outside the repo in
// ~/.config/nocturne-location.json; location.example.json shows the format.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // One line for the desktop, or "" until the first answer arrives.
    property string summary: ""

    readonly property string locationPath: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/nocturne-location.json"

    FileView {
        id: location
        path: root.locationPath
        watchChanges: true
        printErrors: false
        onLoaded: root.refresh()
        onFileChanged: reload()
    }

    // Every 30 minutes, or 5 minutes after a failure.
    Timer {
        id: timer
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    function describe(code) {
        if (code === 0) return "Clear";
        if (code === 1) return "Mostly clear";
        if (code === 2) return "Partly cloudy";
        if (code === 3) return "Overcast";
        if (code === 45 || code === 48) return "Fog";
        if (code >= 51 && code <= 57) return "Drizzle";
        if (code === 61 || code === 80) return "Light rain";
        if (code === 63 || code === 81) return "Rain";
        if (code === 65 || code === 82) return "Heavy rain";
        if (code === 66 || code === 67) return "Freezing rain";
        if ((code >= 71 && code <= 77) || code === 85 || code === 86) return "Snow";
        if (code >= 95) return "Thunderstorm";
        return "";
    }

    function refresh() {
        let place;
        try {
            place = JSON.parse(location.text());
        } catch (e) {
            root.summary = "";
            return;
        }
        if (place.latitude === undefined || place.longitude === undefined)
            return;

        const url = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + place.latitude + "&longitude=" + place.longitude
            + "&current=temperature_2m,weather_code"
            + "&daily=temperature_2m_max,temperature_2m_min&forecast_days=1"
            + "&timezone=" + encodeURIComponent(place.timezone || "auto");

        const request = new XMLHttpRequest();
        request.onreadystatechange = () => {
            if (request.readyState !== XMLHttpRequest.DONE)
                return;
            try {
                const data = JSON.parse(request.responseText);
                const now = Math.round(data.current.temperature_2m);
                const high = Math.round(data.daily.temperature_2m_max[0]);
                const low = Math.round(data.daily.temperature_2m_min[0]);
                const sky = root.describe(data.current.weather_code);
                root.summary = now + "°" + (sky ? " " + sky : "") + "  ·  high " + high + "°, low " + low + "°";
                timer.interval = 30 * 60 * 1000;
            } catch (e) {
                timer.interval = 5 * 60 * 1000;
            }
        };
        request.open("GET", url);
        request.send();
    }
}
