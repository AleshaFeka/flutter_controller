import 'dart:async';

import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/MotorSettings.dart';

enum MotorSettingsCommand { READ, WRITE, SAVE }

class MotorParameter {
  String name;
  String value;
  MotorParameter(this.name, this. value);
}

class MotorTabBloc {
  MotorSettings _motorSettings;
  BluetoothInteractor _bluetoothInteractor;

  StreamController _motorInstantSettingsStreamController = StreamController<MotorSettings>();
  Stream get motorInstantSettingsStream => _motorInstantSettingsStreamController.stream;

  StreamController<MotorSettingsCommand> _motorSettingsCommandStreamController = StreamController<MotorSettingsCommand>();
  StreamSink<MotorSettingsCommand> get motorSettingsCommandStream => _motorSettingsCommandStreamController.sink;

  StreamController<MotorParameter> _motorSettingsDataStreamController
    = StreamController<MotorParameter>(sync: true); //Sync to avoid race between changing parameters and writing to controller
  StreamSink<MotorParameter> get motorSettingsDataStream => _motorSettingsDataStreamController.sink;

  MotorTabBloc(this._bluetoothInteractor) {
    _motorSettingsCommandStreamController.stream.listen(_handleCommand);
    _motorSettingsDataStreamController.stream.listen(_handleSettingsData);
  }

  void _handleSettingsData(MotorParameter motorParameter) {
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
//    _motorInstantSettingsStreamController.sink.add(_motorSettings);
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

  void _motorSettingsRead() {
    _motorSettings = _bluetoothInteractor.read();
    print("Readed from bluetooth - $_motorSettings");
    _motorInstantSettingsStreamController.sink.add(_motorSettings);
  }

  void _motorSettingsWrite() {
    _bluetoothInteractor.write(_motorSettings);
  }

  void _motorSettingsSave() {
    _bluetoothInteractor.save();
  }

  void dispose() {
    _motorInstantSettingsStreamController.close();
    _motorSettingsCommandStreamController.close();
    _motorSettingsDataStreamController.close();
  }
}