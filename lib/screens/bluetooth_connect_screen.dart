// lib/screens/bluetooth_connect_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/ble_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/animations.dart';
import 'main_navigation.dart';

class BluetoothConnectScreen extends StatefulWidget {
  const BluetoothConnectScreen({super.key});

  @override
  State<BluetoothConnectScreen> createState() => _BluetoothConnectScreenState();
}

class _BluetoothConnectScreenState extends State<BluetoothConnectScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulse;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _searchController.addListener(() {
      if (mounted) setState(() {});
    });

    _requestPermissionsAndScan();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissionsAndScan() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    if (!mounted) return;
    final ble = context.read<BleService>();
    await ble.startScan(timeout: const Duration(seconds: 15));
  }

  Future<void> _connect(device) async {
    final ble = context.read<BleService>();
    await ble.connect(device);
    if (!mounted) return;
    if (ble.isConnected) {
      Navigator.of(context).pushReplacement(
        ScaleFadeRoute(page: const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BleService>(
      builder: (context, ble, _) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundLight,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Padding(
              // ← reduced horizontal only, removed top/bottom padding from here
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),    // was 24
                  _buildHeader(ble),
                  const SizedBox(height: 12),    // was 32
                  _buildStatusCard(ble),
                  const SizedBox(height: 8),     // was 16
                  _buildSearchBar(),
                  const SizedBox(height: 8),     // was 16
                  Expanded(child: _buildDeviceList(ble)),
                  _buildBottomActions(ble),
                  const SizedBox(height: 8),     // was 16
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
        decoration: InputDecoration(
          icon: Icon(Icons.search_rounded, color: AppTheme.textTertiary, size: 20),
          hintText: 'Search by name or ID...',
          hintStyle: const TextStyle(color: AppTheme.textTertiary),
          border: InputBorder.none,
          isDense: true,                         // ← smaller height
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.close_rounded, color: AppTheme.textTertiary, size: 18),
            onPressed: () => _searchController.clear(),
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildHeader(BleService ble) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) => Transform.scale(
            scale: ble.status == BleStatus.scanning ? _pulse.value : 1.0,
            child: Container(
              width: 72, height: 72,             // was 80x80
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ble.isConnected ? AppTheme.successGreen : AppTheme.primaryBlue,
                    ble.isConnected
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF1D4ED8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (ble.isConnected
                        ? AppTheme.successGreen
                        : AppTheme.primaryBlue)
                        .withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                ble.isConnected
                    ? Icons.bluetooth_connected_rounded
                    : Icons.bluetooth_searching_rounded,
                color: Colors.white,
                size: 32,                        // was 36
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),             // was 16
        const Text('Connect to EV_Guardian',
            style: TextStyle(
              fontSize: 20,                      // was 22
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.6,
            )),
        const SizedBox(height: 4),              // was 6
        Text(
          ble.isConnected
              ? 'Connected — live data streaming'
              : 'Make sure your ESP32 is powered on and within range',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BleService ble) {
    Color color;
    String label;
    IconData icon;

    switch (ble.status) {
      case BleStatus.scanning:
        color = AppTheme.primaryBlue;
        label = 'Scanning for EV_Guardian...';
        icon = Icons.radar_rounded;
        break;
      case BleStatus.connecting:
        color = AppTheme.warningAmber;
        label = 'Connecting...';
        icon = Icons.sync_rounded;
        break;
      case BleStatus.connected:
        color = AppTheme.successGreen;
        label = 'Connected · Live data active';
        icon = Icons.check_circle_rounded;
        break;
      case BleStatus.error:
        color = AppTheme.dangerRed;
        label = ble.errorMessage;
        icon = Icons.error_rounded;
        break;
      case BleStatus.disconnected:
        color = AppTheme.dangerRed;
        label = 'Disconnected';
        icon = Icons.bluetooth_disabled_rounded;
        break;
      default:
        color = AppTheme.textSecondary;
        label = 'Idle';
        icon = Icons.bluetooth_rounded;
    }

    return AppCard(
      padding: const EdgeInsets.all(12),        // was 16
      child: Row(
        children: [
          Container(
            width: 36, height: 36,              // was 40x40
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                )),
          ),
          if (ble.status == BleStatus.scanning)
            SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2, color: AppTheme.primaryBlue,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(BleService ble) {
    final filterText = _searchController.text.toLowerCase();
    final filteredResults = ble.scanResults.where((r) {
      final name = r.device.platformName.isNotEmpty
          ? r.device.platformName
          : r.advertisementData.advName;
      final id = r.device.remoteId.str;
      return name.toLowerCase().contains(filterText) ||
          id.toLowerCase().contains(filterText);
    }).toList();

    if (filteredResults.isEmpty && ble.status != BleStatus.scanning) {
      final isSearching = _searchController.text.isNotEmpty;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bluetooth_disabled_rounded,
                color: AppTheme.textTertiary, size: 44),
            const SizedBox(height: 10),
            Text(isSearching ? 'No matching devices' : 'No devices found',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              isSearching
                  ? 'Try a different search term'
                  : 'Make sure EV_Guardian is advertising',
              style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (filteredResults.isEmpty && ble.status == BleStatus.scanning) {
      if (_searchController.text.isNotEmpty) {
        return Center(
          child: Text('Scanning for "$filterText"...',
              style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12)),
        );
      }
      return ListView(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text('SCANNING NEARBY...',
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textTertiary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                )),
          ),
          ...List.generate(3, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: StaggeredEntry(
              index: i,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    ShimmerBox(width: 42, height: 42, borderRadius: 11),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(width: 120, height: 12),
                          const SizedBox(height: 8),
                          ShimmerBox(width: 80, height: 10),
                        ],
                      ),
                    ),
                    ShimmerBox(width: 70, height: 32, borderRadius: 10),
                  ],
                ),
              ),
            ),
          )),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (filteredResults.isNotEmpty)
          const SectionHeader(title: 'FOUND DEVICES'),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: filteredResults.length,
            itemBuilder: (_, i) {
              final result = filteredResults[i];
              final name = result.device.platformName.isNotEmpty
                  ? result.device.platformName
                  : result.advertisementData.advName.isNotEmpty
                  ? result.advertisementData.advName
                  : 'Unknown (${result.device.remoteId.str.substring(0, 8)})';
              final rssi = result.rssi;
              final isTarget = name == kDeviceName;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: StaggeredEntry(
                  index: i,
                  child: AppCard(
                    color: isTarget
                        ? AppTheme.primaryBlue.withOpacity(0.05)
                        : AppTheme.surfaceWhite,
                    child: Row(
                      children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: isTarget
                                ? AppTheme.primaryBlue.withOpacity(0.1)
                                : AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(
                            isTarget
                                ? Icons.electric_car_rounded
                                : Icons.bluetooth_rounded,
                            color: isTarget
                                ? AppTheme.primaryBlue
                                : AppTheme.textTertiary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isTarget
                                        ? AppTheme.primaryBlue
                                        : AppTheme.textPrimary,
                                  )),
                              Text('Signal: $rssi dBm',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  )),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _connect(result.device),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isTarget
                                  ? AppTheme.primaryBlue
                                  : AppTheme.backgroundLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('Connect',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isTarget
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BleService ble) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (ble.status != BleStatus.scanning)
          AppActionButton(
            label: 'Scan Again',
            icon: Icons.refresh_rounded,
            onTap: () => context.read<BleService>().startScan(),
          ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(
            FadeRoute(page: const MainNavigation()),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text('Skip — use demo data',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textTertiary,
                  decoration: TextDecoration.underline,
                )),
          ),
        ),
      ],
    );
  }
}