import 'dart:async';

import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/FuncSettings.dart';
import 'package:flutter_controller/model/Parameter.dart';

enum FuncSettingsCommand { READ, WRITE, SAVE, REFRESH }
enum InputFunctions { NO_FUNC, TRQ_SPD, REV_FWD, CRUIZE, S1, S2, FALL, STOP }

class FuncTabBloc {
  final BluetoothInteractor _interactor;
  FuncSettings _settings;

  StreamController<FuncSettings> _funcViewModelStreamController = StreamController<FuncSettings>.broadcast();

  Stream<FuncSettings> get funcViewModelStream => _funcViewModelStreamController.stream;

  StreamController<FuncSettingsCommand> _funcSettingsCommandStreamController =
      StreamController<FuncSettingsCommand>.broadcast();

  StreamSink<FuncSettingsCommand> get funcSettingsCommandStream => _funcSettingsCommandStreamController.sink;

  StreamController<Parameter> _funcSettingsDataStreamController = StreamController<Parameter>.broadcast(
      sync: true); //Sync to avoid async between changing parameters and writing to controller
  StreamSink<Parameter> get funcSettingsDataStream => _funcSettingsDataStreamController.sink;

  FuncTabBloc(this._interactor) {
    _settings = FuncSettings.random(8);

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

  void _funcSettingsRead() {}

  void _funcSettingsWrite() {}

  void _funcSettingsSave() {}

  void _funcSettingsRefresh() {
    _funcViewModelStreamController.sink.add(_settings);
  }

  void _handleSettingsData(Parameter motorParameter) {
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
