// lib/models/battery_data.dart
// Mock sensor data representing all 26 BMS parameters

class BatteryData {
  // ─── PACK LEVEL ─────────────────────────────────────────────────────────────
  static double packVoltage = 396.4;       // [#1] V
  static double packCurrent = -45.2;       // [#2] A (negative = discharge)
  static double packPower = -17.9;         // [#3] kW (negative = discharge)

  // ─── STATE ──────────────────────────────────────────────────────────────────
  static double stateOfCharge = 85.0;      // [#4] %
  static double energyConsumed = 12.4;     // [#5] kWh this trip
  static double regenEnergy = 4.2;         // [#6] kWh reclaimed

  // ─── HEALTH ─────────────────────────────────────────────────────────────────
  static double internalResistance = 42.0; // [#7] mΩ
  static int cycleCount = 347;             // [#8] cycles
  static double depthOfDischarge = 0.65;   // [#9] 65% avg DoD

  // ─── CELL VOLTAGES ──────────────────────────────────────────────────────────
  static double maxCellVoltage = 4.178;    // [#10] V
  static double minCellVoltage = 4.162;    // [#11] V
  static double cellImbalance = 0.016;     // [#12] V

  // ─── CHEMISTRY ──────────────────────────────────────────────────────────────
  static double coulombicEfficiency = 99.3; // [#13] %

  // ─── TEMPERATURE ────────────────────────────────────────────────────────────
  // [#14] not listed but keeping thermal data below
  static double packTemp = 28.5;           // [#15] °C
  static double thermalGradient = 2.1;     // [#16] °C max delta across cells
  static double inverterTemp = 41.2;       // [#17] °C
  static double ambientTemp = 22.0;        // [#18] °C

  // ─── SAFETY ─────────────────────────────────────────────────────────────────
  static double coolantFlow = 12.4;        // [#19] L/min
  static double insulationResistance = 485.0; // [#20] MΩ
  static double gasCoLevel = 0.02;         // [#21] ppm (near zero = safe)

  // ─── DRIVING BEHAVIOR ───────────────────────────────────────────────────────
  static double throttleGradient = 0.35;   // [#22] 0-1 (smoothness)
  static double brakePedalPos = 0.20;      // [#23] 0-1

  // ─── DERIVED / COMPOSITE ────────────────────────────────────────────────────
  static String stateOfPower = 'Ready';    // [#24]
  static double projectedRange = 263.0;    // [#25] km
  static double batteryStressIndex = 78.0; // [#26] 0-100

  // ─── CHARGING ───────────────────────────────────────────────────────────────
  static bool isCharging = false;
  static double chargeRate = 0.0;          // kW
  static double timeToFull = 0.0;          // hours

  // ─── HISTORY DATA (for charts) ──────────────────────────────────────────────
  static List<double> resistanceHistory = [
    38, 39, 40, 40, 41, 41, 42, 42, 42
  ];

  static List<double> packTempHistory = [
    22, 23, 25, 27, 28, 29, 28, 28, 28
  ];

  static List<double> stressHistory = [
    65, 70, 72, 68, 74, 80, 78, 75, 78
  ];

  static List<TripData> recentTrips = [
    TripData(destination: 'Home → Office', distance: 24.2, efficiency: 142, date: 'Today, 8:30 AM', score: 86),
    TripData(destination: 'Office → Mall', distance: 8.7, efficiency: 158, date: 'Today, 12:15 PM', score: 74),
    TripData(destination: 'Mall → Home', distance: 25.1, efficiency: 135, date: 'Yesterday, 6:40 PM', score: 91),
    TripData(destination: 'Home → Gym', distance: 5.3, efficiency: 171, date: 'Yesterday, 7:00 AM', score: 68),
    TripData(destination: 'Highway Run', distance: 68.4, efficiency: 129, date: 'Mon, 9:00 AM', score: 95),
  ];

  // DoD histogram buckets: 0-20%, 20-40%, 40-60%, 60-80%, 80-100%
  static List<double> dodHistogram = [2.0, 8.0, 22.0, 45.0, 23.0];
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