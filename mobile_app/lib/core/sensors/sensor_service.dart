import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'models/sensor_sample.dart';
import 'models/sensor_buffer.dart';

class SensorService {
  static final SensorService _instance = SensorService._internal();
  factory SensorService() => _instance;
  SensorService._internal();

  final SensorBuffer _buffer = SensorBuffer(capacity: 200); // e.g., keep ~4 sec at 50Hz
  final StreamController<SensorSample> _controller = StreamController.broadcast();
  Stream<SensorSample> get sampleStream => _controller.stream;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  void start() {
    _accelSub = accelerometerEventStream().listen(_onAccelerometer);
    _gyroSub = gyroscopeEventStream().listen(_onGyroscope);
  }

  void stop() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _controller.close();
  }

  void _onAccelerometer(AccelerometerEvent event) {
    final sample = SensorSample(
      timestamp: DateTime.now(),
      accelerometerX: event.x,
      accelerometerY: event.y,
      accelerometerZ: event.z,
      gyroscopeX: 0.0,
      gyroscopeY: 0.0,
      gyroscopeZ: 0.0,
      speed: 0.0,
      latitude: 0.0,
      longitude: 0.0,
    );
    _addSample(sample);
  }

  void _onGyroscope(GyroscopeEvent event) {
    if (_buffer.samples.isNotEmpty) {
      final last = _buffer.samples.last;
      final updated = SensorSample(
        timestamp: last.timestamp,
        accelerometerX: last.accelerometerX,
        accelerometerY: last.accelerometerY,
        accelerometerZ: last.accelerometerZ,
        gyroscopeX: event.x,
        gyroscopeY: event.y,
        gyroscopeZ: event.z,
        speed: last.speed,
        latitude: last.latitude,
        longitude: last.longitude,
      );
      _buffer.updateLast(updated);
      _controller.add(updated);
    }
  }

  void _addSample(SensorSample sample) {
    _buffer.add(sample);
    _controller.add(sample);
  }

  List<SensorSample> get recentSamples => _buffer.samples;
}

