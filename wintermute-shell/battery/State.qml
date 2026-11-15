pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
  id: root
  readonly property UPowerDevice device: UPower.displayDevice
  readonly property bool present: device.ready && device.isPresent
      && device.type === UPowerDeviceType.Battery
  readonly property real percentage: present ? Math.max(0, Math.min(100, device.percentage * 100)) : 0
  readonly property bool charging: present && (device.state === UPowerDeviceState.Charging || !UPower.onBattery)
  readonly property string description: present
      ? "Bateria " + Math.round(percentage) + "%, " + UPowerDeviceState.toString(device.state) : ""
  readonly property int level: Math.round(percentage)
  readonly property bool low: present && !charging && level <= 10
  readonly property int alertLevel: !low ? 0 : level <= 3 ? 3 : level <= 5 ? 5 : 10
  property int alert: 0
  property int alerted: 0
  // Perfis de energia (fichas 08 e 13). O Desempenho usa `zap` nos dois lugares (P-07).
  readonly property var profiles: [
    { key: "power-saver", profile: PowerProfile.PowerSaver, name: "Economia", icon: "leaf", accent: "#CBE25B" },
    { key: "balanced", profile: PowerProfile.Balanced, name: "Equilibrado", icon: "gauge", accent: "#E99FFF" },
    { key: "performance", profile: PowerProfile.Performance, name: "Desempenho", icon: "zap", accent: "#FFE51D" }
  ]
  readonly property bool chargingNow: present && device.state === UPowerDeviceState.Charging
  readonly property real changeRate: present ? device.changeRate : 0
  readonly property real timeToFull: present ? device.timeToFull : 0
  readonly property real timeToEmpty: present ? device.timeToEmpty : 0
  readonly property string selectedProfile:
      profiles.find(entry => entry.profile === PowerProfiles.profile)?.key ?? ""
  function profileAvailable(key) {
    return key !== "performance" || PowerProfiles.hasPerformanceProfile;
  }
  function setProfile(key) {
    const entry = profiles.find(candidate => candidate.key === key);
    if (entry && profileAvailable(key))
      PowerProfiles.profile = entry.profile;
  }

  onChargingChanged: if (charging) { alerted = 0; alert = 0; }
  onAlertLevelChanged: {
    if (alertLevel === 0 || (alerted && alertLevel >= alerted)) return;
    alerted = alertLevel;
    alert = alertLevel;
    if (alertLevel === 3) alertTimer.stop();
    else alertTimer.restart();
  }

  Timer {
    id: alertTimer
    interval: 5000
    onTriggered: root.alert = 0
  }
}
