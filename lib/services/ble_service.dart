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
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// ── UUIDs ─────────────────────────────────────────────────────────────────────
final Guid kServiceUUID   = Guid('12345678-1234-1234-1234-123456789012');
final Guid kDataCharUUID  = Guid('87654321-4321-4321-4321-210987654321');
final Guid kCmdCharUUID   = Guid('aaaabbbb-cccc-dddd-eeee-ffffffffffff');
const String kDeviceName    = 'EV_Guardian'; // Must match ESP32 advertised name

enum BleStatus { idle, scanning, connecting, connected, disconnected, error }

class BleService extends ChangeNotifier {
  // ── Singleton ────────────────────────────────────────────────────────────────
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal() {
    // Listen to adapter state changes globally
    _adapterStateSub = FlutterBluePlus.adapterState.listen((state) {
      if (state != BluetoothAdapterState.on) {
        if (_status != BleStatus.idle && _status != BleStatus.error) {
          _setError('Bluetooth adapter turned off');
          _cleanup();
        }
      }
    });
  }

  // ── State ────────────────────────────────────────────────────────────────────
  BleStatus _status = BleStatus.idle;
  BleStatus get status => _status;

  BluetoothDevice? _device;
  BluetoothDevice? get device => _device;

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
  StreamSubscription? _adapterStateSub;

  bool _isAutoReconnecting = false;

  // ── Scan ─────────────────────────────────────────────────────────────────────
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    if (_status == BleStatus.scanning) return;

    // Reset state
    scanResults.clear();
    _errorMessage = '';
    _setStatus(BleStatus.scanning);

    try {
      // Check if Bluetooth is on
      if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
        // Wait briefly to see if it turns on (e.g. user prompt)
        if (Platform.isAndroid) {
          try {
            await FlutterBluePlus.turnOn();
          } catch (e) {
            _setError('Bluetooth is turned off');
            return;
          }
        } else {
          _setError('Bluetooth is turned off');
          return;
        }
      }

      // Listen to scan results
      _scanSub?.cancel();
      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        scanResults
          ..clear()
          ..addAll(results);
        notifyListeners();
      }, onError: (e) {
        debugPrint('[BLE] Scan stream error: $e');
        _setError('Scan stream error: $e');
      });

      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: true,
      );

      // Wait for timeout (FlutterBluePlus stops automatically, but we update status)
      await Future.delayed(timeout);

      // If still scanning after timeout, verify stopped
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }

      if (_status == BleStatus.scanning) {
        _setStatus(BleStatus.idle);
      }

    } catch (e) {
      debugPrint('[BLE] Scan failed: $e');
      _setError('Scan failed: $e');
      _setStatus(BleStatus.idle);
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      debugPrint('[BLE] Stop scan error: $e');
    }
    _scanSub?.cancel();
    if (_status == BleStatus.scanning) _setStatus(BleStatus.idle);
  }

  // ── Connect ──────────────────────────────────────────────────────────────────
  Future<void> connect(BluetoothDevice device) async {
    // If already connected to this device, do nothing
    if (_device?.remoteId == device.remoteId && _status == BleStatus.connected) {
      return;
    }

    // Stop scanning before connecting
    await stopScan();

    _setStatus(BleStatus.connecting);
    _errorMessage = '';

    try {
      // Connect
      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
        mtu: null, // Let negotiation happen later or default
      );
      _device = device;

      // Watch for disconnection
      _stateSub?.cancel();
      _stateSub = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          debugPrint('[BLE] Disconnected from ${device.platformName}');
          if (!_isAutoReconnecting) {
            _setStatus(BleStatus.disconnected);
            _cleanup();
          }
        }
      });

      // Request higher MTU for JSON packets (Android only, iOS negotiates automatically)
      if (Platform.isAndroid) {
        try {
          await device.requestMtu(512);
        } catch (e) {
          debugPrint('[BLE] MTU Request failed: $e');
        }
      }

      // Discover Services
      debugPrint('[BLE] Discovering services...');
      if (await _discoverServices(device)) {
        _setStatus(BleStatus.connected);
      } else {
        await device.disconnect();
        _setError('Required services not found.');
      }

    } catch (e) {
      debugPrint('[BLE] Connect failed: $e');
      _setError('Connect failed: $e');
      await device.disconnect();
      _cleanup();
    }
  }

  Future<void> disconnect() async {
    _isAutoReconnecting = false;
    await _device?.disconnect();
    _cleanup();
    _setStatus(BleStatus.idle);
  }

  // ── Service discovery ────────────────────────────────────────────────────────
  /// Returns true if essential services/characteristics were found and setup
  Future<bool> _discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = [];
    try {
      services = await device.discoverServices();
    } catch (e) {
      debugPrint('[BLE] discoverServices exception: $e');
      return false;
    }

    BluetoothService? targetService;
    try {
      targetService = services.firstWhere((s) => s.uuid == kServiceUUID);
    } catch (_) {
      debugPrint('[BLE] Service $kServiceUUID not found.');
      return false;
    }

    debugPrint('[BLE] Found Service: ${targetService.uuid}');

    bool dataCharFound = false;

    for (final ch in targetService.characteristics) {
      if (ch.uuid == kDataCharUUID) {
        debugPrint('[BLE] Found Data Char: ${ch.uuid}');

        // Enable notifications
        try {
          if (!ch.isNotifying) {
            await ch.setNotifyValue(true);
          }
          _notifySub?.cancel();
          _notifySub = ch.onValueReceived.listen(_onData);
          dataCharFound = true;
        } catch (e) {
          debugPrint('[BLE] Failed to subscribe to data char: $e');
        }
      } else if (ch.uuid == kCmdCharUUID) {
        debugPrint('[BLE] Found Cmd Char: ${ch.uuid}');
        _cmdCh = ch;
      }
    }

    return dataCharFound;
  }

  // ── Data handler ─────────────────────────────────────────────────────────────
  void _onData(List<int> bytes) {
    if (bytes.isEmpty) return;
    try {
      // Decode assuming full JSON packet.
      // Note: For production, implement packet reassembly if MTU < payload size.
      final json = utf8.decode(bytes);
      debugPrint('[BLE] RX: $json');
      final map = jsonDecode(json) as Map<String, dynamic>;
      _dataStream.add(map);
    } catch (e) {
      debugPrint('[BLE] Parse error: $e. Bytes: $bytes');
      // Optional: don't error out the whole connection, just drop bad packet
    }
  }

  // ── Send command to ESP32 ────────────────────────────────────────────────────
  Future<void> sendCommand(String cmd, dynamic value) async {
    if (_cmdCh == null) {
      debugPrint('[BLE] Command characteristic not available');
      return;
    }
    try {
      final payload = utf8.encode(jsonEncode({'cmd': cmd, 'val': value}));
      await _cmdCh!.write(payload, withoutResponse: false);
      debugPrint('[BLE] TX: $cmd=$value');
    } catch (e) {
      debugPrint('[BLE] Write error: $e');
      _setError('Failed to send command: $e');
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
    _scanSub?.cancel();

    _cmdCh = null;
    _device = null;

    // Do not cancel _dataStream or _adapterStateSub here as the service might persist
  }

  bool get isConnected => _status == BleStatus.connected;

  @override
  void dispose() {
    _cleanup();
    _adapterStateSub?.cancel();
    _dataStream.close();
    super.dispose();
  }
}