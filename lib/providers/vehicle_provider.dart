// lib/providers/vehicle_provider.dart
//
// Single source of truth for all 26 BMS parameters.
// - When BLE is connected → values come from ESP32 JSON packets.
// - When disconnected    → values stay at last known (or initial mock).
//
// JSON keys sent by ESP32 (defined in Arduino sketch):
//   v    → packVoltage          i    → packCurrent
//   p    → packPower            soc  → stateOfCharge
//   ec   → energyConsumed       re   → regenEnergy
//   ir   → internalResistance   cc   → cycleCount
//   dod  → depthOfDischarge     vmx  → maxCellVoltage
//   vmn  → minCellVoltage       ci   → cellImbalance (mV int)
//   ce   → coulombicEfficiency  tp   → packTemp
//   tg   → thermalGradient      ti   → inverterTemp
//   ta   → ambientTemp          cf   → coolantFlow
//   ri   → insulationResistance gc   → gasCoLevel
//   th   → throttleGradient (%) bp   → brakePedalPos (%)
//   sop  → stateOfPower (0=Ready,1=Limited,2=Fault)
//   rng  → projectedRange       bsi  → batteryStressIndex
//   chg  → isCharging (0/1)     cr   → chargeRate
//   ttf  → timeToFull (hrs)     spd  → speed (km/h)

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/ble_service.dart';
import '../models/battery_data.dart';

class VehicleProvider extends ChangeNotifier {
  final BleService _ble;
  StreamSubscription? _sub;

  VehicleProvider(this._ble) {
    _sub = _ble.dataStream.listen(_onPacket);
  }

  // ── [#1] Pack Voltage ──────────────────────────────────────────────────────
  double packVoltage = 396.4;
  // ── [#2] Pack Current ─────────────────────────────────────────────────────
  double packCurrent = -45.2;
  // ── [#3] Pack Power ───────────────────────────────────────────────────────
  double packPower = -17.9;
  // ── [#4] State of Charge ──────────────────────────────────────────────────
  double stateOfCharge = 85.0;
  // ── [#5] Energy Consumed ──────────────────────────────────────────────────
  double energyConsumed = 12.4;
  // ── [#6] Regen Energy ─────────────────────────────────────────────────────
  double regenEnergy = 4.2;
  // ── [#7] Internal Resistance ──────────────────────────────────────────────
  double internalResistance = 42.0;
  // ── [#8] Cycle Count ──────────────────────────────────────────────────────
  int cycleCount = 347;
  // ── [#9] Depth of Discharge ───────────────────────────────────────────────
  double depthOfDischarge = 0.65;
  // ── [#10] Max Cell Voltage ────────────────────────────────────────────────
  double maxCellVoltage = 4.178;
  // ── [#11] Min Cell Voltage ────────────────────────────────────────────────
  double minCellVoltage = 4.162;
  // ── [#12] Cell Imbalance ──────────────────────────────────────────────────
  double cellImbalance = 0.016;
  // ── [#13] Coulombic Efficiency ────────────────────────────────────────────
  double coulombicEfficiency = 99.3;
  // ── [#15] Pack Temperature ────────────────────────────────────────────────
  double packTemp = 28.5;
  // ── [#16] Thermal Gradient ────────────────────────────────────────────────
  double thermalGradient = 2.1;
  // ── [#17] Inverter Temperature ────────────────────────────────────────────
  double inverterTemp = 41.2;
  // ── [#18] Ambient Temperature ─────────────────────────────────────────────
  double ambientTemp = 22.0;
  // ── [#19] Coolant Flow ────────────────────────────────────────────────────
  double coolantFlow = 12.4;
  // ── [#20] Insulation Resistance ───────────────────────────────────────────
  double insulationResistance = 485.0;
  // ── [#21] Gas/CO Level ────────────────────────────────────────────────────
  double gasCoLevel = 0.02;
  // ── [#22] Throttle Gradient ───────────────────────────────────────────────
  double throttleGradient = 0.35;
  // ── [#23] Brake Pedal Position ────────────────────────────────────────────
  double brakePedalPos = 0.20;
  // ── [#24] State of Power ──────────────────────────────────────────────────
  String stateOfPower = 'Ready';
  // ── [#25] Projected Range ─────────────────────────────────────────────────
  double projectedRange = 263.0;
  // ── [#26] Battery Stress Index ────────────────────────────────────────────
  double batteryStressIndex = 78.0;

  // ── Charging extras ───────────────────────────────────────────────────────
  bool isCharging = false;
  double chargeRate = 0.0;
  double timeToFull = 0.0;
  double speed = 0.0;

  // ── Rolling history (max 20 points each) ─────────────────────────────────
  final List<double> resistanceHistory = [38, 39, 40, 40, 41, 41, 42, 42, 42];
  final List<double> packTempHistory   = [22, 23, 25, 27, 28, 29, 28, 28, 28];
  final List<double> stressHistory     = [65, 70, 72, 68, 74, 80, 78, 75, 78];
  static const int _historyMax = 20;

  // ── DoD histogram (5 buckets) ─────────────────────────────────────────────
  List<double> dodHistogram = [2.0, 8.0, 22.0, 45.0, 23.0];

  // ── Trip log ──────────────────────────────────────────────────────────────
  double currentTripDistance = 0.0;
  double currentTripEfficiency = 0.0;

  // ── Timestamp ─────────────────────────────────────────────────────────────
  DateTime? lastUpdated;
  bool get hasLiveData => lastUpdated != null;

  // ── Parse incoming JSON from BLE ──────────────────────────────────────────
  void _onPacket(Map<String, dynamic> d) {
    packVoltage          = _d(d, 'v',   packVoltage);
    packCurrent          = _d(d, 'i',   packCurrent);
    packPower            = _d(d, 'p',   packPower);
    stateOfCharge        = _d(d, 'soc', stateOfCharge);
    energyConsumed       = _d(d, 'ec',  energyConsumed);
    regenEnergy          = _d(d, 're',  regenEnergy);
    internalResistance   = _d(d, 'ir',  internalResistance);
    cycleCount           = _i(d, 'cc',  cycleCount);
    depthOfDischarge     = _d(d, 'dod', depthOfDischarge * 100) / 100;
    maxCellVoltage       = _d(d, 'vmx', maxCellVoltage);
    minCellVoltage       = _d(d, 'vmn', minCellVoltage);
    cellImbalance        = _d(d, 'ci',  cellImbalance * 1000) / 1000;
    coulombicEfficiency  = _d(d, 'ce',  coulombicEfficiency);
    packTemp             = _d(d, 'tp',  packTemp);
    thermalGradient      = _d(d, 'tg',  thermalGradient);
    inverterTemp         = _d(d, 'ti',  inverterTemp);
    ambientTemp          = _d(d, 'ta',  ambientTemp);
    coolantFlow          = _d(d, 'cf',  coolantFlow);
    insulationResistance = _d(d, 'ri',  insulationResistance);
    gasCoLevel           = _d(d, 'gc',  gasCoLevel);
    throttleGradient     = _d(d, 'th',  throttleGradient * 100) / 100;
    brakePedalPos        = _d(d, 'bp',  brakePedalPos * 100) / 100;
    projectedRange       = _d(d, 'rng', projectedRange);
    batteryStressIndex   = _d(d, 'bsi', batteryStressIndex);
    isCharging           = (d['chg'] ?? (isCharging ? 1 : 0)) == 1;
    chargeRate           = _d(d, 'cr',  chargeRate);
    timeToFull           = _d(d, 'ttf', timeToFull);
    speed                = _d(d, 'spd', speed);

    // ── TinyML SAF model override ───────────────────────────────────────────
    final safClass = d['saf'];
    if (safClass != null) {
      gasCoLevel = safClass == 2 ? 1.2 : safClass == 1 ? 0.3 : 0.02;
      insulationResistance = safClass == 2 ? 20.0 : safClass == 1 ? 80.0 : 485.0;
    }

    // Decode SoP (0=Ready, 1=Limited, 2=Fault)
    final sopCode = d['sop'];
    if (sopCode != null) {
      stateOfPower = sopCode == 0 ? 'Ready' : sopCode == 1 ? 'Limited' : 'Fault';
    }

    // Append to rolling history
    _push(resistanceHistory, internalResistance);
    _push(packTempHistory,   packTemp);
    _push(stressHistory,     batteryStressIndex);

    lastUpdated = DateTime.now();

    // ── Sync static BatteryData used by UI widgets ──────────────────────────
    BatteryData.packVoltage          = packVoltage;
    BatteryData.packCurrent          = packCurrent;
    BatteryData.packPower            = packPower;
    BatteryData.stateOfCharge        = stateOfCharge;
    BatteryData.energyConsumed       = energyConsumed;
    BatteryData.regenEnergy          = regenEnergy;
    BatteryData.internalResistance   = internalResistance;
    BatteryData.cycleCount           = cycleCount;
    BatteryData.depthOfDischarge     = depthOfDischarge;
    BatteryData.maxCellVoltage       = maxCellVoltage;
    BatteryData.minCellVoltage       = minCellVoltage;
    BatteryData.cellImbalance        = cellImbalance;
    BatteryData.coulombicEfficiency  = coulombicEfficiency;
    BatteryData.packTemp             = packTemp;
    BatteryData.thermalGradient      = thermalGradient;
    BatteryData.inverterTemp         = inverterTemp;
    BatteryData.ambientTemp          = ambientTemp;
    BatteryData.coolantFlow          = coolantFlow;
    BatteryData.insulationResistance = insulationResistance;
    BatteryData.gasCoLevel           = gasCoLevel;
    BatteryData.throttleGradient     = throttleGradient;
    BatteryData.brakePedalPos        = brakePedalPos;
    BatteryData.stateOfPower         = stateOfPower;
    BatteryData.projectedRange       = projectedRange;
    BatteryData.batteryStressIndex   = batteryStressIndex;
    BatteryData.isCharging           = isCharging;
    BatteryData.chargeRate           = chargeRate;
    BatteryData.timeToFull           = timeToFull;

    notifyListeners();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  static double _d(Map d, String k, double fallback) {
    final v = d[k];
    if (v == null) return fallback;
    return (v as num).toDouble();
  }

  static int _i(Map d, String k, int fallback) {
    final v = d[k];
    if (v == null) return fallback;
    return (v as num).toInt();
  }

  void _push(List<double> list, double value) {
    list.add(value);
    if (list.length > _historyMax) list.removeAt(0);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
