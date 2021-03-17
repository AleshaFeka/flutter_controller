class SystemSettings {
  int hall1 = 0;
  int hall2 = 0;
  int hall3 = 0;
  int hall4 = 0;
  int hall5 = 0;
  int hall6 = 0;
  double motorResistance = 0;
  double motorInduction = 0;
  double motorMagnetStream = 0;
  int identificationMode = 0;
  int identificationCurrent = 0;

  SystemSettings.zero();

  Map<String, dynamic> toJson() =>
    {
      'hall1': hall1,
      'hall2': hall2,
      'hall3': hall3,
      'hall4': hall4,
      'hall5': hall5,
      'hall6': hall6,
      'motorResistance': motorResistance,
      'motorInduction': motorInduction,
      'motorMagnetStream': motorMagnetStream,
      'identificationMode': identificationMode,
      'identificationCurrent': identificationCurrent
    };
}