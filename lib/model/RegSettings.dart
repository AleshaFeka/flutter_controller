class RegSettings {
  int currentBandwidth = 0;
  int speedKp = 0;
  int speedKi = 0;
  int fieldWeakingKp = 0;
  int fieldWeakingKi = 0;
  int batteryCurrentKp = 0;
  int batteryCurrentKi = 0;
  int powerUpSpeed = 0;
  int motorCurrentLimitRange = 0;

  RegSettings.zero();

  Map<String, dynamic> toJson() =>
    {
      'currentBandwidth': currentBandwidth,
      'speedKp': speedKp,
      'speedKi': speedKi,
      'fieldWeakingKp': fieldWeakingKp,
      'fieldWeakingKi': fieldWeakingKi,
      'batteryCurrentKp': batteryCurrentKp,
      'batteryCurrentKi': batteryCurrentKi,
      'powerUpSpeed': powerUpSpeed,
      'motorCurrentLimitRange': motorCurrentLimitRange
    };
}