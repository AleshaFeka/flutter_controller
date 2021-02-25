import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_controller/core/Packet.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/FuncSettings.dart';
import 'package:flutter_controller/model/Parameter.dart';
import 'package:flutter_controller/util/Mapper.dart';

enum FuncSettingsCommand { READ, WRITE, SAVE, REFRESH }
enum InputFunctions { NO_FUNC, TRQ_SPD, REV_FWD, CRUIZE, S1, S2, FALL, STOP }

class FuncTabBloc {
  static const SCREEN_NUMBER = 10;

  final BluetoothInteractor _bluetoothInteractor;
  FuncSettings _settings;

  StreamController<FuncSettings> _funcViewModelStreamController = StreamController<FuncSettings>.broadcast();

  Stream<FuncSettings> get funcViewModelStream => _funcViewModelStreamController.stream;

  StreamController<FuncSettingsCommand> _funcSettingsCommandStreamController =
      StreamController<FuncSettingsCommand>.broadcast();

  StreamSink<FuncSettingsCommand> get funcSettingsCommandStream => _funcSettingsCommandStreamController.sink;

  StreamController<Parameter> _funcSettingsDataStreamController = StreamController<Parameter>.broadcast(
      sync: true); //Sync to avoid async between changing parameters and writing to controller
  StreamSink<Parameter> get funcSettingsDataStream => _funcSettingsDataStreamController.sink;

  FuncTabBloc(this._bluetoothInteractor) {
    _settings = FuncSettings.zero();

    _funcSettingsCommandStreamController.stream.listen(_handleCommand);
    _funcSettingsDataStreamController.stream.listen(_handleSettingsData);
  }

  void _handleCommand(FuncSettingsCommand event) {
    switch (event) {
      case FuncSettingsCommand.READ:
        _funcSettingsRead();
        break;
      case FuncSettingsCommand.WRITE:
        _funcSettingsWrite();
        break;
      case FuncSettingsCommand.SAVE:
        _funcSettingsSave();
        break;
      case FuncSettingsCommand.REFRESH:
        _funcSettingsRefresh();
        break;
    }
  }

  void _packetHandler(Packet packet) {
    print('FuncTabBloc   _packetHandler');
    _settings = Mapper.packetToFuncSettings(packet) ?? _settings;
    _funcSettingsRefresh();
  }

  void _funcSettingsRead() {
    _bluetoothInteractor.sendMessage(Packet(SCREEN_NUMBER, 0, Uint8List(28)));
    _bluetoothInteractor.startListenSerial(_packetHandler);
  }

  void _funcSettingsWrite() {
    Packet packet = Mapper.funcSettingsToPacket(_settings);
    _bluetoothInteractor.sendMessage(packet);
  }

  void _funcSettingsSave() {
    _bluetoothInteractor.save();
  }

  void _funcSettingsRefresh() {
    _funcViewModelStreamController.sink.add(_settings);
  }

  void _handleSettingsData(Parameter motorParameter) {
//    print("motorParameter.name = ${motorParameter.name}  | motorParameter.value = ${motorParameter.value}");
    switch (motorParameter.name) {
      case "invertIn1":
        _settings.invertIn1 = motorParameter.value == "true";
        break;
      case "invertIn2":
        _settings.invertIn2 = motorParameter.value == "true";
        break;
      case "invertIn3":
        _settings.invertIn3 = motorParameter.value == "true";
        break;
      case "invertIn4":
        _settings.invertIn4 = motorParameter.value == "true";
        break;
      case "in1":
        _settings.in1 = _getFunctionIndex(motorParameter.value);
        break;
      case "in2":
        _settings.in2 = _getFunctionIndex(motorParameter.value);
        break;
      case "in3":
        _settings.in3 = _getFunctionIndex(motorParameter.value);
        break;
      case "in4":
        _settings.in4 = _getFunctionIndex(motorParameter.value);
        break;

      case "useCan":
        _settings.useCan = motorParameter.value == "true";
        break;

      case "s1MaxTorqueCurrent":
        _settings.s1MaxTorqueCurrent = int.parse(motorParameter.value);
        break;
      case "s1MaxBrakeCurrent":
        _settings.s1MaxBrakeCurrent = int.parse(motorParameter.value);
        break;
      case "s1MaxSpeed":
        _settings.s1MaxSpeed = int.parse(motorParameter.value);
        break;
      case "s1MaxBatteryCurrent":
        _settings.s1MaxBatteryCurrent = int.parse(motorParameter.value);
        break;
      case "s1MaxBatteryCurrent":
        _settings.s1MaxBatteryCurrent = int.parse(motorParameter.value);
        break;

      case "s2MaxTorqueCurrent":
        _settings.s2MaxTorqueCurrent = int.parse(motorParameter.value);
        break;
      case "s2MaxBrakeCurrent":
        _settings.s2MaxBrakeCurrent = int.parse(motorParameter.value);
        break;
      case "s2MaxSpeed":
        _settings.s2MaxSpeed = int.parse(motorParameter.value);
        break;
      case "s2MaxBatteryCurrent":
        _settings.s2MaxBatteryCurrent = int.parse(motorParameter.value);
        break;
      case "s2MaxBatteryCurrent":
        _settings.s2MaxBatteryCurrent = int.parse(motorParameter.value);
        break;
    }
  }

  int _getFunctionIndex(String functionName) => InputFunctions.values
    .map((e) => e.toString())
    .toList()
    .indexOf(functionName);

  void dispose() {
    _funcViewModelStreamController.close();
    _funcSettingsCommandStreamController.close();
    _funcSettingsDataStreamController.close();
  }
}
