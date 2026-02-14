// lib/services/ble_service.dart
//
// ESP32 BLE UUIDs — must match your Arduino sketch exactly:
//   Service UUID    : 12345678-1234-1234-1234-123456789012
//   Data Char UUID  : 87654321-4321-4321-4321-210987654321  (NOTIFY | READ)
//   Command Char UUID: AAAABBBB-CCCC-DDDD-EEEE-FFFFFFFFFFFF  (WRITE)
//
// ESP32 sends a JSON notification every 2 s on the Data characteristic.
// Flutter writes commands (e.g. limp-mode on/off) to the Command characteristic.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// ── UUIDs ─────────────────────────────────────────────────────────────────────
const String kServiceUUID   = '12345678-1234-1234-1234-123456789012';
const String kDataCharUUID  = '87654321-4321-4321-4321-210987654321';
const String kCmdCharUUID   = 'aaaabbbb-cccc-dddd-eeee-ffffffffffff';
const String kDeviceName    = 'EV_Guardian'; // Must match ESP32 advertised name

enum BleStatus { idle, scanning, connecting, connected, disconnected, error }

class BleService extends ChangeNotifier {
  // ── Singleton ────────────────────────────────────────────────────────────────
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  // ── State ────────────────────────────────────────────────────────────────────
  BleStatus _status = BleStatus.idle;
  BleStatus get status => _status;

  BluetoothDevice? _device;
  BluetoothDevice? get device => _device;

  BluetoothCharacteristic? _dataCh;
  BluetoothCharacteristic? _cmdCh;

  // Scanned device list
  final List<ScanResult> scanResults = [];

  // Raw parsed JSON stream → VehicleProvider subscribes to this
  final StreamController<Map<String, dynamic>> _dataStream =
  StreamController.broadcast();
  Stream<Map<String, dynamic>> get dataStream => _dataStream.stream;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  StreamSubscription? _scanSub;
  StreamSubscription? _notifySub;
  StreamSubscription? _stateSub;

  // ── Scan ─────────────────────────────────────────────────────────────────────
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    if (_status == BleStatus.scanning) return;

    scanResults.clear();
    _setStatus(BleStatus.scanning);

    try {
      // Scan for ALL devices — no name filter during discovery
      // Once ESP32 is confirmed visible, you can re-add withNames filter
      await FlutterBluePlus.startScan(
        timeout: timeout,
      );

      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        scanResults
          ..clear()
          ..addAll(results);
        notifyListeners();
      });

      await Future.delayed(timeout);
      await stopScan();
    } catch (e) {
      _setError('Scan failed: $e');
    }
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _scanSub?.cancel();
    if (_status == BleStatus.scanning) _setStatus(BleStatus.idle);
  }

  // ── Connect ──────────────────────────────────────────────────────────────────
  Future<void> connect(BluetoothDevice device) async {
    _setStatus(BleStatus.connecting);
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      _device = device;

      // Watch for disconnection
      _stateSub = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _setStatus(BleStatus.disconnected);
          _cleanup();
        }
      });

      await _discoverServices(device);
      _setStatus(BleStatus.connected);
    } catch (e) {
      _setError('Connect failed: $e');
    }
  }

  Future<void> disconnect() async {
    await _device?.disconnect();
    _cleanup();
    _setStatus(BleStatus.idle);
  }

  // ── Service discovery ────────────────────────────────────────────────────────
  Future<void> _discoverServices(BluetoothDevice device) async {
    final services = await device.discoverServices();
    for (final svc in services) {
      if (svc.uuid.toString().toLowerCase() == kServiceUUID) {
        for (final ch in svc.characteristics) {
          final uuid = ch.uuid.toString().toLowerCase();
          if (uuid == kDataCharUUID) {
            _dataCh = ch;
            await ch.setNotifyValue(true);
            _notifySub = ch.onValueReceived.listen(_onData);
          } else if (uuid == kCmdCharUUID) {
            _cmdCh = ch;
          }
        }
      }
    }
    if (_dataCh == null) {
      _setError('Data characteristic not found — check UUID in ESP32 sketch');
    }
  }

  // ── Data handler ─────────────────────────────────────────────────────────────
  void _onData(List<int> bytes) {
    try {
      final json = utf8.decode(bytes);
      final map = jsonDecode(json) as Map<String, dynamic>;
      _dataStream.add(map);
    } catch (e) {
      debugPrint('[BLE] Parse error: $e');
    }
  }

  // ── Send command to ESP32 ────────────────────────────────────────────────────
  /// Commands the ESP32 understands (defined in Arduino sketch):
  ///   {"cmd":"limp","val":1}   → enable limp mode
  ///   {"cmd":"limp","val":0}   → disable limp mode
  ///   {"cmd":"bal","val":1}    → start balancing charge
  ///   {"cmd":"precond","val":1}→ start pre-conditioning
  Future<void> sendCommand(String cmd, dynamic value) async {
    if (_cmdCh == null) return;
    try {
      final payload = utf8.encode(jsonEncode({'cmd': cmd, 'val': value}));
      await _cmdCh!.write(payload, withoutResponse: false);
    } catch (e) {
      debugPrint('[BLE] Write error: $e');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  void _setStatus(BleStatus s) {
    _status = s;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    _status = BleStatus.error;
    notifyListeners();
  }

  void _cleanup() {
    _notifySub?.cancel();
    _stateSub?.cancel();
    _dataCh = null;
    _cmdCh = null;
    _device = null;
  }

  bool get isConnected => _status == BleStatus.connected;

  @override
  void dispose() {
    _cleanup();
    _dataStream.close();
    super.dispose();
  }
}