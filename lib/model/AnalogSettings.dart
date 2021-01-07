class AnalogSettings {
  double throttleMin = 0;
  double throttleMax = 0;
  int throttleCurveCoefficient1 = 0;
  int throttleCurveCoefficient2 = 0;
  int throttleCurveCoefficient3 = 0;
  double brakeMin = 0;
  double brakeMax = 0;
  int brakeCurveCoefficient1 = 0;
  int brakeCurveCoefficient2 = 0;
  int brakeCurveCoefficient3 = 0;

  AnalogSettings.zero();

  Map<String, dynamic> toJson() =>
    {
      'throttleMin': throttleMin,
      'throttleMax': throttleMax,
      'throttleCurveCoefficient1': throttleCurveCoefficient1,
      'throttleCurveCoefficient2': throttleCurveCoefficient2,
      'throttleCurveCoefficient3': throttleCurveCoefficient3,
      'brakeMin': brakeMin,
      'brakeMax': brakeMax,
      'brakeCurveCoefficient1': brakeCurveCoefficient1,
      'brakeCurveCoefficient2': brakeCurveCoefficient2,
      'brakeCurveCoefficient3': brakeCurveCoefficient3,
    };

}