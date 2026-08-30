import 'sensor_sample.dart';

class SensorBuffer {
  final int capacity; // number of samples to keep
  final List<SensorSample> _buffer = [];

  SensorBuffer({required this.capacity});

  void add(SensorSample sample) {
    if (_buffer.length >= capacity) {
      _buffer.removeAt(0);
    }
    _buffer.add(sample);
  }

  List<SensorSample> get samples => List.unmodifiable(_buffer);

  void updateLast(SensorSample sample) {
    if (_buffer.isNotEmpty) {
      _buffer[_buffer.length - 1] = sample;
    }
  }

  void clear() => _buffer.clear();
}

