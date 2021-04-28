class ControllerInfo {
  int firmwareDateLittle = 0;
  int firmwareDateBig = 0;
  int controllerMaxCurrent = 0;
  int controllerMaxVoltage = 0;
  int processorIdLittle = 0;
  int processorIdBig = 0;

  ControllerInfo.zero();

  ControllerInfo(
    this.firmwareDateLittle,
    this.firmwareDateBig,
    this.controllerMaxCurrent,
    this.controllerMaxVoltage,
    this.processorIdLittle,
    this.processorIdBig,
  );
}
