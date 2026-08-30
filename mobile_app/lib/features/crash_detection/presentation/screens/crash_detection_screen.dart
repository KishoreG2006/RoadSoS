import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadsos_mobile/core/theme/app_theme.dart';
import 'package:roadsos_mobile/core/services/crash_detection_system.dart';
import 'package:roadsos_mobile/core/services/location_service.dart';
import 'package:roadsos_mobile/features/crash_detection/presentation/widgets/test_simulation_dialog.dart';

class CrashDetectionScreen extends ConsumerStatefulWidget {
  const CrashDetectionScreen({super.key});

  @override
  ConsumerState<CrashDetectionScreen> createState() => _CrashDetectionScreenState();
}

class _CrashDetectionScreenState extends ConsumerState<CrashDetectionScreen> {
  final CrashDetectionEngine _engine = CrashDetectionEngine();
  final List<CrashEvent> _eventLogs = [];

  StreamSubscription<CrashEvent>? _eventSub;
  StreamSubscription<CrashReport>? _crashSub;

  bool _rideMode = true; // Default Ride Mode ON
  bool _isModalShowing = false;

  @override
  void initState() {
    super.initState();

    _eventSub = _engine.onEvent.listen((event) {
      if (mounted) {
        setState(() {
          _eventLogs.insert(0, event);
          if (_eventLogs.length > 50) {
            _eventLogs.removeLast();
          }
        });
      }
    });

    _crashSub = _engine.onCrashDetected.listen((report) {
      if (mounted && !_isModalShowing) {
        _handleCrashOperation(report);
      }
    });

    // Auto-start engine if Ride Mode is ON
    if (_rideMode) {
      _engine.start();
    }
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _crashSub?.cancel();
    _engine.dispose();
    super.dispose();
  }

  void _toggleRideMode(bool value) async {
    if (value) {
      try {
        const MethodChannel('com.roadsos.mobile/native').invokeMethod('startRideModeService');
      } catch (_) {}
    } else {
      try {
        const MethodChannel('com.roadsos.mobile/native').invokeMethod('stopRideModeService');
      } catch (_) {}
    }
    setState(() {
      _rideMode = value;
      if (_rideMode) {
        _engine.start();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🏍️ Ride Mode Activated — Continuous Background Service ON'), backgroundColor: AppTheme.successGreen),
        );
      } else {
        _engine.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⏸️ Ride Mode Paused — Sensors Deactivated'), backgroundColor: AppTheme.accentOrange),
        );
      }
    });
  }

  /// Evaluates severity and routes required operations
  void _handleCrashOperation(CrashReport report) {
    _isModalShowing = true;

    if (report.severityLabel != 'LOW') {
      try {
        const MethodChannel('com.roadsos.mobile/native').invokeMethod('triggerCrashVibration');
      } catch (_) {}
    }

    if (report.severityLabel == 'LOW') {
      // LOW Severity: In-App Banner only (No SOS required)
      _isModalShowing = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ℹ️ Minor Bump Detected (${(report.severityScore * 100).toStringAsFixed(0)}% severity). Ride Mode active. No SOS required.'),
          backgroundColor: AppTheme.cardDark,
          duration: const Duration(seconds: 4),
        ),
      );
    } else if (report.severityLabel == 'MEDIUM') {
      // MEDIUM Severity: 60-Second Countdown Check Dialog
      _showMediumCountdownDialog(report);
    } else {
      // HIGH / CRITICAL Severity: Instant Alert Modal + Immediate SOS Dispatch
      _showCriticalCrashModal(report);
    }
  }

  void _showCriticalCrashModal(CrashReport report) async {
    // Auto-dispatch SOS immediately for HIGH and CRITICAL impacts
    await _dispatchEmergencySos(report);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppTheme.primaryRed, size: 28),
              const SizedBox(width: 10),
              Text('${report.severityLabel} IMPACT DETECTED', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Severe crash impact detected. Emergency SOS alert dispatched.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.darkBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    _metricRow('Severity Level', report.severityLabel, AppTheme.primaryRed),
                    _metricRow('Severity Score', '${(report.severityScore * 100).toStringAsFixed(1)}%', AppTheme.primaryRed),
                    _metricRow('Peak Impact Gs', '${report.peakImpactGs.toStringAsFixed(2)} G', Colors.white),
                    _metricRow('Peak Gyroscope', '${report.peakGyroRads.toStringAsFixed(2)} rad/s', Colors.white),
                    _metricRow('SOS Operation', 'SOS Alert Dispatched', AppTheme.successGreen),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _isModalShowing = false;
                _engine.reset();
              },
              child: const Text('Acknowledge', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showMediumCountdownDialog(CrashReport report) {
    int remainingSeconds = 60;
    Timer? countdownTimer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) async {
              if (remainingSeconds > 1) {
                setDialogState(() {
                  remainingSeconds--;
                });
              } else {
                timer.cancel();
                Navigator.pop(ctx);
                _isModalShowing = false;
                await _dispatchEmergencySos(report);
                _engine.reset();
              }
            });

            return AlertDialog(
              backgroundColor: AppTheme.cardDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(Icons.timer_rounded, color: AppTheme.accentOrange, size: 28),
                  SizedBox(width: 10),
                  Text('POTENTIAL IMPACT DETECTED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Medium crash impact recorded. Checking driver status.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: CircularProgressIndicator(
                          value: remainingSeconds / 60.0,
                          strokeWidth: 8,
                          color: AppTheme.accentOrange,
                          backgroundColor: AppTheme.darkBackground,
                        ),
                      ),
                      Text('$remainingSeconds s', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ],
              ),
              actions: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.successGreen)),
                  onPressed: () {
                    countdownTimer?.cancel();
                    Navigator.pop(ctx);
                    _isModalShowing = false;
                    _engine.reset();
                  },
                  child: const Text("I'm Okay (Cancel SOS)", style: TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _dispatchEmergencySos(CrashReport report) async {
    try {
      // 1. Query accurate offline GPS coordinates
      final loc = await LocationService().getCurrentLocation();

      // 2. Fetch saved SMS recipients and custom emergency template from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedContactsJson = prefs.getString('contacts_json');
      final savedCustomMessage = prefs.getString('sms_message');

      List<dynamic> contactsList = [];
      if (savedContactsJson != null) {
        contactsList = jsonDecode(savedContactsJson);
      }

      if (contactsList.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ CRASH DETECTED! No SMS emergency recipients configured. Please add contacts in Automatic SMS SOS.'),
              backgroundColor: AppTheme.accentOrange,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      final baseMessage = savedCustomMessage ??
          '🚨 EMERGENCY ALERT: I need immediate roadside/emergency assistance!';

      // Format Google Maps URL and accurate GPS location string
      final mapsUrl = LocationService.formatGoogleMapsUrl(loc.latitude, loc.longitude);
      final fullSmsMessage = '$baseMessage\n\n'
          '🚨 Crash Severity: ${report.severityLabel} (${(report.severityScore * 100).toStringAsFixed(0)}%)\n'
          '📍 Location: $mapsUrl\n'
          'GPS: ${loc.latitude.toStringAsFixed(5)}, ${loc.longitude.toStringAsFixed(5)}';

      // 3. Dispatch SMS via native MethodChannel automatic_sms/sms to all saved recipients
      const smsChannel = MethodChannel('automatic_sms/sms');
      int successCount = 0;
      int failCount = 0;

      for (final item in contactsList) {
        final Map<String, dynamic> c = Map<String, dynamic>.from(item);
        final phone = c['phone'] as String?;
        if (phone != null && phone.trim().isNotEmpty) {
          try {
            await smsChannel.invokeMethod<String>('sendSms', {
              'phoneNumber': phone.trim(),
              'message': fullSmsMessage,
            });
            successCount++;
          } catch (e) {
            failCount++;
          }
        }
      }

      if (mounted) {
        final statusText = failCount > 0
            ? '🚨 AUTOMATIC EMERGENCY SMS SENT to $successCount recipient(s) ($failCount failed).\n📍 Location: ${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}'
            : '🚨 AUTOMATIC EMERGENCY SMS SENT to $successCount recipient(s)!\n📍 Location: ${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(statusText),
            backgroundColor: AppTheme.primaryRed,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error dispatching emergency SMS: $e'),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
    }
  }

  void _openTestSimulationMode() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TestSimulationBottomSheet(
        onExecuteTest: (report) {
          _handleCrashOperation(report);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crash Detection & Ride Mode', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.science_rounded, color: AppTheme.accentOrange),
            tooltip: 'Open Test & Simulation Mode',
            onPressed: _openTestSimulationMode,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ride Mode Hero Control Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _rideMode
                        ? [const Color(0xFF065F46), const Color(0xFF047857)]
                        : [AppTheme.cardDark, AppTheme.cardDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _rideMode ? AppTheme.successGreen : AppTheme.textSecondary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _rideMode ? Icons.two_wheeler_rounded : Icons.pause_circle_filled_rounded,
                              color: _rideMode ? Colors.white : AppTheme.textSecondary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('RIDE MODE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text(
                                  _rideMode ? 'Active — Background Safety Service ON' : 'Paused — Sensors Inactive',
                                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: _rideMode,
                          activeThumbColor: AppTheme.successGreen,
                          activeTrackColor: Colors.white.withValues(alpha: 0.3),
                          onChanged: _toggleRideMode,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Consolidated Test & Simulation Mode Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.science_rounded, color: AppTheme.accentOrange, size: 22),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Test & Simulation Mode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('Simulate crash sensor metrics', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: _openTestSimulationMode,
                      child: const Text('Open Test Mode', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Live Telemetry Event Log
              const Text('Live Telemetry Event Log (Select to View Inputs)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Tap any logged crash item below to inspect input metrics and severity breakdown.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              const SizedBox(height: 12),

              Expanded(
                child: _eventLogs.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sensors_rounded, size: 40, color: AppTheme.textSecondary),
                            SizedBox(height: 10),
                            Text('No crash events recorded yet.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            SizedBox(height: 4),
                            Text('Toggle Ride Mode ON or tap "Open Test Mode" to simulate.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _eventLogs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, idx) {
                          final event = _eventLogs[idx];
                          return _buildEventTile(event);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildEventTile(CrashEvent event) {
    Color color = AppTheme.successGreen;
    if (event.severityLabel == 'CRITICAL' || event.severityLabel == 'HIGH') {
      color = AppTheme.primaryRed;
    } else if (event.severityLabel == 'MEDIUM') {
      color = AppTheme.accentOrange;
    }

    final speedStr = event.speedKmh != null ? '${event.speedKmh!.toInt()} km/h' : '60 km/h';
    final inactivityStr = event.inactivitySecs != null ? '${event.inactivitySecs!.toInt()} s' : '30 s';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.info_outline_rounded, color: color),
        title: Text(
          '[${event.severityLabel} CRASH] Score: ${(event.severityScore * 100).toStringAsFixed(0)}%',
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Text(
          'Impact: ${event.peakImpactGs.toStringAsFixed(2)}G • ${event.timestamp.toLocal().toString().split('.').first.split(' ').last}',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _metricRow('Impact G-Force', '${event.peakImpactGs.toStringAsFixed(2)} G', Colors.white),
                _metricRow('Gyroscope Speed', '${event.peakGyroRads.toStringAsFixed(2)} rad/s', Colors.white),
                _metricRow('Pre-Impact Speed', speedStr, Colors.white),
                _metricRow('Inactivity Period', inactivityStr, Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
