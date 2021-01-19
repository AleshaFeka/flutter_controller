class DriveSettings {
  int throttleUpSpeed = 0;
  int throttleDownSpeed = 0;
  int throttlePhaseCurrentMax = 0;
  int brakeUpSpeed = 0;
  int brakeDownSpeed = 0;
  int brakePhaseCurrentMax = 0;
  int discreetBrakeCurrentUpSpeed = 0;
  int discreetBrakeCurrentDownSpeed = 0;
  int discreetBrakeCurrentMax = 0;
  int modeControlCommandWord = 0;
  int phaseWeakingCurrent = 0;
  int pwmFrequency = 0;
  int processorIdHigh = 0;
  int processorIdLow = 0;

  DriveSettings.zero();

  Map<String, dynamic> toJson() =>
    {
      'throttleUpSpeed': throttleUpSpeed,
      'throttleDownSpeed': throttleDownSpeed,
      'throttlePhaseCurrentMax': throttlePhaseCurrentMax,
      'brakeUpSpeed': brakeUpSpeed,
      'brakeDownSpeed': brakeDownSpeed,
      'brakePhaseCurrentMax': brakePhaseCurrentMax,
      'discreetBrakeCurrentUpSpeed': discreetBrakeCurrentUpSpeed,
      'discreetBrakeCurrentDownSpeed': discreetBrakeCurrentDownSpeed,
      'discreetBrakeCurrentMax': discreetBrakeCurrentMax,
      'modeControlCommandWord': modeControlCommandWord,
      'phaseWeakingCurrent': phaseWeakingCurrent,
      'pwmFrequency': pwmFrequency,
      'processorIdHigh': processorIdHigh,
      'processorIdLow': processorIdLow,
    };
}