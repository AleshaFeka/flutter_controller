import 'dart:math';

class BatterySettings {
  int fullVoltage = 0;
  int lowVoltage = 0;
  int limitCurrentStart = 0;
  int maxPower = 0;
  int driveCurrent = 0;
  int regenCurrent = 0;
  double batteryR = 0;

  BatterySettings.zero();

  BatterySettings.random(int range) {
    var random = Random();
    fullVoltage = random.nextInt(range);
    lowVoltage = random.nextInt(range);
    limitCurrentStart = random.nextInt(range);
    maxPower = random.nextInt(range);
    driveCurrent = random.nextInt(range);
    regenCurrent = random.nextInt(range);
    batteryR = random.nextDouble() * range;
  }
}
