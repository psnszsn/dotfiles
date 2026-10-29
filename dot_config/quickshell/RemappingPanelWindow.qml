// Hyprland leaves a mapped layer surface at its old global position when its
// monitor moves in the layout (unplugging an external moves eDP-1), drawing it
// off-screen. This remaps the window once the screen's origin settles; the 50ms
// gap keeps the compositor from coalescing unmap and remap. Set `shown` rather
// than `visible`, which the remap drives. Popups anchored to the window close
// with it, so `aboutToRemap` lets them note they were open and reopen after.
import QtQuick
import Quickshell

PanelWindow {
  id: window

  property bool shown: true
  property bool remapping: false
  signal aboutToRemap()
  visible: shown && !remapping

  // The origin last seen, since geometryChanged also fires on size changes. Set
  // by hand rather than bound, so the handler sees the old value.
  property real originX: 0
  property real originY: 0
  function noteOrigin() {
    originX = screen?.x ?? 0;
    originY = screen?.y ?? 0;
  }
  Component.onCompleted: noteOrigin()
  onScreenChanged: noteOrigin()

  Timer {
    id: remapSettle
    interval: 200
    onTriggered: {
      if (!window.visible) return;
      window.aboutToRemap();
      window.remapping = true;
    }
  }
  Timer { interval: 50; running: window.remapping; onTriggered: window.remapping = false }

  Connections {
    target: window.screen
    function onGeometryChanged() {
      if (window.screen.x === window.originX && window.screen.y === window.originY) return;
      window.noteOrigin();
      remapSettle.restart();
    }
  }
}
