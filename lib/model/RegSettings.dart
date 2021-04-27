class RegSettings {
  int currentBandwidth = 0;
  double speedKp = 0;
  double speedKi = 0;
  double fieldWeakingKp = 0;
  double fieldWeakingKi = 0;
  double batteryCurrentKp = 0;
  double batteryCurrentKi = 0;
  int powerUpSpeed = 0;
  int motorCurrentLimitRange = 0;

  int speedUpSpeed = 0;
  int speedDownSpeed = 0;
  int fieldWeakingMaxCurrent = 0;

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
      'motorCurrentLimitRange': motorCurrentLimitRange,
      'speedUpSpeed': speedUpSpeed,
      'speedDownSpeed': speedDownSpeed,
      'fieldWeakingMaxCurrent': fieldWeakingMaxCurrent,

    };
}