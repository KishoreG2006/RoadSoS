import 'package:flutter/material.dart';
import 'package:roadsos_mobile/core/theme/app_theme.dart';
import 'package:roadsos_mobile/core/services/crash_detection_system.dart';

class TestSimulationBottomSheet extends StatefulWidget {
  final Function(CrashReport report) onExecuteTest;

  const TestSimulationBottomSheet({
    super.key,
    required this.onExecuteTest,
  });

  @override
  State<TestSimulationBottomSheet> createState() => _TestSimulationBottomSheetState();
}

class _TestSimulationBottomSheetState extends State<TestSimulationBottomSheet> {
  double _impactGs = 3.8;
  double _gyroRads = 4.9;
  double _speedKmh = 60.0;
  double _inactivitySecs = 30.0;
  bool _isLiveSampling = false;

  @override
  Widget build(BuildContext context) {
    final report = CrashDetectionEngine().evaluateMetrics(
      gForce: _impactGs,
      gyroRads: _gyroRads,
      preImpactSpeedKmh: _speedKmh,
      inactivitySecs: _inactivitySecs,
    );

    Color evalColor = report.severityColor;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.science_rounded, color: AppTheme.accentOrange, size: 26),
                    SizedBox(width: 10),
                    Text(
                      'Central Simulation Center',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Text(
              'Unified test matrix for Crash Sensor Metrics & Severity Scoring.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 20),

            // SECTION 1: CRASH METRICS SIMULATOR
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Crash Sensor Metrics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isLiveSampling ? AppTheme.accentOrange : AppTheme.cardDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          side: const BorderSide(color: AppTheme.accentOrange),
                        ),
                        icon: const Icon(Icons.sensors_rounded, color: AppTheme.accentOrange, size: 14),
                        label: Text(
                          _isLiveSampling ? 'Sampling...' : '((·)) Sample IMU',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          setState(() {
                            _impactGs = 4.2;
                            _gyroRads = 5.5;
                            _speedKmh = 75.0;
                            _inactivitySecs = 45.0;
                            _isLiveSampling = true;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _sliderRow('Impact G-Force', '${_impactGs.toStringAsFixed(1)} G', _impactGs, 0.5, 12.0, (val) {
                    setState(() => _impactGs = val);
                  }),
                  _sliderRow('Rotation Speed', '${_gyroRads.toStringAsFixed(1)} rad/s', _gyroRads, 0.5, 10.0, (val) {
                    setState(() => _gyroRads = val);
                  }),
                  _sliderRow('Pre-Impact Speed', '${_speedKmh.toInt()} km/h', _speedKmh, 0, 140, (val) {
                    setState(() => _speedKmh = val);
                  }),
                  _sliderRow('Driver Inactivity', '${_inactivitySecs.toInt()}s', _inactivitySecs, 0, 120, (val) {
                    setState(() => _inactivitySecs = val);
                  }),

                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: evalColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: evalColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Calculated Severity: ${report.severityLabel}', style: TextStyle(color: evalColor, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${(report.severityScore * 100).toStringAsFixed(1)}%', style: TextStyle(color: evalColor, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Combined Execute Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                label: const Text('EXECUTE CRASH PIPELINE TEST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onExecuteTest(report);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sliderRow(String label, String valStr, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            Text(valStr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppTheme.primaryRed,
          inactiveColor: AppTheme.darkBackground,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
