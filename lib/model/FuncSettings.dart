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

  FuncSettings.zero() {
    in1 = 0;
    in2 = 0;
    in3 = 0;
    in4 = 0;

    invertIn1 = false;
    invertIn2 = false;
    invertIn3 = false;
    invertIn4 = false;

    useCan = false;

    s1MaxTorqueCurrent = 0;
    s1MaxBrakeCurrent = 0;
    s1MaxSpeed = 0;
    s1MaxBatteryCurrent = 0;
    s1MaxFieldWeakingCurrent = 0;

    s2MaxTorqueCurrent = 0;
    s2MaxBrakeCurrent = 0;
    s2MaxSpeed = 0;
    s2MaxBatteryCurrent = 0;
    s2MaxFieldWeakingCurrent = 0;
  }

  Map<String, dynamic> toJson() =>
    {
      'in1': in1,
      'in2': in2,
      'in3': in3,
      'in4': in4,
      'invertIn1': invertIn1,
      'invertIn2': invertIn2,
      'invertIn3': invertIn3,
      'invertIn4': invertIn4,

      's1MaxTorqueCurrent': s1MaxTorqueCurrent,
      's1MaxBrakeCurrent': s1MaxBrakeCurrent,
      's1MaxSpeed': s1MaxSpeed,
      's1MaxBatteryCurrent': s1MaxBatteryCurrent,
      's1MaxFieldWeakingCurrent': s1MaxFieldWeakingCurrent,

      's2MaxTorqueCurrent': s2MaxTorqueCurrent,
      's2MaxBrakeCurrent': s2MaxBrakeCurrent,
      's2MaxSpeed': s2MaxSpeed,
      's2MaxBatteryCurrent': s2MaxBatteryCurrent,
      's2MaxFieldWeakingCurrent': s2MaxFieldWeakingCurrent,
    };

}