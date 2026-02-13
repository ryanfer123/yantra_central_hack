// lib/models/simulation_service.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'battery_data.dart';

class SimulationService {
  SimulationService._();
  static final SimulationService instance = SimulationService._();

  final ValueNotifier<BatteryData> data = ValueNotifier(const BatteryData());
  Timer? _timer;
  final _rng = Random();

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void refresh() {
    _tick();
  }

  double _drift(double current, double amount) {
    return current + (_rng.nextDouble() - 0.5) * 2 * amount;
  }

  double _clamp(double value, double min, double max) {
    return value.clamp(min, max);
  }

  void _tick() {
    final d = data.value;

    // SoC slowly decreases during driving
    final newSoC = _clamp(d.stateOfCharge - (_rng.nextDouble() * 0.15 + 0.02), 5, 100);

    // Pack voltage correlates with SoC (roughly 340-410V range)
    final newVoltage = _clamp(_drift(d.packVoltage, 0.8), 340, 410);

    // Current fluctuates during driving
    final newCurrent = _clamp(_drift(d.packCurrent, 3.0), -120, 10);

    // Power = voltage * current / 1000
    final newPower = double.parse(
        (newVoltage * newCurrent / 1000).toStringAsFixed(1));

    // Energy consumed slowly increases
    final newEnergyConsumed = _clamp(
        d.energyConsumed + (_rng.nextDouble() * 0.08), 0, 999);

    // Regen energy slowly increases
    final newRegenEnergy = _clamp(
        d.regenEnergy + (_rng.nextDouble() * 0.02), 0, 999);

    // Pack temp fluctuates
    final newPackTemp = _clamp(_drift(d.packTemp, 0.3), 15, 55);

    // Thermal gradient
    final newThermalGrad = _clamp(_drift(d.thermalGradient, 0.15), 0.5, 8);

    // Inverter temp
    final newInverterTemp = _clamp(_drift(d.inverterTemp, 0.4), 25, 80);

    // Coolant flow
    final newCoolantFlow = _clamp(_drift(d.coolantFlow, 0.2), 8, 18);

    // Cell voltages
    final newMaxCell = _clamp(_drift(d.maxCellVoltage, 0.002), 3.8, 4.2);
    final newMinCell = _clamp(newMaxCell - _rng.nextDouble() * 0.025, 3.75, newMaxCell);
    final newImbalance = double.parse((newMaxCell - newMinCell).toStringAsFixed(3));

    // Driving behavior
    final newThrottle = _clamp(_drift(d.throttleGradient, 0.04), 0.05, 0.95);
    final newBrake = _clamp(_drift(d.brakePedalPos, 0.03), 0.0, 0.8);

    // Stress index
    final newStress = _clamp(_drift(d.batteryStressIndex, 2.0), 30, 100);

    // Projected range correlates with SoC
    final newRange = _clamp(newSoC * 3.1 + _drift(0, 5), 15, 350);

    // Internal resistance (very slow drift)
    final newResistance = _clamp(_drift(d.internalResistance, 0.1), 35, 60);

    // Update stress history (slide window)
    final newStressHistory = List<double>.from(d.stressHistory);
    if (newStressHistory.length >= 9) newStressHistory.removeAt(0);
    newStressHistory.add(double.parse(newStress.toStringAsFixed(0)));

    // Update pack temp history
    final newTempHistory = List<double>.from(d.packTempHistory);
    if (newTempHistory.length >= 9) newTempHistory.removeAt(0);
    newTempHistory.add(double.parse(newPackTemp.toStringAsFixed(0)));

    data.value = d.copyWith(
      stateOfCharge: double.parse(newSoC.toStringAsFixed(1)),
      packVoltage: double.parse(newVoltage.toStringAsFixed(1)),
      packCurrent: double.parse(newCurrent.toStringAsFixed(1)),
      packPower: newPower,
      energyConsumed: double.parse(newEnergyConsumed.toStringAsFixed(1)),
      regenEnergy: double.parse(newRegenEnergy.toStringAsFixed(1)),
      packTemp: double.parse(newPackTemp.toStringAsFixed(1)),
      thermalGradient: double.parse(newThermalGrad.toStringAsFixed(1)),
      inverterTemp: double.parse(newInverterTemp.toStringAsFixed(1)),
      coolantFlow: double.parse(newCoolantFlow.toStringAsFixed(1)),
      maxCellVoltage: double.parse(newMaxCell.toStringAsFixed(3)),
      minCellVoltage: double.parse(newMinCell.toStringAsFixed(3)),
      cellImbalance: newImbalance,
      throttleGradient: double.parse(newThrottle.toStringAsFixed(2)),
      brakePedalPos: double.parse(newBrake.toStringAsFixed(2)),
      batteryStressIndex: double.parse(newStress.toStringAsFixed(0)),
      projectedRange: double.parse(newRange.toStringAsFixed(0)),
      internalResistance: double.parse(newResistance.toStringAsFixed(1)),
      stressHistory: newStressHistory,
      packTempHistory: newTempHistory,
    );
  }
}
