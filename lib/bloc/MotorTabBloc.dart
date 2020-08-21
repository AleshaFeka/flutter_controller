import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_controller/core/Packet.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/MotorSettings.dart';
import 'package:flutter_controller/model/Parameter.dart';
import 'package:flutter_controller/util/Mapper.dart';

enum MotorSettingsCommand { READ, WRITE, SAVE }

class MotorTabBloc {
  MotorSettings _motorSettings;
  BluetoothInteractor _bluetoothInteractor;

  StreamController _motorInstantSettingsStreamController = StreamController<MotorSettings>.broadcast();
  Stream get motorInstantSettingsStream => _motorInstantSettingsStreamController.stream;

  StreamController<MotorSettingsCommand> _motorSettingsCommandStreamController = StreamController<MotorSettingsCommand>.broadcast();
  StreamSink<MotorSettingsCommand> get motorSettingsCommandStream => _motorSettingsCommandStreamController.sink;

  StreamController<Parameter> _motorSettingsDataStreamController
    = StreamController<Parameter>.broadcast(sync: true); //Sync to avoid async between changing parameters and writing to controller
  StreamSink<Parameter> get motorSettingsDataStream => _motorSettingsDataStreamController.sink;

  MotorTabBloc(this._bluetoothInteractor) {
    _motorSettingsCommandStreamController.stream.listen(_handleCommand);
    _motorSettingsDataStreamController.stream.listen(_handleSettingsData);
  }

  void _handleSettingsData(Parameter motorParameter) {
    switch (motorParameter.name) {
      case "motorPolePairs" :
        _motorSettings.motorPolePairs = int.parse(motorParameter.value);
        break;
      case "motorDirection" :
        _motorSettings.motorDirection = int.parse(motorParameter.value);
        break;
      case "motorSpeedMax" :
        _motorSettings.motorSpeedMax = int.parse(motorParameter.value);
        break;
      case "motorVoltageMax" :
        _motorSettings.motorVoltageMax = int.parse(motorParameter.value);
        break;
      case "fieldWakingCurrent" :
        _motorSettings.fieldWakingCurrent = int.parse(motorParameter.value);
        break;
      case "motorPositionSensorType" :
        _motorSettings.motorPositionSensorType = int.parse(motorParameter.value);
        break;
      case "motorTemperatureSensorType" :
        _motorSettings.motorTemperatureSensorType = int.parse(motorParameter.value);
        break;
      case "wheelDiameter" :
        _motorSettings.wheelDiameter = int.parse(motorParameter.value);
        break;

      case "motorFlux" :
        _motorSettings.motorFlux = double.parse(motorParameter.value);
        break;
      case "motorTemperatureMax" :
        _motorSettings.motorTemperatureMax = double.parse(motorParameter.value);
        break;
      case "motorTemperatureLimit" :
        _motorSettings.motorTemperatureLimit = double.parse(motorParameter.value);
        break;
      case "motorCurrentMax" :
        _motorSettings.motorCurrentMax = double.parse(motorParameter.value);
        break;
      case "motorStatorResistance" :
        _motorSettings.motorStatorResistance = double.parse(motorParameter.value);
        break;
      case "motorInductance" :
        _motorSettings.motorInductance = double.parse(motorParameter.value);
        break;
      case "motorKv" :
        _motorSettings.motorKv = double.parse(motorParameter.value);
        break;
      case "phaseCorrection" :
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
    }
  }

  void _packetHandler(Packet packet) {
    print(packet.toBytes);
    _motorSettings = Mapper.packetToMotorSettings(packet);
    _motorInstantSettingsStreamController.sink.add(_motorSettings);
  }

  void _motorSettingsRead() {
    _bluetoothInteractor.sendMessage(Packet(1, 0, Uint8List(28)));
    _bluetoothInteractor.startMonitoring(_packetHandler);

/*
    _motorSettings = _bluetoothInteractor.readMotorSettings();
    _motorInstantSettingsStreamController.sink.add(_motorSettings);
*/
  }

  void _motorSettingsWrite() {
    _bluetoothInteractor.writeMotorSettings(_motorSettings);
  }

  void _motorSettingsSave() {
    _bluetoothInteractor.save();
  }

  void dispose() {
    _bluetoothInteractor.stopMonitoring();
    _motorInstantSettingsStreamController.close();
    _motorSettingsCommandStreamController.close();
    _motorSettingsDataStreamController.close();
  }
}