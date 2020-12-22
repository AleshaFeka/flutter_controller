class AnalogSettings {
  double throttleMin;
  double throttleMax;
  int throttleCurveCoefficient1;
  int throttleCurveCoefficient2;
  int throttleCurveCoefficient3;
  double brakeMin;
  double brakeMax;
  int brakeCurveCoefficient1;
  int brakeCurveCoefficient2;
  int brakeCurveCoefficient3;

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