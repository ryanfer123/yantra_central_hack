// lib/screens/role_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../theme/admin_theme.dart';
import 'main_navigation.dart';
import 'admin/admin_navigation.dart';
import 'bluetooth_connect_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool isLoading = false;
  String loadingLabel = ""; // Shows correct message for each role

  // DRIVER LOADING → GO TO BLUETOOTH FIRST
  Future<void> _enterDriver() async {
    setState(() {
      isLoading = true;
      loadingLabel = "Loading Dashboard…";
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const BluetoothConnectScreen(), // ← Changed
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // ADMIN LOADING
  Future<void> _enterAdmin() async {
    setState(() {
      isLoading = true;
      loadingLabel = "Loading Admin Panel…";
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AdminNavigation(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              // -----------------------------
              // PAGE CONTENT
              // -----------------------------
              Opacity(
                opacity: isLoading ? 0.25 : 1,
                child: AbsorbPointer(
                  absorbing: isLoading,
                  child: Column(
                    children: [
                      const Spacer(),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppTheme.primaryBlue, Color(0xFF1D4ED8)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.electric_car_rounded,
                            color: Colors.white, size: 34),
                      ),
                      const SizedBox(height: 20),
                      const Text('EV Guardian',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: -1,
                          )),
                      const SizedBox(height: 6),
                      const Text('Select your access role to continue',
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.textSecondary)),
                      const Spacer(),

                      // DRIVER CARD
                      _RoleCard(
                        icon: Icons.person_rounded,
                        title: 'Driver / Owner',
                        subtitle:
                        'Monitor your vehicle, range, battery health and eco-drive coaching',
                        color: AppTheme.primaryBlue,
                        tags: const [
                          'Dashboard',
                          'Battery',
                          'Eco-Drive',
                          'Diagnostics'
                        ],
                        isDark: false,
                        onTap: _enterDriver,
                      ),
                      const SizedBox(height: 16),

                      // ADMIN CARD
                      _RoleCard(
                        icon: Icons.admin_panel_settings_rounded,
                        title: 'Fleet Admin',
                        subtitle:
                        'Fleet oversight, predictive maintenance, driver behavior & remote controls',
                        color: const Color(0xFF3B82F6),
                        tags: const [
                          'God View',
                          'Triage',
                          'Maintenance',
                          'Controls'
                        ],
                        isDark: true,
                        onTap: _enterAdmin,
                      ),

                      const Spacer(),
                      const Text('EV Guardian · Fleet Intelligence v1.0',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textTertiary,
                          )),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // -----------------------------
              // LOADING SPINNER OVERLAY
              // -----------------------------
              if (isLoading)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: Color(0xFF3B82F6),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loadingLabel,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final List<String> tags;
  final bool isDark;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.tags,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? AdminTheme.bg : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? AdminTheme.border : AppTheme.divider,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Text('Enter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          )),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: isDark ? AdminTheme.textPrimary : AppTheme.textPrimary,
                )),
            const SizedBox(height: 5),
            Text(subtitle,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: isDark ? AdminTheme.textSecondary : AppTheme.textSecondary,
                )),
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags
                  .map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(tag,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    )),
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
