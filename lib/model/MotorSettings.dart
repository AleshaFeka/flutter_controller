import 'dart:math';

class MotorSettings {
  int motorPolePairs = 0;
  int motorDirection = -1;
  int motorSpeedMax = 0;
  int motorVoltageMax = 0; //Unused((
  int fieldWakingCurrent = 0;
  double motorTemperatureMax = 0;
  double motorTemperatureLimit = 0;
  double motorCurrentMax = 0;
  double motorStatorResistance = 0;
  double motorInductance = 0;
  double motorKv = 0;
  double phaseCorrection = 0;

  MotorSettings.zero();

  MotorSettings.random(int range) {
    var random = Random();
    motorPolePairs = random.nextInt(range);
    motorDirection = random.nextInt(range);
    motorSpeedMax = random.nextInt(range);
    motorVoltageMax = random.nextInt(range);
    fieldWakingCurrent = random.nextInt(range);
    motorTemperatureMax = random.nextDouble() * range ;
    motorTemperatureLimit = random.nextDouble() * range ;
    motorCurrentMax = random.nextDouble() * range ;
    motorStatorResistance = random.nextDouble() * range ;
    motorInductance = random.nextDouble() * range ;
    motorKv = random.nextDouble() * range ;
    phaseCorrection = random.nextDouble() * range ;
  }

  Map<String, dynamic> toJson() =>
    {
      'motorPolePairs': motorPolePairs,
      'motorDirection': motorDirection,
      'motorSpeedMax': motorSpeedMax,
      'motorVoltageMax': motorVoltageMax,
      'fieldWakingCurrent': fieldWakingCurrent,
      'motorTemperatureMax': motorTemperatureMax,
      'motorTemperatureLimit': motorTemperatureLimit,
      'motorCurrentMax': motorCurrentMax,
      'motorStatorResistance': motorStatorResistance,
      'motorInductance': motorInductance,
      'motorKv': motorKv,
      'phaseCorrection': phaseCorrection
    };
}