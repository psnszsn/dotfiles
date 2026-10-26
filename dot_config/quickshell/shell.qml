//@ pragma UseQApplication
// Mirrors ~/.config/waybar: workspaces | window title | backlight battery network tray idle volume clock
// UseQApplication is required for tray icon context menus.
// Left-click a module for its popover; the old waybar actions moved to right-click/scroll.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.WindowManager
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower

ShellRoot {
  id: root

  readonly property color fg: "#ffffff"
  readonly property color accent: "#64727d"
  readonly property color bg: Qt.rgba(43 / 255, 48 / 255, 59 / 255, 0.5)
  readonly property color border: Qt.rgba(100 / 255, 114 / 255, 125 / 255, 0.5)
  readonly property string font: "monospace"
  readonly property int fontSize: 13

  property bool inhibitIdle: false

  // The backlight driver differs between hosts, and desktops have none; the
  // module is hidden when missing.
  property string backlightDir: ""
  readonly property bool hasBacklight: backlightDir !== ""
  Process {
    running: true
    command: ["sh", "-c", `for d in /sys/class/backlight/*; do [ -e "$d/brightness" ] && { echo "$d"; break; }; done`]
    stdout: SplitParser { onRead: line => root.backlightDir = line }
  }

  // sysfs attributes don't emit inotify events; they're re-read on udev events below.
  FileView { id: blBrightness; path: root.hasBacklight ? root.backlightDir + "/brightness" : "" }
  FileView { id: blMax; path: root.hasBacklight ? root.backlightDir + "/max_brightness" : "" }

  readonly property int backlight: Math.round(100 * parseInt(blBrightness.text()) / parseInt(blMax.text())) || 0

  // The internal battery, not wireless peripherals; null on desktops.
  readonly property UPowerDevice bat: UPower.devices.values.find(d => d.isLaptopBattery) ?? null
  readonly property bool hasBattery: bat !== null
  readonly property int battery: Math.round((bat?.percentage ?? 0) * 100)
  readonly property bool charging: bat?.state === UPowerDeviceState.Charging

  // UPower doesn't expose the charge limit through Quickshell. It only matters
  // around state changes (reaching it, plugging in), so it's re-read on those.
  FileView {
    id: batLimit
    path: root.hasBattery ? `/sys/class/power_supply/${root.bat.nativePath}/charge_control_end_threshold` : ""
  }
  Connections {
    target: root.bat
    function onStateChanged() { batLimit.reload(); }
  }
  readonly property int batteryLimit: parseInt(batLimit.text()) || 100

  readonly property var btBatteries: Bluetooth.devices.values.filter(d => d.connected && d.batteryAvailable)

  // BlueZ only exposes a device's first Battery Service. ZMK split keyboards
  // report the other halves as extra ones, labelled through a user description
  // descriptor ("Peripheral 0"), so those are read from the GATT objects
  // directly when the battery popup opens. Keyed by device path: [[label, percent]].
  property var btExtraBatteries: ({})
  Process {
    id: btExtraProc
    command: ["sh", "-c", `
      # busctl waits 25s by default; a device that stops answering shouldn't stall this.
      bus() { busctl --system --timeout=2 -j "$@" 2>/dev/null; }
      bus call org.bluez / org.freedesktop.DBus.ObjectManager GetManagedObjects | jq -r '
        .data[0] as $o
        | [$o | keys[] | select($o[.]["org.bluez.GattCharacteristic1"].UUID.data == "00002a19-0000-1000-8000-00805f9b34fb")]
        # Paths sort by handle, and BlueZ takes the lowest-handle service.
        | group_by(sub("/service.*"; ""))[] | .[1:][]
        | . as $c
        | [$c, ([$o | keys[] | select(startswith($c + "/desc")
            and $o[.]["org.bluez.GattDescriptor1"].UUID.data == "00002901-0000-1000-8000-00805f9b34fb")][0] // "")]
        | @tsv' |
      while read -r char desc; do
        pct=$(bus call org.bluez "$char" org.bluez.GattCharacteristic1 ReadValue 'a{sv}' 0 | jq '.data[0][0] // empty')
        [ -n "$pct" ] || continue
        label=""
        [ -n "$desc" ] && label=$(bus call org.bluez "$desc" org.bluez.GattDescriptor1 ReadValue 'a{sv}' 0 | jq -r '.data[0] | implode')
        printf '%s\\t%s\\t%s\\n' "$char" "$label" "$pct"
      done`]
    stdout: StdioCollector {
      onStreamFinished: {
        const out = {};
        for (const line of text.split("\n")) {
          const f = line.split("\t");
          if (f.length < 3) continue;
          const dev = f[0].replace(/\/service.*/, "");
          if (!out[dev]) out[dev] = [];
          out[dev].push([f[1] || "battery", parseInt(f[2])]);
        }
        root.btExtraBatteries = out;
      }
    }
  }

  // No NetworkManager here (iwd + networkd); net-info.sh asks ip and iwd instead.
  property var net: ({})
  // Starting an already running Process does nothing, so a refresh requested
  // mid-run is remembered and run once the current one exits.
  property bool netRefreshQueued: false
  function refreshNet() {
    if (netProc.running) netRefreshQueued = true;
    else netProc.running = true;
  }
  Process {
    id: netProc
    command: [Quickshell.shellDir + "/net-info.sh"]
    onExited: {
      if (root.netRefreshQueued) {
        root.netRefreshQueued = false;
        Qt.callLater(() => netProc.running = true);
      }
    }
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          root.net = JSON.parse(text);
        } catch (e) {
          root.net = {};
        }
      }
    }
  }

  // The kernel emits a udev change event for every backlight write.
  Process {
    id: udevMonitor
    running: true
    command: ["udevadm", "monitor", "--udev", "--subsystem-match=backlight"]
    stdout: SplitParser {
      onRead: line => { if (line.endsWith("(backlight)")) blBrightness.reload(); }
    }
    onExited: monitorRestart.start()
  }

  // Route and address changes cover connecting, disconnecting and switching networks.
  Process {
    id: ipMonitor
    running: true
    command: ["ip", "monitor", "route", "address"]
    stdout: SplitParser {
      // A single change prints several lines; refresh once they settle.
      onRead: netDebounce.restart()
    }
    onExited: monitorRestart.start()
  }

  Timer {
    id: monitorRestart
    interval: 5000
    onTriggered: {
      udevMonitor.running = true;
      ipMonitor.running = true;
    }
  }

  Timer { id: netDebounce; interval: 300; onTriggered: root.refreshNet() }

  // Signal strength changes constantly; only follow it while a network popover is open.
  property int netPopupsOpen: 0
  Timer {
    interval: 2000
    running: root.netPopupsOpen > 0
    repeat: true
    onTriggered: root.refreshNet()
  }

  Component.onCompleted: refreshNet()

  // brightnessctl is spawned at most every 30ms while dragging the slider.
  property int pendingBacklight: -1
  property double pendingBacklightAt: 0
  function setBacklight(pct) {
    pendingBacklight = Math.max(1, Math.min(100, pct));
    pendingBacklightAt = Date.now();
    if (!blSetTimer.running) blSetTimer.start();
  }
  // Scroll notches arrive faster than a write is read back through udev, so
  // step from the last requested value while one is recent.
  function stepBacklight(step) {
    const base = Date.now() - pendingBacklightAt < 500 ? pendingBacklight : backlight;
    setBacklight(base + step);
  }
  Timer {
    id: blSetTimer
    interval: 30
    onTriggered: Quickshell.execDetached(["brightnessctl", "-q", "-d", root.backlightDir.split("/").pop(), "set", `${root.pendingBacklight}%`])
  }

  // Numbered workspaces in numeric order, then named ones by name, then by
  // ext-workspace coordinates.
  function compareWindowsets(a, b) {
    const na = parseInt(a.name), nb = parseInt(b.name);
    if (isNaN(na) !== isNaN(nb)) return isNaN(na) ? 1 : -1;
    if (!isNaN(na) && na !== nb) return na - nb;
    if (a.name !== b.name) return a.name < b.name ? -1 : 1;
    const ca = a.coordinates ?? [], cb = b.coordinates ?? [];
    for (let i = 0; i < Math.min(ca.length, cb.length); i++) {
      if (ca[i] !== cb[i]) return ca[i] - cb[i];
    }
    return ca.length - cb.length;
  }

  readonly property PwNode sink: Pipewire.defaultAudioSink
  readonly property PwNode source: Pipewire.defaultAudioSource
  readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)
  readonly property var sources: Pipewire.nodes.values.filter(n => !n.isSink && !n.isStream && n.audio)
  PwObjectTracker { objects: [root.sink, root.source] }

  SystemClock { id: clock; precision: SystemClock.Minutes }

  function formatHours(h) {
    if (!isFinite(h) || h <= 0) return "";
    const m = Math.round(h * 60);
    return `${Math.floor(m / 60)}h ${m % 60}m`;
  }

  component BarText: Text {
    color: root.fg
    font.family: root.font
    font.pixelSize: root.fontSize
  }

  component Chip: Rectangle {
    id: chip
    property string text
    property color textColor: root.fg
    property bool strikeout: false
    signal clicked(int button)
    signal scrolled(int delta)

    color: "transparent"
    implicitWidth: label.implicitWidth + 20
    Layout.fillHeight: true
    Layout.leftMargin: 4
    Layout.rightMargin: 4

    BarText {
      id: label
      anchors.centerIn: parent
      text: chip.text
      color: chip.textColor
      font.strikeout: chip.strikeout
    }

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      onClicked: e => chip.clicked(e.button)
      // Horizontal scrolling has no vertical delta; it isn't a step down.
      onWheel: w => { if (w.angleDelta.y !== 0) chip.scrolled(w.angleDelta.y); }
    }
  }

  component BarPopup: PopupWindow {
    id: popup
    required property Item anchorItem
    default property alias content: col.data
    property double closedAt: 0

    function toggle() {
      if (visible) {
        visible = false;
      } else if (Date.now() - closedAt > 250) {
        // A click on the chip while open first dismisses the popup through the
        // focus grab; don't reopen it from that same click.
        visible = true;
      }
    }

    anchor.item: anchorItem
    anchor.rect.width: anchorItem.width
    // Open below the bar's 3px bottom border rather than over it.
    anchor.rect.height: anchorItem.height + 3
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    grabFocus: true
    color: Qt.rgba(43 / 255, 48 / 255, 59 / 255, 0.95)
    implicitWidth: col.implicitWidth + 20
    implicitHeight: col.implicitHeight + 20
    // A Connections rather than onVisibleChanged, so popups can add their own handler.
    Connections {
      target: popup
      function onVisibleChanged() {
        if (!popup.visible) popup.closedAt = Date.now();
      }
    }

    Rectangle {
      anchors.fill: parent
      color: "transparent"
      border.color: root.border
      border.width: 1
    }

    ColumnLayout {
      id: col
      x: 10
      y: 10
      spacing: 6
    }
  }

  component BarButton: Rectangle {
    id: button
    property string text
    property bool checked: false
    signal clicked()

    implicitWidth: buttonLabel.implicitWidth + 12
    implicitHeight: buttonLabel.implicitHeight + 4
    color: checked ? root.accent : buttonMouse.containsMouse ? Qt.rgba(0, 0, 0, 0.2) : "transparent"

    BarText {
      id: buttonLabel
      x: 6
      anchors.verticalCenter: parent.verticalCenter
      text: button.text
    }

    MouseArea {
      id: buttonMouse
      anchors.fill: parent
      hoverEnabled: true
      onClicked: button.clicked()
    }
  }

  component BarSlider: Item {
    id: slider
    property real value: 0
    signal moved(real value)
    readonly property real shown: area.pressed ? area.dragValue : Math.max(0, Math.min(1, value))

    implicitWidth: 200
    implicitHeight: 16

    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width
      height: 4
      color: Qt.rgba(1, 1, 1, 0.2)
    }
    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width * slider.shown
      height: 4
      color: root.fg
    }
    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      x: (parent.width - width) * slider.shown
      width: 10
      height: 10
      color: root.fg
    }

    MouseArea {
      id: area
      property real dragValue: 0
      anchors.fill: parent
      function update(x) {
        dragValue = Math.max(0, Math.min(1, x / width));
        slider.moved(dragValue);
      }
      onPressed: e => update(e.x)
      onPositionChanged: e => update(e.x)
      onWheel: w => {
        if (w.angleDelta.y !== 0)
          slider.moved(Math.max(0, Math.min(1, slider.value + (w.angleDelta.y > 0 ? 0.01 : -0.01))));
      }
    }
  }

  // Two-column label/value list; rows with an empty value are skipped.
  component InfoGrid: GridLayout {
    id: grid
    property var rows: []
    columns: 2
    columnSpacing: 12
    rowSpacing: 2

    Repeater {
      // Qt's JS engine has no Array.prototype.flat.
      model: grid.rows.filter(r => r[1] !== undefined && r[1] !== "").reduce((acc, r) => acc.concat(r), [])
      delegate: BarText {
        required property var modelData
        required property int index
        text: modelData
        opacity: index % 2 === 0 ? 0.6 : 1
      }
    }
  }

  component VolumeRow: RowLayout {
    id: volumeRow
    required property PwNode node
    spacing: 8

    BarButton {
      text: volumeRow.node?.audio?.muted ? "unmute" : "mute"
      Layout.preferredWidth: 60
      onClicked: if (volumeRow.node?.audio) volumeRow.node.audio.muted = !volumeRow.node.audio.muted
    }
    BarSlider {
      value: volumeRow.node?.audio?.volume ?? 0
      opacity: volumeRow.node?.audio?.muted ? 0.4 : 1
      onMoved: v => { if (volumeRow.node?.audio) volumeRow.node.audio.volume = v; }
    }
    BarText {
      text: `${Math.round((volumeRow.node?.audio?.volume ?? 0) * 100)}`
      Layout.preferredWidth: 30
      horizontalAlignment: Text.AlignRight
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: bar
      required property ShellScreen modelData
      screen: modelData

      anchors { top: true; left: true; right: true }
      implicitHeight: 20
      color: root.bg

      IdleInhibitor { window: bar; enabled: root.inhibitIdle }

      Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 3
        color: root.border
      }

      Item {
        id: content
        anchors { fill: parent; bottomMargin: 3 }

        // Workspaces come from ext-workspace-v1, so the same code serves Hyprland and niri,
        // and activation doesn't go through Hyprland's dispatch IPC.
        RowLayout {
          id: leftRow
          anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
          spacing: 0

          Repeater {
            model: (WindowManager.screenProjection(bar.modelData)?.windowsets ?? WindowManager.windowsets)
              .filter(w => w.shouldDisplay)
              .sort(root.compareWindowsets)

            delegate: Rectangle {
              id: wsButton
              required property Windowset modelData
              Layout.fillHeight: true
              implicitWidth: wsLabel.implicitWidth + 18
              color: modelData.urgent ? "#eb4d4b"
                : modelData.active ? root.accent
                : wsMouse.containsMouse ? Qt.rgba(0, 0, 0, 0.2)
                : "transparent"

              BarText {
                id: wsLabel
                anchors { centerIn: parent; verticalCenterOffset: -1 }
                text: wsButton.modelData.name
              }

              Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 3
                color: wsButton.modelData.active || wsMouse.containsMouse ? root.fg : "transparent"
              }

              MouseArea {
                id: wsMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: if (wsButton.modelData.canActivate) wsButton.modelData.activate()
              }
            }
          }
        }

        // Kept centered, so its width is limited by whichever side row is wider.
        BarText {
          anchors.centerIn: parent
          width: Math.max(0, Math.min(implicitWidth,
            content.width - 2 * (Math.max(leftRow.width, rightRow.width) + 8)))
          elide: Text.ElideRight
          text: ToplevelManager.activeToplevel?.title ?? ""
        }

        RowLayout {
          id: rightRow
          anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
          spacing: 0

          Chip {
            id: backlightChip
            visible: root.hasBacklight
            text: `lgt:${root.backlight}`
            onClicked: backlightPopup.toggle()
            onScrolled: delta => root.stepBacklight(delta > 0 ? 1 : -1)

            BarPopup {
              id: backlightPopup
              anchorItem: backlightChip

              BarText { text: `brightness ${root.backlight}%` }
              BarSlider {
                value: root.backlight / 100
                onMoved: v => root.setBacklight(Math.round(v * 100))
              }
            }
          }

          Chip {
            id: batteryChip
            visible: root.hasBattery
            text: `bat:${root.battery}` + (root.charging ? "↑" : "")
            color: root.charging ? "#26a65b" : "#ffffff"
            textColor: root.charging ? "#ffffff" : "#000000"
            onClicked: batteryPopup.toggle()

            BarPopup {
              id: batteryPopup
              anchorItem: batteryChip
              onVisibleChanged: if (visible) btExtraProc.running = true

              InfoGrid {
                // Energy is in Wh and changeRate in W, always positive.
                rows: root.bat ? [
                  ["status", UPowerDeviceState.toString(root.bat.state).toLowerCase()],
                  ["charge", `${root.battery}%` + (root.batteryLimit < 100 ? ` (limit ${root.batteryLimit}%)` : "")],
                  root.bat.state === UPowerDeviceState.Discharging
                    ? ["left", root.formatHours(root.bat.timeToEmpty / 3600)]
                    : ["to limit", root.charging
                      ? root.formatHours((root.bat.energyCapacity * root.batteryLimit / 100 - root.bat.energy) / root.bat.changeRate)
                      : ""],
                  ["power", root.bat.changeRate > 0 ? `${root.bat.changeRate.toFixed(1)} W` : ""],
                  ["health", root.bat.healthSupported ? `${root.bat.healthPercentage.toFixed(1)}%` : ""],
                ] : []
              }

              BarText { text: "bluetooth"; opacity: 0.6; Layout.topMargin: 6; visible: root.btBatteries.length > 0 }
              InfoGrid {
                visible: root.btBatteries.length > 0
                rows: root.btBatteries.reduce((acc, d) => acc.concat(
                  [[d.name, `${Math.round(d.battery * 100)}%`]],
                  (root.btExtraBatteries[d.dbusPath] ?? []).map(b => [`${d.name} ${b[0].toLowerCase()}`, `${b[1]}%`])), [])
              }
            }
          }

          Chip {
            id: networkChip
            text: root.net.dev || "disconnected"
            onClicked: networkPopup.toggle()

            BarPopup {
              id: networkPopup
              anchorItem: networkChip
              // Counted through a flag so a popup destroyed while open (its
              // screen unplugged) still releases its count.
              property bool counted: false
              function setCounted(c) {
                if (c === counted) return;
                counted = c;
                root.netPopupsOpen += c ? 1 : -1;
              }
              onVisibleChanged: {
                setCounted(visible);
                if (visible) root.refreshNet();
              }
              Component.onDestruction: setCounted(false)

              InfoGrid {
                rows: [
                  ["network", root.net.ssid ?? ""],
                  ["signal", root.net.rssi !== undefined && root.net.rssi !== null ? `${root.net.rssi} dBm` : ""],
                  ["band", root.net.frequency ? `${root.net.frequency} MHz` + (root.net.mode ? ` · ${root.net.mode}` : "") : ""],
                  ["security", root.net.security ?? ""],
                  ["interface", root.net.dev || "none"],
                  ["address", root.net.addr ?? ""],
                  ["gateway", root.net.gateway ?? ""],
                ]
              }
              BarButton {
                text: "iwctl"
                onClicked: {
                  networkPopup.visible = false;
                  Quickshell.execDetached(["ghostty", "-e", "iwctl"]);
                }
              }
            }
          }

          RowLayout {
            Layout.leftMargin: 14
            Layout.rightMargin: 14
            spacing: 4

            Repeater {
              model: SystemTray.items

              delegate: Image {
                id: trayIcon
                required property SystemTrayItem modelData
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                sourceSize: Qt.size(32, 32)
                source: modelData.icon

                MouseArea {
                  anchors.fill: parent
                  acceptedButtons: Qt.LeftButton | Qt.RightButton
                  onClicked: e => {
                    const item = trayIcon.modelData;
                    if (e.button === Qt.LeftButton && !item.onlyMenu) {
                      item.activate();
                    } else if (item.hasMenu) {
                      const p = trayIcon.mapToItem(null, 0, trayIcon.height);
                      item.display(bar, p.x, p.y);
                    }
                  }
                }
              }
            }
          }

          Chip {
            text: "zzz"
            strikeout: root.inhibitIdle
            onClicked: root.inhibitIdle = !root.inhibitIdle
          }

          Chip {
            id: volumeChip
            readonly property real volume: root.sink?.audio?.volume ?? 0
            text: `vol:${Math.round(volume * 100)}`
            strikeout: root.sink?.audio?.muted ?? false
            onClicked: button => {
              if (button === Qt.LeftButton) volumePopup.toggle();
              else if (root.sink?.audio) root.sink.audio.muted = !root.sink.audio.muted;
            }
            onScrolled: delta => {
              if (root.sink?.audio)
                root.sink.audio.volume = Math.max(0, Math.min(1, volume + (delta > 0 ? 0.01 : -0.01)));
            }

            BarPopup {
              id: volumePopup
              anchorItem: volumeChip

              BarText { text: "output"; opacity: 0.6 }
              VolumeRow { node: root.sink }
              Repeater {
                model: root.sinks
                delegate: BarButton {
                  required property PwNode modelData
                  Layout.fillWidth: true
                  text: modelData.description || modelData.nickname || modelData.name
                  checked: modelData === root.sink
                  onClicked: Pipewire.preferredDefaultAudioSink = modelData
                }
              }

              BarText { text: "input"; opacity: 0.6; Layout.topMargin: 6 }
              VolumeRow { node: root.source }
              Repeater {
                model: root.sources
                delegate: BarButton {
                  required property PwNode modelData
                  Layout.fillWidth: true
                  text: modelData.description || modelData.nickname || modelData.name
                  checked: modelData === root.source
                  onClicked: Pipewire.preferredDefaultAudioSource = modelData
                }
              }

              BarButton {
                text: "pavucontrol"
                Layout.topMargin: 6
                onClicked: {
                  volumePopup.visible = false;
                  Quickshell.execDetached(["pavucontrol"]);
                }
              }
            }
          }

          Chip {
            id: clockChip
            text: Qt.formatDateTime(clock.date, "HH:mm ddd")
            color: root.accent
            onClicked: button => {
              if (button === Qt.LeftButton) calendarPopup.toggle();
              else Quickshell.execDetached(["ghostty", "-e", "fish", "-C", "cal -3 -M"]);
            }

            BarPopup {
              id: calendarPopup
              anchorItem: clockChip

              property int month: 0
              property int year: 0
              readonly property var locale: Qt.locale("en_GB") // Monday first, like `cal -M`

              function shift(delta) {
                const d = new Date(year, month + delta, 1);
                month = d.getMonth();
                year = d.getFullYear();
              }

              onVisibleChanged: {
                if (visible) {
                  month = clock.date.getMonth();
                  year = clock.date.getFullYear();
                }
              }

              RowLayout {
                Layout.fillWidth: true
                BarButton { text: "‹"; onClicked: calendarPopup.shift(-1) }
                BarText {
                  Layout.fillWidth: true
                  horizontalAlignment: Text.AlignHCenter
                  text: `${calendarPopup.locale.standaloneMonthName(calendarPopup.month)} ${calendarPopup.year}`
                }
                BarButton { text: "›"; onClicked: calendarPopup.shift(1) }
              }

              DayOfWeekRow {
                Layout.fillWidth: true
                locale: calendarPopup.locale
                spacing: 0
                padding: 0
                delegate: BarText {
                  required property var model
                  text: model.shortName.slice(0, 2)
                  horizontalAlignment: Text.AlignHCenter
                  opacity: 0.6
                }
              }

              MonthGrid {
                id: monthGrid
                Layout.fillWidth: true
                month: calendarPopup.month
                year: calendarPopup.year
                locale: calendarPopup.locale
                spacing: 0
                padding: 0

                // Scroll to change month.
                WheelHandler {
                  onWheel: e => { if (e.angleDelta.y !== 0) calendarPopup.shift(e.angleDelta.y > 0 ? -1 : 1); }
                }

                delegate: Rectangle {
                  required property var model
                  implicitWidth: 28
                  implicitHeight: 20
                  color: model.today ? root.accent : "transparent"

                  BarText {
                    anchors.centerIn: parent
                    text: model.day
                    opacity: model.month === monthGrid.month ? 1 : 0.35
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
