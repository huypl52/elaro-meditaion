class SensorRuntime {
  SensorRuntime._();

  static final SensorRuntime instance = SensorRuntime._();

  bool _sensorAvailable = true;

  bool get sensorAvailable => _sensorAvailable;

  void setSensorAvailableForTests(bool value) {
    _sensorAvailable = value;
  }

  void resetForTests() {
    _sensorAvailable = true;
  }
}

