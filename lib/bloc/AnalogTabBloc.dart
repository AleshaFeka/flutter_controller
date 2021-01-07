import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_controller/core/Packet.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/AnalogSettings.dart';
import 'package:flutter_controller/util/Mapper.dart';

enum AnalogSettingsCommand { READ, WRITE, SAVE, REFRESH }

class AnalogTabBloc {
  static const SCREEN_NUMBER = 6;

  StreamController _analogViewModelStreamController = StreamController<AnalogSettings>.broadcast();
  Stream get analogViewModelStream => _analogViewModelStreamController.stream;

  StreamController<AnalogSettingsCommand> _analogSettingsCommandStreamController =  StreamController<AnalogSettingsCommand>.broadcast();
  StreamSink<AnalogSettingsCommand> get batterySettingsCommandStream => _analogSettingsCommandStreamController.sink;

  BluetoothInteractor _bluetoothInteractor;
  AnalogSettings _analogSettings;

  AnalogTabBloc(this._bluetoothInteractor){
    _analogSettingsCommandStreamController.stream.listen(_handleCommand);
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

  void _analogSettingsRead() {
    print("_analogSettingsRead");
    _bluetoothInteractor.sendMessage(Packet(SCREEN_NUMBER, 0, Uint8List(28)));
    _bluetoothInteractor.startListenSerial(_packetHandler);
  }

  void _packetHandler(Packet packet) {
    print('AnalogTabBloc   _packetHandler');
    print(packet.toBytes);
    if (packet.screenNum == SCREEN_NUMBER) {
      _analogSettings = Mapper.packetToAnalogSettings(packet);
      _analogSettingsRefresh();
    }
  }

  void _analogSettingsWrite() {
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
    _analogViewModelStreamController.close();
    _analogSettingsCommandStreamController.close();
  }
}