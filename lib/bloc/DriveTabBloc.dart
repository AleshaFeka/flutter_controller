import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_controller/core/Packet.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/DriveSettings.dart';
import 'package:flutter_controller/model/Parameter.dart';
import 'package:flutter_controller/util/Mapper.dart';

enum DriveSettingsCommand { READ, WRITE, SAVE, REFRESH }
enum DriveControlMode { SINE, FOC, SENSORLESS, BLDC }
enum DrivePwmFrequency { PWM8000, PWM10000, PWM12000, PWM15000, PWM18000, PWM20000, PWM22000 }

class DriveTabBloc {
  static const SCREEN_NUMBER = 2;

  BluetoothInteractor _bluetoothInteractor;
  DriveSettings _driveSettings;

  StreamController _driveViewModelStreamController = StreamController<DriveSettings>.broadcast();
  Stream get driveViewModelStream => _driveViewModelStreamController.stream;

  StreamController<DriveSettingsCommand> _driveSettingsCommandStreamController = StreamController<DriveSettingsCommand>.broadcast();
  StreamSink<DriveSettingsCommand> get driveSettingsCommandStream => _driveSettingsCommandStreamController.sink;

  StreamController<Parameter> _driveSettingsDataStreamController = StreamController<Parameter>.broadcast(sync: true); //Sync to avoid async between changing parameters and writing to controller
  StreamSink<Parameter> get driveSettingsDataStream => _driveSettingsDataStreamController.sink;

  DriveTabBloc(this._bluetoothInteractor){
    _driveSettingsCommandStreamController.stream.listen(_handleCommand);
    _driveSettingsDataStreamController.stream.listen(_handleSettingsData);
  }

  void _handleSettingsData(Parameter motorParameter) {
    switch (motorParameter.name) {
      case "throttleUpSpeed":
        _driveSettings.throttleUpSpeed = int.parse(motorParameter.value);
        break;
      case "throttleDownSpeed":
        _driveSettings.throttleDownSpeed = int.parse(motorParameter.value);
        break;
      case "throttlePhaseCurrentMax":
        _driveSettings.throttlePhaseCurrentMax = int.parse(motorParameter.value);
        break;

      case "brakeUpSpeed":
        _driveSettings.brakeUpSpeed = int.parse(motorParameter.value);
        break;
      case "brakeDownSpeed":
        _driveSettings.brakeDownSpeed = int.parse(motorParameter.value);
        break;
      case "brakePhaseCurrentMax":
        _driveSettings.brakePhaseCurrentMax = int.parse(motorParameter.value);
        break;

      case "discreetBrakeCurrentUpSpeed":
        _driveSettings.discreetBrakeCurrentUpSpeed = int.parse(motorParameter.value);
        break;
      case "discreetBrakeCurrentDownSpeed":
        _driveSettings.discreetBrakeCurrentDownSpeed = int.parse(motorParameter.value);
        break;
      case "discreetBrakeCurrentMax":
        _driveSettings.discreetBrakeCurrentMax = int.parse(motorParameter.value);
        break;

      case "phaseWeakingCurrent":
        _driveSettings.phaseWeakingCurrent = int.parse(motorParameter.value);
        break;
      case "pwmFrequency":
        print("motorParameter.value = ${motorParameter.value}");
        final index = motorParameter.value.trim().indexOf(".PWM") + ".PWM".length;
        final frequency = motorParameter.value.trim().substring(index);
        _driveSettings.pwmFrequency = int.parse(frequency);
        break;
      case "controlMode":
        var sensorType = DriveControlMode
          .values
          .firstWhere((element) => element.toString() == motorParameter.value);
        _driveSettings.controlMode = DriveControlMode.values.indexOf(sensorType);
        break;

      case "processorIdHigh":
        _driveSettings.processorIdHigh = int.parse(motorParameter.value);
        break;
      case "processorIdLow":
        _driveSettings.processorIdLow = int.parse(motorParameter.value);
        break;
    }
  }

  void _handleCommand(DriveSettingsCommand event) {
    switch (event) {
      case DriveSettingsCommand.READ:
        _driveSettingsRead();
        break;
      case DriveSettingsCommand.WRITE:
        _driveSettingsWrite();
        break;
      case DriveSettingsCommand.SAVE:
        _driveSettingsSave();
        break;
      case DriveSettingsCommand.REFRESH:
        _driveSettingsRefresh();
        break;
    }
  }

  void _driveSettingsRead() {
    _bluetoothInteractor.sendMessage(Packet(SCREEN_NUMBER, 0, Uint8List(28)));
    _bluetoothInteractor.startListenSerial(_packetHandler);
  }

  void _driveSettingsRefresh() {
    _driveViewModelStreamController.sink.add(_driveSettings);
  }

  void _driveSettingsWrite() {
    Packet packet = Mapper.driveSettingsToPacket(_driveSettings);
    _bluetoothInteractor.sendMessage(packet);
  }

  void _driveSettingsSave() {
    _bluetoothInteractor.save();
  }

  void _packetHandler(Packet packet) {
    if (packet.screenNum == SCREEN_NUMBER) {
      _driveSettings = Mapper.packetToDriveSettings(packet);
      _driveSettingsRefresh();
    }
  }

  void dispose() {
    _bluetoothInteractor.stopListenSerial();
    _driveViewModelStreamController.close();
    _driveSettingsCommandStreamController.close();
    _driveSettingsDataStreamController.close();
  }
}