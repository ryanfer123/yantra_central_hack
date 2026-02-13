// lib/models/battery_data.dart
// Immutable battery data model representing all 26 BMS parameters

class BatteryData {
  // ─── PACK LEVEL ─────────────────────────────────────────────────────────────
  final double packVoltage;       // [#1] V
  final double packCurrent;       // [#2] A (negative = discharge)
  final double packPower;         // [#3] kW (negative = discharge)

  // ─── STATE ──────────────────────────────────────────────────────────────────
  final double stateOfCharge;     // [#4] %
  final double energyConsumed;    // [#5] kWh this trip
  final double regenEnergy;       // [#6] kWh reclaimed

  // ─── HEALTH ─────────────────────────────────────────────────────────────────
  final double internalResistance; // [#7] mΩ
  final int cycleCount;            // [#8] cycles
  final double depthOfDischarge;   // [#9] 0-1

  // ─── CELL VOLTAGES ──────────────────────────────────────────────────────────
  final double maxCellVoltage;    // [#10] V
  final double minCellVoltage;    // [#11] V
  final double cellImbalance;     // [#12] V

  // ─── CHEMISTRY ──────────────────────────────────────────────────────────────
  final double coulombicEfficiency; // [#13] %

  // ─── TEMPERATURE ────────────────────────────────────────────────────────────
  final double packTemp;           // [#15] °C
  final double thermalGradient;    // [#16] °C max delta across cells
  final double inverterTemp;       // [#17] °C
  final double ambientTemp;        // [#18] °C

  // ─── SAFETY ─────────────────────────────────────────────────────────────────
  final double coolantFlow;        // [#19] L/min
  final double insulationResistance; // [#20] MΩ
  final double gasCoLevel;         // [#21] ppm

  // ─── DRIVING BEHAVIOR ───────────────────────────────────────────────────────
  final double throttleGradient;   // [#22] 0-1
  final double brakePedalPos;      // [#23] 0-1

  // ─── DERIVED / COMPOSITE ────────────────────────────────────────────────────
  final String stateOfPower;       // [#24]
  final double projectedRange;     // [#25] km
  final double batteryStressIndex; // [#26] 0-100

  // ─── CHARGING ───────────────────────────────────────────────────────────────
  final bool isCharging;
  final double chargeRate;         // kW
  final double timeToFull;         // hours

  // ─── HISTORY DATA (for charts) ──────────────────────────────────────────────
  final List<double> resistanceHistory;
  final List<double> packTempHistory;
  final List<double> stressHistory;
  final List<TripData> recentTrips;
  final List<double> dodHistogram;

  const BatteryData({
    this.packVoltage = 396.4,
    this.packCurrent = -45.2,
    this.packPower = -17.9,
    this.stateOfCharge = 85.0,
    this.energyConsumed = 12.4,
    this.regenEnergy = 4.2,
    this.internalResistance = 42.0,
    this.cycleCount = 347,
    this.depthOfDischarge = 0.65,
    this.maxCellVoltage = 4.178,
    this.minCellVoltage = 4.162,
    this.cellImbalance = 0.016,
    this.coulombicEfficiency = 99.3,
    this.packTemp = 28.5,
    this.thermalGradient = 2.1,
    this.inverterTemp = 41.2,
    this.ambientTemp = 22.0,
    this.coolantFlow = 12.4,
    this.insulationResistance = 485.0,
    this.gasCoLevel = 0.02,
    this.throttleGradient = 0.35,
    this.brakePedalPos = 0.20,
    this.stateOfPower = 'Ready',
    this.projectedRange = 263.0,
    this.batteryStressIndex = 78.0,
    this.isCharging = false,
    this.chargeRate = 0.0,
    this.timeToFull = 0.0,
    this.resistanceHistory = const [38, 39, 40, 40, 41, 41, 42, 42, 42],
    this.packTempHistory = const [22, 23, 25, 27, 28, 29, 28, 28, 28],
    this.stressHistory = const [65, 70, 72, 68, 74, 80, 78, 75, 78],
    this.recentTrips = const [
      TripData(destination: 'Home → Office', distance: 24.2, efficiency: 142, date: 'Today, 8:30 AM', score: 86),
      TripData(destination: 'Office → Mall', distance: 8.7, efficiency: 158, date: 'Today, 12:15 PM', score: 74),
      TripData(destination: 'Mall → Home', distance: 25.1, efficiency: 135, date: 'Yesterday, 6:40 PM', score: 91),
      TripData(destination: 'Home → Gym', distance: 5.3, efficiency: 171, date: 'Yesterday, 7:00 AM', score: 68),
      TripData(destination: 'Highway Run', distance: 68.4, efficiency: 129, date: 'Mon, 9:00 AM', score: 95),
    ],
    this.dodHistogram = const [2.0, 8.0, 22.0, 45.0, 23.0],
  });

  BatteryData copyWith({
    double? packVoltage,
    double? packCurrent,
    double? packPower,
    double? stateOfCharge,
    double? energyConsumed,
    double? regenEnergy,
    double? internalResistance,
    int? cycleCount,
    double? depthOfDischarge,
    double? maxCellVoltage,
    double? minCellVoltage,
    double? cellImbalance,
    double? coulombicEfficiency,
    double? packTemp,
    double? thermalGradient,
    double? inverterTemp,
    double? ambientTemp,
    double? coolantFlow,
    double? insulationResistance,
    double? gasCoLevel,
    double? throttleGradient,
    double? brakePedalPos,
    String? stateOfPower,
    double? projectedRange,
    double? batteryStressIndex,
    bool? isCharging,
    double? chargeRate,
    double? timeToFull,
    List<double>? resistanceHistory,
    List<double>? packTempHistory,
    List<double>? stressHistory,
    List<TripData>? recentTrips,
    List<double>? dodHistogram,
  }) {
    return BatteryData(
      packVoltage: packVoltage ?? this.packVoltage,
      packCurrent: packCurrent ?? this.packCurrent,
      packPower: packPower ?? this.packPower,
      stateOfCharge: stateOfCharge ?? this.stateOfCharge,
      energyConsumed: energyConsumed ?? this.energyConsumed,
      regenEnergy: regenEnergy ?? this.regenEnergy,
      internalResistance: internalResistance ?? this.internalResistance,
      cycleCount: cycleCount ?? this.cycleCount,
      depthOfDischarge: depthOfDischarge ?? this.depthOfDischarge,
      maxCellVoltage: maxCellVoltage ?? this.maxCellVoltage,
      minCellVoltage: minCellVoltage ?? this.minCellVoltage,
      cellImbalance: cellImbalance ?? this.cellImbalance,
      coulombicEfficiency: coulombicEfficiency ?? this.coulombicEfficiency,
      packTemp: packTemp ?? this.packTemp,
      thermalGradient: thermalGradient ?? this.thermalGradient,
      inverterTemp: inverterTemp ?? this.inverterTemp,
      ambientTemp: ambientTemp ?? this.ambientTemp,
      coolantFlow: coolantFlow ?? this.coolantFlow,
      insulationResistance: insulationResistance ?? this.insulationResistance,
      gasCoLevel: gasCoLevel ?? this.gasCoLevel,
      throttleGradient: throttleGradient ?? this.throttleGradient,
      brakePedalPos: brakePedalPos ?? this.brakePedalPos,
      stateOfPower: stateOfPower ?? this.stateOfPower,
      projectedRange: projectedRange ?? this.projectedRange,
      batteryStressIndex: batteryStressIndex ?? this.batteryStressIndex,
      isCharging: isCharging ?? this.isCharging,
      chargeRate: chargeRate ?? this.chargeRate,
      timeToFull: timeToFull ?? this.timeToFull,
      resistanceHistory: resistanceHistory ?? this.resistanceHistory,
      packTempHistory: packTempHistory ?? this.packTempHistory,
      stressHistory: stressHistory ?? this.stressHistory,
      recentTrips: recentTrips ?? this.recentTrips,
      dodHistogram: dodHistogram ?? this.dodHistogram,
    );
  }
}

class TripData {
  final String destination;
  final double distance;
  final double efficiency;  // Wh/km
  final String date;
  final int score;

  const TripData({
    required this.destination,
    required this.distance,
    required this.efficiency,
    required this.date,
    required this.score,
  });
}
