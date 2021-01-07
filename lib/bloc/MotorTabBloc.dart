import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_controller/core/Packet.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/MotorSettings.dart';
import 'package:flutter_controller/model/Parameter.dart';
import 'package:flutter_controller/util/Mapper.dart';

enum MotorSettingsCommand { READ, WRITE, SAVE, REFRESH }

enum MotorTemperatureSensor { NO_SENSOR, KTY84, KTY83, KTY81, KTY83_2K }
enum MotorPositionSensor { NO_SENSOR, HALL, ENCODER }

class MotorTabBloc {
  static const SCREEN_NUMBER = 1;

  MotorSettings _motorSettings;
  BluetoothInteractor _bluetoothInteractor;

  StreamController _motorViewModelStreamController = StreamController<MotorSettings>.broadcast();
  Stream get motorViewModelStream => _motorViewModelStreamController.stream;

  StreamController<MotorSettingsCommand> _motorSettingsCommandStreamController = StreamController<MotorSettingsCommand>.broadcast();
  StreamSink<MotorSettingsCommand> get motorSettingsCommandStream => _motorSettingsCommandStreamController.sink;

  StreamController<Parameter> _motorSettingsDataStreamController = StreamController<Parameter>.broadcast(sync: true); //Sync to avoid async between changing parameters and writing to controller
  StreamSink<Parameter> get motorSettingsDataStream => _motorSettingsDataStreamController.sink;

  MotorTabBloc(this._bluetoothInteractor) {
    _motorSettingsCommandStreamController.stream.listen(_handleCommand);
    _motorSettingsDataStreamController.stream.listen(_handleSettingsData);
  }

  void _handleSettingsData(Parameter motorParameter) {
    switch (motorParameter.name) {
      case "motorPolePairs":
        _motorSettings.motorPolePairs = int.parse(motorParameter.value);
        break;
      case "motorDirection":
        _motorSettings.motorDirection = int.parse(motorParameter.value);
        break;
      case "motorSpeedMax":
        _motorSettings.motorSpeedMax = int.parse(motorParameter.value);
        break;
      case "motorVoltageMax":
        _motorSettings.motorVoltageMax = int.parse(motorParameter.value);
        break;
      case "fieldWakingCurrent":
        _motorSettings.fieldWakingCurrent = int.parse(motorParameter.value);
        break;
      case "wheelDiameter":
        _motorSettings.wheelDiameter = int.parse(motorParameter.value);
        break;

      case "motorTemperatureSensorType":
        var sensorType = MotorTemperatureSensor
          .values
          .firstWhere((element) => element.toString() == motorParameter.value);
        _motorSettings.motorTemperatureSensorType = MotorTemperatureSensor.values.indexOf(sensorType);
        break;
      case "motorPositionSensorType":
        var sensorType = MotorPositionSensor
          .values
          .firstWhere((element) => element.toString() == motorParameter.value);
        _motorSettings.motorPositionSensorType = MotorPositionSensor.values.indexOf(sensorType);
        break;

      case "motorFlux":
        _motorSettings.motorFlux = double.parse(motorParameter.value);
        break;
      case "motorTemperatureMax":
        _motorSettings.motorTemperatureMax = double.parse(motorParameter.value);
        break;
      case "motorTemperatureLimit":
        _motorSettings.motorTemperatureLimit = double.parse(motorParameter.value);
        break;
      case "motorCurrentMax":
        _motorSettings.motorCurrentMax = double.parse(motorParameter.value);
        break;
      case "motorStatorResistance":
        _motorSettings.motorStatorResistance = double.parse(motorParameter.value);
        break;
      case "motorInductance":
        _motorSettings.motorInductance = double.parse(motorParameter.value);
        break;
      case "motorKv":
        _motorSettings.motorKv = double.parse(motorParameter.value);
        break;
      case "phaseCorrection":
        _motorSettings.phaseCorrection = double.parse(motorParameter.value);
        break;
    }
  }

  void _handleCommand(MotorSettingsCommand event) {
    switch (event) {
      case MotorSettingsCommand.READ:
        _motorSettingsRead();
        break;
      case MotorSettingsCommand.WRITE:
        _motorSettingsWrite();
        break;
      case MotorSettingsCommand.SAVE:
        _motorSettingsSave();
        break;
      case MotorSettingsCommand.REFRESH:
        _motorSettingsRefresh();
        break;
    }
  }

  void _packetHandler(Packet packet) {
    print('MotorTabBloc   _packetHandler');
    print(packet.toBytes);
    if (packet.screenNum == SCREEN_NUMBER) {
      _motorSettings = Mapper.packetToMotorSettings(packet);
      _motorSettingsRefresh();
    }
  }

    void _motorSettingsRead() {
    _bluetoothInteractor.sendMessage(Packet(SCREEN_NUMBER, 0, Uint8List(28)));
    _bluetoothInteractor.startListenSerial(_packetHandler);
  }

  void _motorSettingsRefresh() {
    _motorViewModelStreamController.sink.add(_motorSettings);
  }

  void _motorSettingsWrite() {
    Packet packet = Mapper.motorSettingsToPacket(_motorSettings);
    _bluetoothInteractor.sendMessage(packet);
  }

  void _motorSettingsSave() {
    _bluetoothInteractor.save();
  }

  void dispose() {
    _bluetoothInteractor.stopListenSerial();
    _motorViewModelStreamController.close();
    _motorSettingsCommandStreamController.close();
    _motorSettingsDataStreamController.close();
  }
}
