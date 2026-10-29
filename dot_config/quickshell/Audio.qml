// The default sink and source, shared by the bar and leadr.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
  id: audio

  readonly property PwNode sink: Pipewire.defaultAudioSink
  readonly property PwNode source: Pipewire.defaultAudioSource
  readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)
  readonly property var sources: Pipewire.nodes.values.filter(n => !n.isSink && !n.isStream && n.audio)
  PwObjectTracker { objects: [audio.sink, audio.source] }

  // Sets the average volume, scaling each channel so their balance survives.
  function setVolume(node, volume) {
    if (!node?.audio) return;
    const current = node.audio.volume;
    node.audio.volumes = current > 0
      ? node.audio.volumes.map(v => v * volume / current)
      : node.audio.volumes.map(() => volume);
  }

  // Steps the volume, stopping at 100% on the way up. A volume already over 100%
  // (set in pavucontrol, say) stays put on Up and steps down from where it is.
  function nudgeVolume(node, by) {
    if (!node?.audio) return;
    const current = node.audio.volume;
    if (by > 0) setVolume(node, current >= 1 ? current : Math.min(1, current + by));
    else setVolume(node, Math.max(0, current + by));
  }

  function toggleMute(node) {
    if (node?.audio) node.audio.muted = !node.audio.muted;
  }
}
