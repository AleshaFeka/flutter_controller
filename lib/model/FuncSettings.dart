import 'dart:math';

class FuncSettings {
  int in1;
  int in2;
  int in3;
  int in4;

  bool invertIn1;
  bool invertIn2;
  bool invertIn3;
  bool invertIn4;

  bool useCan;

  int s1MaxTorqueCurrent;
  int s1MaxBrakeCurrent;
  int s1MaxSpeed;
  int s1MaxBatteryCurrent;
  int s1MaxFieldWeakingCurrent;

  int s2MaxTorqueCurrent;
  int s2MaxBrakeCurrent;
  int s2MaxSpeed;
  int s2MaxBatteryCurrent;
  int s2MaxFieldWeakingCurrent;

  FuncSettings.random(int max) {
    final r = Random();
    in1 = r.nextInt(max);
    in2 = r.nextInt(max);
    in3 = r.nextInt(max);
    in4 = r.nextInt(max);

    invertIn1 = r.nextInt(max) % 2 == 0;
    invertIn2 = r.nextInt(max) % 2 != 0;
    invertIn3 = r.nextInt(max) % 2 == 0;
    invertIn4 = r.nextInt(max) % 2 != 0;

    useCan = r.nextInt(max) % 2 == 0;

    s1MaxTorqueCurrent = r.nextInt(max);
    s1MaxBrakeCurrent = r.nextInt(max);
    s1MaxSpeed = r.nextInt(max);
    s1MaxBatteryCurrent = r.nextInt(max);
    s1MaxFieldWeakingCurrent = r.nextInt(max);

    s2MaxTorqueCurrent = r.nextInt(max);
    s2MaxBrakeCurrent = r.nextInt(max);
    s2MaxSpeed = r.nextInt(max);
    s2MaxBatteryCurrent = r.nextInt(max);
    s2MaxFieldWeakingCurrent = r.nextInt(max);
  }
}