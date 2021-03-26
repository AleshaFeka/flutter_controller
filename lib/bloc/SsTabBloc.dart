
import 'dart:async';

import 'package:flutter_controller/model/Parameter.dart';
import 'package:flutter_controller/model/SystemSettings.dart';
import 'package:flutter_controller/util/kotlin_style_extensions.dart';

enum SsCommand { DISABLE, MEASURE_RS, MEASURE_LS, MEASURE_HALLS, MEASURE_HALLS_WITH_ROTATION,  MEASURE_FLUX, WRITE_HALLS_TABLE, READ}

class SsTabBloc {
  StreamController<SsCommand> _commandController = StreamController.broadcast();
  StreamSink<SsCommand> get commandSink => _commandController.sink;

  StreamController<Parameter> _dataController = StreamController.broadcast();
  StreamSink<Parameter> get dataSink => _dataController.sink;

  StreamController<SystemSettings> _viewModelController = StreamController.broadcast();
  Stream<SystemSettings> get viewModelStream => _viewModelController.stream;

  SystemSettings _settings = SystemSettings.zero();

  SsTabBloc() {
    _commandController.stream.listen(_handleCommand);
    _dataController.stream.listen(_handleDataChanged);
  }

  void _handleDataChanged(Parameter parameter) {
    print("_handleDataChanged: ${parameter.name} = ${parameter.value}");
    switch (parameter.name) {
      case "identificationCurrent" :
        final current = int.tryParse(parameter.value);
        current?.let((amps) {
          print("amps = $amps");
        });
    }
  }

  void _handleCommand(SsCommand command) {
    switch (command) {
      case SsCommand.READ : 
        _readSettings();
        _refreshSettings();
        break;      
      case SsCommand.DISABLE:
        // Ignore
        break;
      case SsCommand.MEASURE_RS:
        _measureRs();
        break;
      case SsCommand.MEASURE_LS:
        _measureLs();
        break;
      case SsCommand.MEASURE_HALLS:
        _startIdentification();
        break;
      case SsCommand.MEASURE_HALLS_WITH_ROTATION:
        // Ignore
        break;
      case SsCommand.MEASURE_FLUX:
        _measureFlux();
        break;
      case SsCommand.WRITE_HALLS_TABLE:
        _writeHallTable();
        break;
    }
  }

  void _readSettings() {
    _settings = SystemSettings.zero();
  }

  void _refreshSettings() {
    _viewModelController.sink.add(_settings);
  }

  void dispose() {
    _commandController.close();
    _dataController.close();
    _viewModelController.close();
  }

  void _measureRs() {
    print("_measureRs");
  }

  void _measureLs() {
    print("_measureLs");
  }

  void _measureFlux() {
    print("_measureFlux");
  }
  
  void _startIdentification() {
    print("_startIdentification");
  }

  void _writeHallTable() {
    print("_writeHallTable");
/*
    _settings = SystemSettings.random();
    _refreshSettings();
*/
  }
}