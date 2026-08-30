import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsos_mobile/core/theme/app_theme.dart';
import 'package:roadsos_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:roadsos_mobile/features/auth/presentation/screens/profile_screen.dart';
import 'package:roadsos_mobile/features/crash_detection/presentation/screens/crash_detection_screen.dart';
import 'package:roadsos_mobile/features/crash_detection/presentation/widgets/test_simulation_dialog.dart';
import 'package:roadsos_mobile/features/automatic_sms/presentation/screens/automatic_sms_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openCentralTestCenter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TestSimulationBottomSheet(
        onExecuteTest: (report) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Simulated ${report.severityLabel} Crash Pipeline Execution'),
              backgroundColor: report.severityColor,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.shield_rounded, color: AppTheme.primaryRed, size: 24),
            ),
            const SizedBox(width: 10),
            const Text('Roadsos+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.science_rounded, color: AppTheme.accentOrange, size: 26),
            tooltip: 'Central Test & Simulation Center',
            onPressed: () => _openCentralTestCenter(context),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Welcome Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.primaryRed,
                      AppTheme.purpleAccent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryRed.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              CircleAvatar(radius: 4, backgroundColor: AppTheme.successGreen),
                              SizedBox(width: 6),
                              Text('Safety Engine Active', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.science_rounded, color: Colors.white),
                          onPressed: () => _openCentralTestCenter(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome, ${user?.fullName ?? "Driver"}! 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.email ?? 'driver@roadsos.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Central Test Center Banner Shortcut
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: AppTheme.accentOrange.withValues(alpha: 0.1), blurRadius: 16),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.science_rounded, color: AppTheme.accentOrange, size: 26),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Central Test Center', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('Simulate crash sensor metrics', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _openCentralTestCenter(context),
                      child: const Text('Open Center', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Grid Section Title
              const Text(
                'Safety Platform Modules',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Modules Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.05,
                children: [
                  _ModuleCard(
                    title: 'Crash Detection',
                    status: 'Active Monitoring',
                    icon: Icons.car_crash_rounded,
                    color: AppTheme.primaryRed,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CrashDetectionScreen()),
                      );
                    },
                  ),
                  _ModuleCard(
                    title: 'Automatic SMS SOS',
                    status: 'Direct SIM Dispatch',
                    icon: Icons.sms_rounded,
                    color: Colors.pinkAccent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AutomaticSmsScreen()),
                      );
                    },
                  ),
                  _ModuleCard(
                    title: 'Driver Profile',
                    status: 'Local Account',
                    icon: Icons.person_rounded,
                    color: AppTheme.accentOrange,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String status;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.status,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: color, size: 26),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textSecondary.withValues(alpha: 0.6)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
