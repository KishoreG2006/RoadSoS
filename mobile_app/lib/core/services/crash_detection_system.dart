import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:roadsos_mobile/core/theme/app_theme.dart';



/// Events emitted by the Crash Detection System
enum CrashEventType {
  impactDetected,
  abnormalOrientationDetected,
  inactivityDetected,
  crashConfirmed,
}

class CrashEvent {
  final CrashEventType type;
  final double magnitude;
  final DateTime timestamp;
  final CrashReport? report;
  final double? gForce;
  final double? gyroRads;
  final double? inactivitySecs;
  final double? speedKmh;

  CrashEvent({
    required this.type,
    required this.magnitude,
    DateTime? timestamp,
    this.report,
    this.gForce,
    this.gyroRads,
    this.inactivitySecs,
    this.speedKmh,
  }) : timestamp = timestamp ?? DateTime.now();

  String get severityLabel => report?.severityLabel ?? (magnitude >= 0.7 ? 'HIGH' : 'LOW');
  double get severityScore => report?.severityScore ?? magnitude;
  double get peakImpactGs => gForce ?? report?.peakImpactGs ?? magnitude;
  double get peakGyroRads => gyroRads ?? report?.peakGyroRads ?? magnitude;
}



/// Result payload when a crash is confirmed
class CrashReport {
  final double confidenceScore;
  final double severityScore; // 0.0 to 1.0
  final String severityLabel; // CRITICAL, HIGH, MEDIUM, LOW
  final double peakImpactGs;
  final double peakGyroRads;
  final DateTime timestamp;

  CrashReport({
    required this.confidenceScore,
    required this.severityScore,
    required this.severityLabel,
    required this.peakImpactGs,
    required this.peakGyroRads,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Color get severityColor {
    if (severityLabel == 'CRITICAL' || severityLabel == 'HIGH') return AppTheme.primaryRed;
    if (severityLabel == 'MEDIUM') return AppTheme.accentOrange;
    return AppTheme.successGreen;
  }
}


/// Main Crash Detection Engine
class CrashDetectionEngine {
  // Configurable Thresholds
  final double impactGThreshold; // in Gs (e.g. 1.8g)
  final double rotationThreshold; // in rad/s (e.g. 5.0 rad/s)
  final double confidenceThreshold; // 0.0 - 1.0 (default 0.7)
  final Duration correlationWindow;

  // Stream Subscriptions
  StreamSubscription<UserAccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  // Internal Analyzers
  late final _MotionAnalyzer _motionAnalyzer;
  late final _OrientationAnalyzer _orientationAnalyzer;
  late final _InactivityDetector _inactivityDetector;

  // State Tracking
  bool _isRunning = false;
  bool _crashDetected = false;
  double _confidenceScore = 0.0;
  DateTime? _impactTime;
  DateTime? _orientationTime;
  DateTime? _inactivityTime;
  double _peakImpactGs = 0.0;
  double _peakGyroRads = 0.0;

  // Stream Controller for outputting crash events
  final _eventController = StreamController<CrashEvent>.broadcast();
  final _crashController = StreamController<CrashReport>.broadcast();

  Stream<CrashEvent> get onEvent => _eventController.stream;
  Stream<CrashReport> get onCrashDetected => _crashController.stream;
  bool get isRunning => _isRunning;

  CrashDetectionEngine({
    this.impactGThreshold = 1.84, // ~18.0 m/s^2
    this.rotationThreshold = 5.0, // rad/s
    this.confidenceThreshold = 0.70,
    this.correlationWindow = const Duration(seconds: 90),
  }) {
    _motionAnalyzer = _MotionAnalyzer(
      impactThresholdMs2: impactGThreshold * 9.81,
      onImpact: (magnitudeMs2) {
        _impactTime = DateTime.now();
        _peakImpactGs = magnitudeMs2 / 9.81;
        _inactivityDetector.startTracking();
        _eventController.add(CrashEvent(
          type: CrashEventType.impactDetected,
          magnitude: _peakImpactGs,
        ));
        _evaluateConfidence();
      },
    );

    _orientationAnalyzer = _OrientationAnalyzer(
      rotationThreshold: rotationThreshold,
      onAbnormalOrientation: (magnitudeRads) {
        _orientationTime = DateTime.now();
        _peakGyroRads = magnitudeRads;
        _eventController.add(CrashEvent(
          type: CrashEventType.abnormalOrientationDetected,
          magnitude: magnitudeRads,
        ));
        _evaluateConfidence();
      },
    );

    _inactivityDetector = _InactivityDetector(
      onInactivityConfirmed: () {
        _inactivityTime = DateTime.now();
        _eventController.add(CrashEvent(
          type: CrashEventType.inactivityDetected,
          magnitude: 1.0,
        ));
        _evaluateConfidence();
      },
    );
  }

  /// Start monitoring sensors
  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _crashDetected = false;
    _accelSub = userAccelerometerEventStream().listen((event) {
      _motionAnalyzer.analyze(event);
      _inactivityDetector.analyze(event);
    });
    _gyroSub = gyroscopeEventStream().listen((event) {
      _orientationAnalyzer.analyze(event);
    });
  }

  /// Stop monitoring sensors
  void stop() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _inactivityDetector.stopTracking();
    _isRunning = false;
  }

  void _evaluateConfidence() {
    if (_crashDetected) return;
    final now = DateTime.now();
    _confidenceScore = 0.0;

    // Impact Weight: 40%
    if (_impactTime != null && now.difference(_impactTime!) <= correlationWindow) {
      _confidenceScore += 0.40;
    }
    // Orientation Weight: 30%
    if (_orientationTime != null && now.difference(_orientationTime!) <= correlationWindow) {
      _confidenceScore += 0.30;
    }
    // Inactivity Weight: 30%
    if (_inactivityTime != null && now.difference(_inactivityTime!) <= correlationWindow) {
      _confidenceScore += 0.30;
    }

    // Check Trigger Condition
    if (_confidenceScore >= confidenceThreshold && !_crashDetected) {
      _crashDetected = true;

      // Compute Sigmoid Severity
      final severityData = _calculateSeverity(
        peakAccelGs: _peakImpactGs,
        peakGyroRads: _peakGyroRads,
        inactivitySecs: _inactivityTime != null ? 30.0 : 0.0,
      );

      final report = CrashReport(
        confidenceScore: _confidenceScore,
        severityScore: severityData['score']!,
        severityLabel: severityData['label'] as String,
        peakImpactGs: _peakImpactGs,
        peakGyroRads: _peakGyroRads,
      );

      _crashController.add(report);
      _eventController.add(CrashEvent(
        type: CrashEventType.crashConfirmed,
        magnitude: _confidenceScore,
      ));
    }
  }

  /// Sigmoid Mathematical Severity Score Calculation
  Map<String, dynamic> _calculateSeverity({
    required double peakAccelGs,
    required double peakGyroRads,
    double inactivitySecs = 0.0,
    double preImpactSpeedKmh = 60.0,
  }) {
    double sigmoid(double val, double midpoint, double steepness) {
      return 1.0 / (1.0 + exp(-steepness * (val - midpoint)));
    }

    double sImpact = sigmoid(peakAccelGs, 3.0, 1.5);
    double sOrient = sigmoid(peakGyroRads, 4.0, 1.0);
    double sInactive = (inactivitySecs / 60.0).clamp(0.0, 1.0);
    double sSpeed = sigmoid(preImpactSpeedKmh, 60.0, 0.10);


    double score = (0.40 * sImpact) + (0.25 * sOrient) + (0.20 * sInactive) + (0.15 * sSpeed);
    score = score.clamp(0.0, 1.0);

    String label = 'LOW';
    if (score >= 0.70) {
      label = 'CRITICAL';
    } else if (score >= 0.50) {
      label = 'HIGH';
    } else if (score >= 0.30) {
      label = 'MEDIUM';
    }

    return {'score': score, 'label': label};
  }

  /// Evaluates custom metrics and produces a CrashReport payload
  CrashReport evaluateMetrics({
    required double gForce,
    required double gyroRads,
    double inactivitySecs = 0.0,
    double preImpactSpeedKmh = 60.0,
  }) {
    final severityData = _calculateSeverity(
      peakAccelGs: gForce,
      peakGyroRads: gyroRads,
      inactivitySecs: inactivitySecs,
      preImpactSpeedKmh: preImpactSpeedKmh,
    );

    return CrashReport(
      confidenceScore: 0.85,
      severityScore: severityData['score']!,
      severityLabel: severityData['label'] as String,
      peakImpactGs: gForce,
      peakGyroRads: gyroRads,
    );
  }

  /// Manual trigger for testing crash reports
  void simulateCrashReport({double gForce = 3.5, double gyroRads = 6.2, double inactivitySecs = 30.0, double preImpactSpeedKmh = 60.0}) {
    final report = evaluateMetrics(
      gForce: gForce,
      gyroRads: gyroRads,
      inactivitySecs: inactivitySecs,
      preImpactSpeedKmh: preImpactSpeedKmh,
    );

    _crashController.add(report);
    _eventController.add(CrashEvent(
      type: CrashEventType.crashConfirmed,
      magnitude: report.severityScore,
      report: report,
      gForce: gForce,
      gyroRads: gyroRads,
      inactivitySecs: inactivitySecs,
      speedKmh: preImpactSpeedKmh,
    ));
  }



  void reset() {
    _crashDetected = false;
    _confidenceScore = 0.0;
    _impactTime = null;
    _orientationTime = null;
    _inactivityTime = null;
    _peakImpactGs = 0.0;
    _peakGyroRads = 0.0;
    _motionAnalyzer.reset();
    _orientationAnalyzer.reset();
    _inactivityDetector.reset();
  }

  void dispose() {
    stop();
    _eventController.close();
    _crashController.close();
  }
}

// ============================================================================
// INTERNAL ANALYZER CLASSES (Sensor Noise Filters)
// ============================================================================

class _MotionAnalyzer {
  final double impactThresholdMs2;
  final Function(double) onImpact;
  int _consecutiveHighG = 0;
  bool _impactDetected = false;

  _MotionAnalyzer({required this.impactThresholdMs2, required this.onImpact});

  void analyze(UserAccelerometerEvent event) {
    if (_impactDetected) return;
    double acc = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    if (acc > impactThresholdMs2) {
      _consecutiveHighG++;
      // Require 2 consecutive high-G readings to avoid single-frame noise
      if (_consecutiveHighG >= 2) {
        _impactDetected = true;
        onImpact(acc);
      }
    } else {
      _consecutiveHighG = 0;
    }
  }

  void reset() {
    _consecutiveHighG = 0;
    _impactDetected = false;
  }
}

class _OrientationAnalyzer {
  final double rotationThreshold;
  final Function(double) onAbnormalOrientation;
  bool _detected = false;

  _OrientationAnalyzer({required this.rotationThreshold, required this.onAbnormalOrientation});

  void analyze(GyroscopeEvent event) {
    if (_detected) return;
    double rot = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    if (rot > rotationThreshold) {
      _detected = true;
      onAbnormalOrientation(rot);
    }
  }

  void reset() {
    _detected = false;
  }
}

class _InactivityDetector {
  final Function() onInactivityConfirmed;
  Timer? _timer;
  bool _isActive = false;
  bool _detected = false;

  _InactivityDetector({required this.onInactivityConfirmed});

  void startTracking() {
    if (_isActive) return;
    _isActive = true;
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 15), () {
      if (!_detected) {
        _detected = true;
        onInactivityConfirmed();
      }
    });
  }

  void analyze(UserAccelerometerEvent event) {
    if (!_isActive || _detected) return;
    double acc = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    // If movement > 1.2 m/s^2 detected, user is moving/conscious -> reset timer
    if (acc > 1.2) {
      startTracking();
    }
  }

  void stopTracking() {
    _isActive = false;
    _timer?.cancel();
  }

  void reset() {
    _detected = false;
    stopTracking();
  }
}
