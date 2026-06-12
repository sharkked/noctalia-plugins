import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
    id: root

    // Required for Launcher Provider
    property var pluginApi: null
    property var launcher: null
    property string name: "Godot Provider"

    property var projectPaths: []
    property bool godotInstalled: false
    property string godotBin: "godot"

    Process {
        id: whichGodot
        command: ["sh", "-c", "(command -v godot || echo 'not found')"]
        stdout: SplitParser {
            onRead: data => {
                var bin = data.trim();
                if (bin !== "not found" && bin !== "") {
                    root.godotInstalled = true;
                    root.godotBin = bin;
                }
            }
        }
    }

    Process {
        id: getProjectList
        command: ["sh", "-c", "gawk 'match(\$0, /\\[(.*)\\]/, a) { print a[1] }' ~/.local/share/godot/projects.cfg"]
        stdout: SplitParser {
            onRead: data => {
                if (data.trim() !== "") {
                    root.projectPaths.push(data.trim());
                }
            }
        }
        onExited: {
            root.launcher?.updateResults();
        }
    }

    function init() {
        whichGodot.running = true;
        getProjectList.running = true;
    }

    function onOpened() {
        root.projectPaths = [];
        getProjectList.running = true;
    }

    function handleCommand(searchText) {
        return searchText.startsWith(">gd");
    }

    function commands() {
        return [
            {
                "name": ">gd",
                "description": pluginApi?.tr("launcher.description"),
                "icon": "search",
                "isTablerIcon": true,
                "onActivate": function () {
                    launcher.setSearchText(">gd");
                }
            }
        ];
    }

    function getResults(searchText) {
        if (!searchText.startsWith(">gd")) {
            return [];
        }

        if (!root.godotInstalled) {
            return [
                {
                    "name": pluginApi?.tr("launcher.notInstalled"),
                    "description": pluginApi?.tr("launcher.notInstalledDesc"),
                    "icon": "alert-circle",
                    "isTablerIcon": true,
                    "onActivate": function () {
                        launcher.close();
                    }
                }
            ];
        }

        var query = searchText.slice(4).trim();
        return root.projectPaths.map(function (p) {
            return {
                "name": "Sample Project",
                "description": p,
                "icon": "star",
                "isTablerIcon": true,
                "onActivate": function () {
                    Quickshell.execDetached(["sh", "-c", `${root.godotBin} -e '${p}/project.godot'`]);
                    launcher.close();
                }
            };
        });
    }
}
