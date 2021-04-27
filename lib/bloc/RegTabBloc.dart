import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_controller/core/Packet.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/Parameter.dart';
import 'package:flutter_controller/model/RegSettings.dart';
import 'package:flutter_controller/util/Mapper.dart';

enum RegSettingsCommand { READ, WRITE, SAVE, REFRESH }

class RegTabBloc {
  static const SCREEN_NUMBER = 5;

  BluetoothInteractor _bluetoothInteractor;
  RegSettings _regSettings;

  StreamController _regViewModelStreamController = StreamController<RegSettings>.broadcast();

  Stream get regViewModelStream => _regViewModelStreamController.stream;

  StreamController<RegSettingsCommand> _regSettingsCommandStreamController =
      StreamController<RegSettingsCommand>.broadcast();

  StreamSink<RegSettingsCommand> get regSettingsCommandStream => _regSettingsCommandStreamController.sink;

  StreamController<Parameter> _regSettingsDataStreamController = StreamController<Parameter>.broadcast(
      sync: true); //Sync to avoid async between changing parameters and writing to controller
  StreamSink<Parameter> get regSettingsDataStream => _regSettingsDataStreamController.sink;

  RegTabBloc(this._bluetoothInteractor) {
    _regSettingsCommandStreamController.stream.listen(_handleCommand);
    _regSettingsDataStreamController.stream.listen(_handleSettingsData);
  }

  void _handleSettingsData(Parameter motorParameter) {
    switch (motorParameter.name) {
      case "currentBandwidth":
        _regSettings.currentBandwidth = int.parse(motorParameter.value);
        break;
      case "speedKp":
        _regSettings.speedKp = double.parse(motorParameter.value);
        break;
      case "speedKi":
        _regSettings.speedKi = double.parse(motorParameter.value);
        break;
      case "fieldWeakingKp":
        _regSettings.fieldWeakingKp = double.parse(motorParameter.value);
        break;
      case "fieldWeakingKi":
        _regSettings.fieldWeakingKi = double.parse(motorParameter.value);
        break;
      case "batteryCurrentKp":
        _regSettings.batteryCurrentKp = double.parse(motorParameter.value);
        break;
      case "batteryCurrentKi":
        _regSettings.batteryCurrentKi = double.parse(motorParameter.value);
        break;
      case "powerUpSpeed":
        _regSettings.powerUpSpeed = int.parse(motorParameter.value);
        break;
      case "motorCurrentLimitRange":
        _regSettings.motorCurrentLimitRange = int.parse(motorParameter.value);
        break;

      case "speedUpSpeed":
        _regSettings.speedUpSpeed = int.parse(motorParameter.value);
        break;
      case "speedDownSpeed":
        _regSettings.speedDownSpeed = int.parse(motorParameter.value);
        break;
      case "fieldWeakingMaxCurrent":
        _regSettings.fieldWeakingMaxCurrent = int.parse(motorParameter.value);
        break;

    }
  }

  void _handleCommand(RegSettingsCommand event) {
    switch (event) {
      case RegSettingsCommand.READ:
        _regSettingsRead();
        break;
      case RegSettingsCommand.WRITE:
        _regSettingsWrite();
        break;
      case RegSettingsCommand.SAVE:
        _regSettingsSave();
        break;
      case RegSettingsCommand.REFRESH:
        _regSettingsRefresh();
        break;
    }
  }

  void _packetHandler(Packet packet) {
    if (packet.screenNum == SCREEN_NUMBER) {
      _regSettings = Mapper.packetToRegSettings(packet) ?? _regSettings;
      _regSettingsRefresh();
    }
  }

  void _regSettingsRead() {
    _bluetoothInteractor.sendMessage(Packet(SCREEN_NUMBER, 0, Uint8List(28)));
    _bluetoothInteractor.startListenSerial(_packetHandler);
  }

  void _regSettingsWrite() {
    Packet packet = Mapper.regSettingsToPacket(_regSettings);
    _bluetoothInteractor.sendMessage(packet);
  }

  void _regSettingsSave() {
    _bluetoothInteractor.save();
  }

  void _regSettingsRefresh() {
    _regViewModelStreamController.sink.add(_regSettings);
  }

  void close() {
    _regViewModelStreamController.close();
    _regSettingsCommandStreamController.close();
    _regSettingsDataStreamController.close();
  }
}
