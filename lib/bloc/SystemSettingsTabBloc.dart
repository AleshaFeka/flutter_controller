import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_controller/core/Packet.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/Parameter.dart';
import 'package:flutter_controller/model/SystemSettings.dart';
import 'package:flutter_controller/util/Mapper.dart';

enum SystemSettingsCommand { READ, WRITE, SAVE, REFRESH }

class SystemSettingsTabBloc {
  static const SCREEN_NUMBER = 3;

  StreamController _systemSettingsViewModelStreamController = StreamController<SystemSettings>.broadcast();
  Stream get systemSettingsViewModelStream => _systemSettingsViewModelStreamController.stream;

  StreamController<SystemSettingsCommand> _systemSettingsCommandStreamController =
      StreamController<SystemSettingsCommand>.broadcast();
  StreamSink<SystemSettingsCommand> get systemSettingsCommandStream => _systemSettingsCommandStreamController.sink;

  StreamController<Parameter> _systemSettingsDataStreamController = StreamController<Parameter>.broadcast(sync: true);
  StreamSink<Parameter> get systemSettingsDataStream => _systemSettingsDataStreamController.sink;

  BluetoothInteractor _bluetoothInteractor;

  SystemSettings _settings = SystemSettings.zero();

  SystemSettingsTabBloc(this._bluetoothInteractor) {
    _systemSettingsCommandStreamController.stream.listen(_handleCommand);
    _systemSettingsDataStreamController.stream.listen(_handleSettingsData);
  }

  void _handleSettingsData(Parameter analogParameter) {
    switch (analogParameter.name) {
      case "hall1":
        _settings.hall1 = int.parse(analogParameter.value);
        break;
      case "hall2":
        _settings.hall2 = int.parse(analogParameter.value);
        break;
      case "hall3":
        _settings.hall3 = int.parse(analogParameter.value);
        break;
      case "hall4":
        _settings.hall4= int.parse(analogParameter.value);
        break;
      case "hall5":
        _settings.hall5 = int.parse(analogParameter.value);
        break;
      case "hall6":
        _settings.hall6 = int.parse(analogParameter.value);
        break;

      case "motorResistance":
        _settings.motorResistance = double.parse(analogParameter.value);
        break;
      case "motorInduction":
        _settings.motorInduction = double.parse(analogParameter.value);
        break;
      case "motorMagnetStream":
        _settings.motorMagnetStream = double.parse(analogParameter.value);
        break;
      case "identificationMode":
        _settings.identificationMode = int.parse(analogParameter.value);
        break;
      case "identificationCurrent":
        _settings.identificationCurrent = int.parse(analogParameter.value);
        break;
    }
  }

  void _handleCommand(SystemSettingsCommand event) {
    switch (event) {
      case SystemSettingsCommand.READ:
        _systemSettingsRead();
        break;
      case SystemSettingsCommand.WRITE:
        _systemSettingsWrite();
        break;
      case SystemSettingsCommand.SAVE:
        _systemSettingsSave();
        break;
      case SystemSettingsCommand.REFRESH:
        _systemSettingsRefresh();
        break;
    }
  }

  void _systemSettingsRead() {
    _bluetoothInteractor.sendMessage(Packet(SCREEN_NUMBER, 0, Uint8List(28)));
    _bluetoothInteractor.startListenSerial(_packetHandler);
  }

  void _packetHandler(Packet packet) {
    print(packet.toBytes);
    if (packet.screenNum == SCREEN_NUMBER) {
      _settings = Mapper.packetToSystemSettings(packet);
      _systemSettingsRefresh();
    }
  }

  void _systemSettingsWrite() {
    Packet packet = Mapper.systemSettingsToPacket(_settings);
    _bluetoothInteractor.sendMessage(packet);
  }

  void _systemSettingsSave() {
    _bluetoothInteractor.save();
  }

  void _systemSettingsRefresh() {
    _systemSettingsViewModelStreamController.sink.add(_settings);

  }

  void close() {
    _systemSettingsViewModelStreamController.close();
    _systemSettingsCommandStreamController.close();
    _systemSettingsDataStreamController.close();
  }
}
