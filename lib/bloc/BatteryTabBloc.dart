import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_controller/core/Packet.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/BatterySettings.dart';
import 'package:flutter_controller/model/Parameter.dart';
import 'package:flutter_controller/util/Mapper.dart';

enum BatterySettingsCommand { READ, WRITE, SAVE, REFRESH }

class BatteryTabBloc {
  BluetoothInteractor _bluetoothInteractor;
  BatterySettings _batterySettings;

  StreamController _batteryInstantSettingsStreamController = StreamController<BatterySettings>.broadcast();

  Stream get batteryInstantSettingsStream => _batteryInstantSettingsStreamController.stream;

  StreamController<BatterySettingsCommand> _batterySettingsCommandStreamController =
      StreamController<BatterySettingsCommand>.broadcast();

  StreamSink<BatterySettingsCommand> get batterySettingsCommandStream => _batterySettingsCommandStreamController.sink;

  StreamController<Parameter> _batterySettingsDataStreamController = StreamController<Parameter>.broadcast(sync: true);

  StreamSink<Parameter> get batterySettingsDataStream => _batterySettingsDataStreamController.sink;

  BatteryTabBloc(this._bluetoothInteractor) {
    _batterySettingsCommandStreamController.stream.listen(_handleCommand);
    _batterySettingsDataStreamController.stream.listen(_handleSettingsData);
  }

  void dispose() {
    _batteryInstantSettingsStreamController.close();
    _batterySettingsCommandStreamController.close();
    _batterySettingsDataStreamController.close();
  }

  void _handleSettingsData(Parameter batteryParameter) {
    print(batteryParameter.name + " = " + batteryParameter.value);
    switch (batteryParameter.name) {
      case "fullVoltage":
        _batterySettings.fullVoltage = int.parse(batteryParameter.value);
        break;
      case "lowVoltage":
        _batterySettings.lowVoltage = int.parse(batteryParameter.value);
        break;
      case "maxPower":
        _batterySettings.maxPower = int.parse(batteryParameter.value);
        break;
      case "driveCurrent":
        _batterySettings.driveCurrent = int.parse(batteryParameter.value);
        break;
      case "regenCurrent":
        _batterySettings.regenCurrent = int.parse(batteryParameter.value);
        break;
      case "powerReductionVoltage":
        _batterySettings.powerReductionVoltage = int.parse(batteryParameter.value);
        break;
    }
  }

  void _handleCommand(BatterySettingsCommand event) {
    switch (event) {
      case BatterySettingsCommand.READ:
        _batterySettingsRead();
        break;
      case BatterySettingsCommand.WRITE:
        _batterySettingsWrite();
        break;
      case BatterySettingsCommand.SAVE:
        _batterySettingsSave();
        break;
      case BatterySettingsCommand.REFRESH:
        _batterySettingsRefresh();
        break;
    }
  }

  void _packetHandler(Packet packet) {
    print(packet.toBytes);
    _batterySettings = Mapper.packetToBatterySettings(packet);
    _batteryInstantSettingsStreamController.sink.add(_batterySettings);
  }

  void _batterySettingsRead() {
    print("_batterySettingsRead");
    _bluetoothInteractor.sendMessage(Packet(2, 0, Uint8List(28)));
    _bluetoothInteractor.startListenSerial(_packetHandler);
  }

  void _batterySettingsWrite() {
    print("_batterySettingsWrite");
    Packet packet = Mapper.batterySettingsToPacket(_batterySettings);
    print("packet = ${packet.dataBuffer}");
    _bluetoothInteractor.sendMessage(packet);
  }

  void _batterySettingsSave() {
    print("_batterySettingsSave");
    print("_batterySettings = ${_batterySettings.toJson()}");
  }

  void _batterySettingsRefresh() {
    print("_batterySettingsRefresh");
    _batterySettings = BatterySettings.random(72);
  }
}
