import QtQuick

QtObject {
    id: palette

    property color base: "#1e1e2e"
    property color crust: "#11111b"
    property color text: "#cdd6f4"
    property color subtext0: "#a6adc8"
    property color overlay2: "#9399b2"
    property color surface0: "#313244"
    property color surface1: "#45475a"
    property color surface2: "#585b70"
    property color mauve: "#cba6f7"
    property color red: "#f38ba8"
    property color peach: "#fab387"
    property color blue: "#89b4fa"

    function load(path) {
        const xhr = new XMLHttpRequest()
        xhr.open("GET", "file://" + path, false)
        xhr.send()
        let c
        try { c = JSON.parse(xhr.responseText) } catch (e) { return }
        for (const key of ["base", "crust", "text", "subtext0", "overlay2", "surface0",
                           "surface1", "surface2", "mauve", "red", "peach", "blue"]) {
            if (c[key]) palette[key] = c[key]
        }
    }
}
