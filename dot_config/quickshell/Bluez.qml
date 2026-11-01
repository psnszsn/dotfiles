// Connecting, pairing and scanning for Bluetooth devices, shared by leadr and anything
// else that lists them. The calls go to BlueZ over D-Bus and return at once; callers
// follow each device's state as BlueZ reports it. Pairing goes through the
// bluez-agent user service, which asks for any PIN, passkey or confirmation in a
// pinentry dialog.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire

Singleton {
  id: bluez

  readonly property var adapter: Bluetooth.defaultAdapter
  // Set while a device list shows, so new devices turn up to pair.
  property bool scanning: false

  function device(address) {
    return Bluetooth.devices.values.find(d => d.address === address);
  }

  // Disconnects a connected device, cancels a pairing, and otherwise connects,
  // pairing first if the device is new. Returns true when it starts pairing, which
  // may open a pinentry dialog for a PIN or code.
  function toggle(device) {
    if (!device) return;
    if (device.pairing) return device.cancelPair();
    if (device.state === BluetoothDeviceState.Connected) return device.disconnect();
    // Already connecting or disconnecting.
    if (device.state !== BluetoothDeviceState.Disconnected) return;
    if (device.paired || device.trusted) return connect(device);
    // pair() marks the device as pairing before it returns, so pairingDone can't
    // count it finished early.
    device.pair();
    pairing = pairing.concat([device.address]);
    return true;
  }

  // Trusted devices reconnect by themselves and aren't asked to authorize again, like
  // bluetoothctl's pair, trust, connect. The device's audio sink becomes the default
  // once it shows up (see sink).
  function connect(device) {
    device.trusted = true;
    device.connect();
    sinkFor = device.address;
    sinkTimeout.restart();
  }

  // Removes the pairing, disconnecting first if needed, so the device has to pair
  // again from scratch.
  function forget(device) {
    if (!device) return;
    if (sinkFor === device.address) sinkFor = "";
    device.forget();
  }

  // BlueZ's Powered isn't kept across reboots (hardware.bluetooth.powerOnBoot sets it
  // at boot). It refuses to power up under an rfkill block, so that's lifted instead,
  // and BlueZ then powers the adapter on by itself.
  function togglePower() {
    if (!adapter) return;
    if (adapter.state === BluetoothAdapterState.Blocked) Quickshell.execDetached(["rfkill", "unblock", "bluetooth"]);
    else adapter.enabled = !adapter.enabled;
  }

  // New devices being paired, by address. Once BlueZ answers, those that paired go
  // on to connect.
  property var pairing: []
  readonly property var pairingDone: pairing.filter(a => !device(a)?.pairing)
  onPairingDoneChanged: {
    const done = pairingDone;
    if (done.length === 0) return;
    pairing = pairing.filter(a => !done.includes(a));
    done.map(device).filter(d => d?.paired).forEach(connect);
  }

  // The address of a device connected here, until its sink appears; given up on after
  // a while, since keyboards and mice never get one.
  property string sinkFor: ""
  readonly property var sink: sinkFor === "" ? null
    : Audio.sinks.find(n => n.name.startsWith("bluez_") && n.name.includes(sinkFor.replace(/:/g, "_"))) ?? null
  onSinkChanged: {
    if (!sink) return;
    Pipewire.preferredDefaultAudioSink = sink;
    sinkFor = "";
  }
  Timer { id: sinkTimeout; interval: 30000; onTriggered: bluez.sinkFor = "" }

  // BlueZ refuses to start discovery while the adapter powers up and ends it by itself
  // after a while, so it's restarted as needed.
  property bool ownsScan: false
  Timer {
    interval: 1000
    repeat: true
    triggeredOnStart: true
    running: bluez.scanning && !!bluez.adapter?.enabled && !bluez.adapter.discovering
    onTriggered: {
      bluez.ownsScan = true;
      bluez.adapter.discovering = true;
    }
  }

  // A scan left running makes A2DP audio on the same radio stutter. Quickshell drops
  // a stop sent before BlueZ confirms the start, so stopping retries until discovery
  // is down, a few times at most: another client's scan (bluetoothctl's, say) keeps
  // it up whatever we send.
  Timer {
    property int attempts: 0
    interval: 1000
    repeat: true
    triggeredOnStart: true
    running: !bluez.scanning && bluez.ownsScan && !!bluez.adapter?.discovering
    onRunningChanged: if (running) attempts = 0
    onTriggered: {
      if (++attempts > 5) bluez.ownsScan = false;
      else bluez.adapter.discovering = false;
    }
  }

  Connections {
    target: bluez.adapter
    function onDiscoveringChanged() {
      if (!bluez.adapter.discovering) bluez.ownsScan = false;
    }
  }
}
