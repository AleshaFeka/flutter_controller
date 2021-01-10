import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_controller/core/Packet.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/AnalogSettings.dart';
import 'package:flutter_controller/model/Parameter.dart';
import 'package:flutter_controller/util/Mapper.dart';

enum AnalogSettingsCommand { READ, WRITE, SAVE, REFRESH }

class AnalogTabBloc {
  static const SCREEN_NUMBER = 9;

  StreamController _analogViewModelStreamController = StreamController<AnalogSettings>.broadcast();
  Stream get analogViewModelStream => _analogViewModelStreamController.stream;

  StreamController<AnalogSettingsCommand> _analogSettingsCommandStreamController =  StreamController<AnalogSettingsCommand>.broadcast();
  StreamSink<AnalogSettingsCommand> get batterySettingsCommandStream => _analogSettingsCommandStreamController.sink;


  StreamController<Parameter> _analogSettingsDataStreamController = StreamController<Parameter>.broadcast(sync: true);
  StreamSink<Parameter> get analogSettingsDataStream => _analogSettingsDataStreamController.sink;

  BluetoothInteractor _bluetoothInteractor;
  AnalogSettings _analogSettings;

  AnalogTabBloc(this._bluetoothInteractor){
    _analogSettingsCommandStreamController.stream.listen(_handleCommand);
    _analogSettingsDataStreamController.stream.listen(_handleSettingsData);
  }

  void _handleCommand(AnalogSettingsCommand event) {
    switch (event) {
      case AnalogSettingsCommand.READ:
        _analogSettingsRead();
        break;
      case AnalogSettingsCommand.WRITE:
        _analogSettingsWrite();
        break;
      case AnalogSettingsCommand.SAVE:
        _analogSettingsSave();
        break;
      case AnalogSettingsCommand.REFRESH:
        _analogSettingsRefresh();
        break;
    }
  }

  void _handleSettingsData(Parameter analogParameter) {
    print(analogParameter.name + " = " + analogParameter.value);
    switch (analogParameter.name) {
      case "throttleMin":
        _analogSettings.throttleMin = double.parse(analogParameter.value);
        break;
      case "throttleMax":
        _analogSettings.throttleMax = double.parse(analogParameter.value);
        break;
      case "throttleCurveCoefficient1":
        _analogSettings.throttleCurveCoefficient1 = int.parse(analogParameter.value);
        break;
      case "throttleCurveCoefficient2":
        _analogSettings.throttleCurveCoefficient2 = int.parse(analogParameter.value);
        break;
      case "throttleCurveCoefficient3":
        _analogSettings.throttleCurveCoefficient3 = int.parse(analogParameter.value);
        break;
      case "brakeMin":
        _analogSettings.brakeMin = double.parse(analogParameter.value);
        break;
      case "brakeMax":
        _analogSettings.brakeMax = double.parse(analogParameter.value);
        break;
      case "brakeCurveCoefficient1":
        _analogSettings.brakeCurveCoefficient1 = int.parse(analogParameter.value);
        break;
      case "brakeCurveCoefficient2":
        _analogSettings.brakeCurveCoefficient2 = int.parse(analogParameter.value);
        break;
      case "brakeCurveCoefficient3":
        _analogSettings.brakeCurveCoefficient3 = int.parse(analogParameter.value);
        break;
    }
  }

  void _analogSettingsRead() {
    _bluetoothInteractor.sendMessage(Packet(SCREEN_NUMBER, 0, Uint8List(28)));
    _bluetoothInteractor.startListenSerial(_packetHandler);
  }

  void _packetHandler(Packet packet) {
    print('AnalogTabBloc   _packetHandler');
    print(packet.toBytes);
    if (packet.screenNum == SCREEN_NUMBER) {
    }
      _analogSettings = Mapper.packetToAnalogSettings(packet);
      _analogSettingsRefresh();
  }

  void _analogSettingsWrite() {
    print("_analogSettings - ${_analogSettings.toJson()}");
    Packet packet = Mapper.analogSettingsToPacket(_analogSettings);
    _bluetoothInteractor.sendMessage(packet);
  }

  void _analogSettingsSave() {
    _bluetoothInteractor.save();
  }

  void _analogSettingsRefresh() {
    print("_analogSettingsRefresh");
    _analogViewModelStreamController.sink.add(_analogSettings);
  }

  void dispose() {
    _analogSettingsDataStreamController.close();
    _analogViewModelStreamController.close();
    _analogSettingsCommandStreamController.close();
  }
}