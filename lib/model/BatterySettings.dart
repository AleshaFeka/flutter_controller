import 'dart:math';

class BatterySettings {
  int fullVoltage = 0;
  int lowVoltage = 0;
  int maxPower = 0;
  int driveCurrent = 0;
  int regenCurrent = 0;
/*
  int limitCurrentStart = 0;
  double batteryResistance = 0;
*/
  int powerReductionVoltage;

  BatterySettings.zero();

  BatterySettings.random(int range) {
    var random = Random();
    fullVoltage = random.nextInt(range);
    lowVoltage = random.nextInt(range);
    maxPower = random.nextInt(range);
    driveCurrent = random.nextInt(range);
    regenCurrent = random.nextInt(range);
/*
    limitCurrentStart = random.nextInt(range);
    batteryResistance = random.nextDouble() * range;
*/
    powerReductionVoltage = random.nextInt(range);
  }

  Map<String, dynamic> toJson() => {
/*
        'batteryResistance': batteryResistance,
        'limitCurrentStart': limitCurrentStart,
*/
        'fullVoltage': fullVoltage,
        'lowVoltage': lowVoltage,
        'maxPower': maxPower,
        'driveCurrent': driveCurrent,
        'regenCurrent': regenCurrent,
        'powerReductionVoltage': powerReductionVoltage
      };
}
