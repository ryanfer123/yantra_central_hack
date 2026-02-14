// lib/models/fleet_data.dart

enum VehicleStatus { critical, warning, healthy }
enum MaintenanceStatus { immediate, scheduled, monitoring, clear }

class VehicleData {
  final String id;
  final String driverName;
  final VehicleStatus status;
  final double soc;
  final double range;
  final double battTemp;
  final int driverScore;
  final String predictedFailure;
  final double internalResistance;
  final double cellImbalance;
  final double thermalGradient;
  final double coolantFlow;
  final int cycleCount;
  final double stressIndex;
  final double regenEnergy;
  final double energyConsumed;
  final double throttleGradient;
  final double brakePedalPos;
  final double gasCoLevel;
  final double insulationResistance;
  final bool isCharging;
  final String location;

  const VehicleData({
    required this.id,
    required this.driverName,
    required this.status,
    required this.soc,
    required this.range,
    required this.battTemp,
    required this.driverScore,
    required this.predictedFailure,
    required this.internalResistance,
    required this.cellImbalance,
    required this.thermalGradient,
    required this.coolantFlow,
    required this.cycleCount,
    required this.stressIndex,
    required this.regenEnergy,
    required this.energyConsumed,
    required this.throttleGradient,
    required this.brakePedalPos,
    required this.gasCoLevel,
    required this.insulationResistance,
    required this.isCharging,
    required this.location,
  });
}

class MaintenanceTicket {
  final String vehicleId;
  final String metric;
  final String condition;
  final MaintenanceStatus status;
  final String action;
  final String priority; // HIGH / MEDIUM / LOW

  const MaintenanceTicket({
    required this.vehicleId,
    required this.metric,
    required this.condition,
    required this.status,
    required this.action,
    required this.priority,
  });
}

class DriverRecord {
  final String name;
  final String vehicleId;
  final double throttleGradient;
  final double brakeGradient;
  final int score;
  final double excessConsumption; // % above fleet average
  final int trips;

  const DriverRecord({
    required this.name,
    required this.vehicleId,
    required this.throttleGradient,
    required this.brakeGradient,
    required this.score,
    required this.excessConsumption,
    required this.trips,
  });
}

class FleetData {
  // ── 20 Mock Vehicles ──────────────────────────────────────────────────────
  static const List<VehicleData> vehicles = [
    VehicleData(id: 'EV-101', driverName: 'Arjun K.', status: VehicleStatus.healthy, soc: 88, range: 280, battTemp: 26, driverScore: 91, predictedFailure: 'None', internalResistance: 40, cellImbalance: 0.010, thermalGradient: 1.2, coolantFlow: 13.1, cycleCount: 210, stressIndex: 88, regenEnergy: 5.1, energyConsumed: 9.8, throttleGradient: 0.22, brakePedalPos: 0.18, gasCoLevel: 0.01, insulationResistance: 520, isCharging: false, location: 'Chennai Hub'),
    VehicleData(id: 'EV-204', driverName: 'Priya M.', status: VehicleStatus.critical, soc: 12, range: 38, battTemp: 47, driverScore: 42, predictedFailure: 'Inverter Temp High', internalResistance: 68, cellImbalance: 0.095, thermalGradient: 7.4, coolantFlow: 6.2, cycleCount: 1380, stressIndex: 28, regenEnergy: 0.8, energyConsumed: 28.4, throttleGradient: 0.88, brakePedalPos: 0.74, gasCoLevel: 0.62, insulationResistance: 18, isCharging: false, location: 'On Route NH-44'),
    VehicleData(id: 'EV-115', driverName: 'Rahul S.', status: VehicleStatus.critical, soc: 34, range: 92, battTemp: 43, driverScore: 55, predictedFailure: 'Insulation Failure', internalResistance: 72, cellImbalance: 0.082, thermalGradient: 6.1, coolantFlow: 7.8, cycleCount: 1290, stressIndex: 35, regenEnergy: 1.2, energyConsumed: 22.1, throttleGradient: 0.71, brakePedalPos: 0.62, gasCoLevel: 0.08, insulationResistance: 12, isCharging: false, location: 'Depot B'),
    VehicleData(id: 'EV-402', driverName: 'Kavya R.', status: VehicleStatus.critical, soc: 28, range: 74, battTemp: 52, driverScore: 38, predictedFailure: 'Gas Venting Detected', internalResistance: 75, cellImbalance: 0.110, thermalGradient: 9.2, coolantFlow: 5.1, cycleCount: 1450, stressIndex: 22, regenEnergy: 0.5, energyConsumed: 31.2, throttleGradient: 0.92, brakePedalPos: 0.81, gasCoLevel: 1.24, insulationResistance: 42, isCharging: false, location: 'On Route MH-01'),
    VehicleData(id: 'EV-317', driverName: 'Suresh P.', status: VehicleStatus.warning, soc: 52, range: 148, battTemp: 36, driverScore: 67, predictedFailure: 'Cell Imbalance Growing', internalResistance: 54, cellImbalance: 0.058, thermalGradient: 4.1, coolantFlow: 10.4, cycleCount: 890, stressIndex: 61, regenEnergy: 2.8, energyConsumed: 15.6, throttleGradient: 0.54, brakePedalPos: 0.44, gasCoLevel: 0.03, insulationResistance: 180, isCharging: false, location: 'Chennai Hub'),
    VehicleData(id: 'EV-088', driverName: 'Divya N.', status: VehicleStatus.warning, soc: 61, range: 174, battTemp: 34, driverScore: 72, predictedFailure: 'Coolant Flow Low', internalResistance: 51, cellImbalance: 0.044, thermalGradient: 3.8, coolantFlow: 7.9, cycleCount: 760, stressIndex: 66, regenEnergy: 3.2, energyConsumed: 13.9, throttleGradient: 0.48, brakePedalPos: 0.39, gasCoLevel: 0.02, insulationResistance: 240, isCharging: true, location: 'Depot A'),
    VehicleData(id: 'EV-550', driverName: 'Vikram L.', status: VehicleStatus.warning, soc: 44, range: 122, battTemp: 38, driverScore: 58, predictedFailure: 'End of Life Approach', internalResistance: 62, cellImbalance: 0.067, thermalGradient: 4.6, coolantFlow: 9.1, cycleCount: 1320, stressIndex: 52, regenEnergy: 2.1, energyConsumed: 18.2, throttleGradient: 0.61, brakePedalPos: 0.52, gasCoLevel: 0.03, insulationResistance: 145, isCharging: false, location: 'On Route NH-48'),
    VehicleData(id: 'EV-223', driverName: 'Ananya T.', status: VehicleStatus.healthy, soc: 79, range: 242, battTemp: 28, driverScore: 84, predictedFailure: 'None', internalResistance: 43, cellImbalance: 0.015, thermalGradient: 1.8, coolantFlow: 12.6, cycleCount: 340, stressIndex: 82, regenEnergy: 4.4, energyConsumed: 11.2, throttleGradient: 0.31, brakePedalPos: 0.24, gasCoLevel: 0.01, insulationResistance: 490, isCharging: false, location: 'Chennai Hub'),
    VehicleData(id: 'EV-667', driverName: 'Mohan D.', status: VehicleStatus.healthy, soc: 92, range: 298, battTemp: 25, driverScore: 95, predictedFailure: 'None', internalResistance: 38, cellImbalance: 0.008, thermalGradient: 0.9, coolantFlow: 13.8, cycleCount: 180, stressIndex: 93, regenEnergy: 5.8, energyConsumed: 8.4, throttleGradient: 0.19, brakePedalPos: 0.14, gasCoLevel: 0.01, insulationResistance: 610, isCharging: true, location: 'Depot C'),
    VehicleData(id: 'EV-445', driverName: 'Ravi C.', status: VehicleStatus.healthy, soc: 71, range: 214, battTemp: 27, driverScore: 88, predictedFailure: 'None', internalResistance: 41, cellImbalance: 0.012, thermalGradient: 1.4, coolantFlow: 12.9, cycleCount: 270, stressIndex: 86, regenEnergy: 4.9, energyConsumed: 10.1, throttleGradient: 0.26, brakePedalPos: 0.20, gasCoLevel: 0.01, insulationResistance: 540, isCharging: false, location: 'On Route ECR'),
    VehicleData(id: 'EV-332', driverName: 'Sanjay B.', status: VehicleStatus.warning, soc: 48, range: 136, battTemp: 35, driverScore: 63, predictedFailure: 'Chemistry Aging', internalResistance: 58, cellImbalance: 0.051, thermalGradient: 3.4, coolantFlow: 10.8, cycleCount: 1100, stressIndex: 57, regenEnergy: 2.4, energyConsumed: 16.8, throttleGradient: 0.57, brakePedalPos: 0.47, gasCoLevel: 0.02, insulationResistance: 195, isCharging: false, location: 'Depot B'),
    VehicleData(id: 'EV-189', driverName: 'Meena V.', status: VehicleStatus.healthy, soc: 83, range: 260, battTemp: 26, driverScore: 89, predictedFailure: 'None', internalResistance: 42, cellImbalance: 0.011, thermalGradient: 1.1, coolantFlow: 13.3, cycleCount: 295, stressIndex: 87, regenEnergy: 5.3, energyConsumed: 9.6, throttleGradient: 0.24, brakePedalPos: 0.19, gasCoLevel: 0.01, insulationResistance: 510, isCharging: false, location: 'Chennai Hub'),
    VehicleData(id: 'EV-721', driverName: 'Karthik A.', status: VehicleStatus.healthy, soc: 76, range: 234, battTemp: 29, driverScore: 81, predictedFailure: 'None', internalResistance: 44, cellImbalance: 0.018, thermalGradient: 1.9, coolantFlow: 12.2, cycleCount: 410, stressIndex: 79, regenEnergy: 4.1, energyConsumed: 11.8, throttleGradient: 0.34, brakePedalPos: 0.27, gasCoLevel: 0.02, insulationResistance: 465, isCharging: true, location: 'Depot A'),
    VehicleData(id: 'EV-508', driverName: 'Lakshmi R.', status: VehicleStatus.healthy, soc: 68, range: 202, battTemp: 30, driverScore: 77, predictedFailure: 'None', internalResistance: 46, cellImbalance: 0.021, thermalGradient: 2.2, coolantFlow: 11.8, cycleCount: 520, stressIndex: 75, regenEnergy: 3.7, energyConsumed: 12.4, throttleGradient: 0.38, brakePedalPos: 0.30, gasCoLevel: 0.02, insulationResistance: 420, isCharging: false, location: 'On Route OMR'),
    VehicleData(id: 'EV-093', driverName: 'Vinod S.', status: VehicleStatus.warning, soc: 39, range: 108, battTemp: 37, driverScore: 61, predictedFailure: 'Thermal Anomaly', internalResistance: 56, cellImbalance: 0.049, thermalGradient: 4.8, coolantFlow: 8.6, cycleCount: 980, stressIndex: 55, regenEnergy: 2.2, energyConsumed: 17.4, throttleGradient: 0.59, brakePedalPos: 0.49, gasCoLevel: 0.03, insulationResistance: 168, isCharging: false, location: 'Depot C'),
    VehicleData(id: 'EV-614', driverName: 'Nisha G.', status: VehicleStatus.healthy, soc: 85, range: 268, battTemp: 25, driverScore: 92, predictedFailure: 'None', internalResistance: 39, cellImbalance: 0.009, thermalGradient: 1.0, coolantFlow: 13.5, cycleCount: 198, stressIndex: 91, regenEnergy: 5.5, energyConsumed: 8.9, throttleGradient: 0.20, brakePedalPos: 0.15, gasCoLevel: 0.01, insulationResistance: 580, isCharging: false, location: 'Chennai Hub'),
    VehicleData(id: 'EV-277', driverName: 'Ganesh P.', status: VehicleStatus.healthy, soc: 74, range: 228, battTemp: 28, driverScore: 83, predictedFailure: 'None', internalResistance: 43, cellImbalance: 0.014, thermalGradient: 1.6, coolantFlow: 12.7, cycleCount: 355, stressIndex: 81, regenEnergy: 4.3, energyConsumed: 10.6, throttleGradient: 0.28, brakePedalPos: 0.22, gasCoLevel: 0.01, insulationResistance: 498, isCharging: true, location: 'Depot B'),
    VehicleData(id: 'EV-438', driverName: 'Deepa K.', status: VehicleStatus.warning, soc: 55, range: 158, battTemp: 33, driverScore: 69, predictedFailure: 'Balancing Required', internalResistance: 52, cellImbalance: 0.062, thermalGradient: 3.2, coolantFlow: 11.2, cycleCount: 720, stressIndex: 63, regenEnergy: 2.9, energyConsumed: 14.8, throttleGradient: 0.51, brakePedalPos: 0.41, gasCoLevel: 0.02, insulationResistance: 225, isCharging: false, location: 'On Route GST'),
    VehicleData(id: 'EV-865', driverName: 'Rajesh M.', status: VehicleStatus.healthy, soc: 90, range: 286, battTemp: 24, driverScore: 94, predictedFailure: 'None', internalResistance: 37, cellImbalance: 0.007, thermalGradient: 0.8, coolantFlow: 14.1, cycleCount: 155, stressIndex: 94, regenEnergy: 6.1, energyConsumed: 7.9, throttleGradient: 0.17, brakePedalPos: 0.13, gasCoLevel: 0.01, insulationResistance: 640, isCharging: false, location: 'Chennai Hub'),
    VehicleData(id: 'EV-156', driverName: 'Pooja H.', status: VehicleStatus.healthy, soc: 66, range: 196, battTemp: 31, driverScore: 78, predictedFailure: 'None', internalResistance: 47, cellImbalance: 0.022, thermalGradient: 2.4, coolantFlow: 11.6, cycleCount: 580, stressIndex: 74, regenEnergy: 3.5, energyConsumed: 12.8, throttleGradient: 0.40, brakePedalPos: 0.32, gasCoLevel: 0.02, insulationResistance: 405, isCharging: false, location: 'Depot A'),
  ];

  // ── Maintenance Tickets ───────────────────────────────────────────────────
  static const List<MaintenanceTicket> maintenanceTickets = [
    MaintenanceTicket(vehicleId: 'EV-402', metric: 'Gas/CO Level [#21]', condition: '1.24 ppm — Gas Venting', status: MaintenanceStatus.immediate, action: 'IMMEDIATE RECALL — Isolate vehicle, inspect cell venting', priority: 'HIGH'),
    MaintenanceTicket(vehicleId: 'EV-115', metric: 'Insulation Resistance [#20]', condition: '12 MΩ — Below safe threshold', status: MaintenanceStatus.immediate, action: 'Ground vehicle — shock risk. Inspect HV wiring harness', priority: 'HIGH'),
    MaintenanceTicket(vehicleId: 'EV-204', metric: 'Thermal Gradient [#16]', condition: '7.4°C spike during charge', status: MaintenanceStatus.immediate, action: 'Inspect thermal paste & cooling loop. Predict fire risk', priority: 'HIGH'),
    MaintenanceTicket(vehicleId: 'EV-550', metric: 'Cycle Count [#8]', condition: '1320 / 1500 — 88% life used', status: MaintenanceStatus.scheduled, action: 'Budget pack replacement Q3. Flag for second-life use', priority: 'MEDIUM'),
    MaintenanceTicket(vehicleId: 'EV-317', metric: 'Cell Imbalance [#12]', condition: '95 mV — Consistently high', status: MaintenanceStatus.scheduled, action: 'Schedule overnight balancing slow charge', priority: 'MEDIUM'),
    MaintenanceTicket(vehicleId: 'EV-088', metric: 'Coolant Flow [#19]', condition: '7.9 L/min — 40% drop vs RPM', status: MaintenanceStatus.scheduled, action: 'Order pump part #TM-4821. Schedule replacement', priority: 'MEDIUM'),
    MaintenanceTicket(vehicleId: 'EV-332', metric: 'Polarization Voltage', condition: 'High lag after load — aging', status: MaintenanceStatus.monitoring, action: 'Flag for second-life stationary storage assessment', priority: 'LOW'),
    MaintenanceTicket(vehicleId: 'EV-093', metric: 'Thermal Gradient [#16]', condition: '4.8°C — Borderline anomaly', status: MaintenanceStatus.monitoring, action: 'Monitor for 3 more cycles. Check coolant quality', priority: 'LOW'),
    MaintenanceTicket(vehicleId: 'EV-438', metric: 'Cell Imbalance [#12]', condition: '62 mV — Moderate imbalance', status: MaintenanceStatus.monitoring, action: 'Queue for balancing charge next depot visit', priority: 'LOW'),
  ];

  // ── Driver Records (sorted by score asc = worst first) ────────────────────
  static const List<DriverRecord> driverRecords = [
    DriverRecord(name: 'Kavya R.', vehicleId: 'EV-402', throttleGradient: 0.92, brakeGradient: 0.81, score: 38, excessConsumption: 32.4, trips: 94),
    DriverRecord(name: 'Priya M.', vehicleId: 'EV-204', throttleGradient: 0.88, brakeGradient: 0.74, score: 42, excessConsumption: 28.1, trips: 112),
    DriverRecord(name: 'Rahul S.', vehicleId: 'EV-115', throttleGradient: 0.71, brakeGradient: 0.62, score: 55, excessConsumption: 18.6, trips: 88),
    DriverRecord(name: 'Vikram L.', vehicleId: 'EV-550', throttleGradient: 0.61, brakeGradient: 0.52, score: 58, excessConsumption: 14.2, trips: 103),
    DriverRecord(name: 'Vinod S.', vehicleId: 'EV-093', throttleGradient: 0.59, brakeGradient: 0.49, score: 61, excessConsumption: 12.8, trips: 76),
    DriverRecord(name: 'Sanjay B.', vehicleId: 'EV-332', throttleGradient: 0.57, brakeGradient: 0.47, score: 63, excessConsumption: 10.4, trips: 91),
    DriverRecord(name: 'Suresh P.', vehicleId: 'EV-317', throttleGradient: 0.54, brakeGradient: 0.44, score: 67, excessConsumption: 8.7, trips: 84),
    DriverRecord(name: 'Deepa K.', vehicleId: 'EV-438', throttleGradient: 0.51, brakeGradient: 0.41, score: 69, excessConsumption: 6.2, trips: 97),
    DriverRecord(name: 'Divya N.', vehicleId: 'EV-088', throttleGradient: 0.48, brakeGradient: 0.39, score: 72, excessConsumption: 4.8, trips: 108),
    DriverRecord(name: 'Nisha G.', vehicleId: 'EV-614', throttleGradient: 0.20, brakeGradient: 0.15, score: 92, excessConsumption: -8.4, trips: 119),
    DriverRecord(name: 'Mohan D.', vehicleId: 'EV-667', throttleGradient: 0.19, brakeGradient: 0.14, score: 95, excessConsumption: -11.2, trips: 132),
  ];

  // ── Fleet Aggregate Stats ─────────────────────────────────────────────────
  static int get totalVehicles => vehicles.length;
  static int get criticalCount => vehicles.where((v) => v.status == VehicleStatus.critical).length;
  static int get warningCount => vehicles.where((v) => v.status == VehicleStatus.warning).length;
  static int get healthyCount => vehicles.where((v) => v.status == VehicleStatus.healthy).length;
  static int get chargingCount => vehicles.where((v) => v.isCharging).length;

  static double get fleetReadinessScore {
    final avg = vehicles.map((v) => v.stressIndex).reduce((a, b) => a + b) / vehicles.length;
    return avg;
  }

  static double get avgInternalResistance {
    return vehicles.map((v) => v.internalResistance).reduce((a, b) => a + b) / vehicles.length;
  }

  static double get totalRegenEnergy {
    return vehicles.map((v) => v.regenEnergy).reduce((a, b) => a + b);
  }

  static double get totalEnergyConsumed {
    return vehicles.map((v) => v.energyConsumed).reduce((a, b) => a + b);
  }

  // Resistance trend for the fleet (simulated monthly)
  static List<double> get resistanceTrend => [44.2, 45.1, 45.8, 46.4, 47.0, 47.8, 48.2, 49.1, 50.3, 51.0, 51.8, 52.6];

  static List<VehicleData> get criticalVehicles =>
      vehicles.where((v) => v.status == VehicleStatus.critical).toList();

  static List<String> get alertMessages => [
    '🚨 EV-402: Gas Venting Detected — IMMEDIATE RECALL',
    '⚡ EV-115: Insulation Failure (12 MΩ) — Shock Risk',
    '🔥 EV-204: Thermal Spike 7.4°C — Cooling Failure',
    '⚠️ EV-317: Cell Imbalance 95mV — Schedule Balancing',
    '🔋 EV-550: Cycle Count 1320/1500 — End of Life',
  ];
}