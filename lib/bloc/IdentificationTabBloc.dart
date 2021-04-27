
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_controller/core/Packet.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/Parameter.dart';
import 'package:flutter_controller/model/SystemSettings.dart';
import 'package:flutter_controller/util/Mapper.dart';
import 'package:flutter_controller/util/kotlin_style_extensions.dart';

enum IdentificationCommand { DISABLE, MEASURE_RS, MEASURE_LS, MEASURE_HALLS, MEASURE_HALLS_WITH_ROTATION,  MEASURE_FLUX, WRITE_HALLS_TABLE, READ}

class IdentificationTabBloc {
  static const SCREEN_NUMBER = 3;

  BluetoothInteractor _bluetoothInteractor;
  SystemSettings _settings = SystemSettings.zero();

  StreamController<IdentificationCommand> _commandController;
  StreamSink<IdentificationCommand> get commandSink => _commandController.sink;

  StreamController<Parameter> _dataController;
  StreamSink<Parameter> get dataSink => _dataController.sink;

  StreamController<SystemSettings> _viewModelController;
  Stream<SystemSettings> get viewModelStream => _viewModelController.stream;


  StreamController<int> _controllerStateStreamController ;
  StreamSubscription _controllerStateSubscription;

  IdentificationTabBloc(this._bluetoothInteractor) {
/*
    _commandController.stream.listen(_handleCommand);
    _dataController.stream.listen(_handleDataChanged);
*/

/*
    _controllerStateStreamController = StreamController<int>.broadcast(
      onListen: _startMonitoringControllerState,
      onCancel: _stopMonitoringControllerState
    );
*/
  }

  void init() {

    _commandController = StreamController.broadcast();
    _dataController = StreamController.broadcast();
    _viewModelController = StreamController.broadcast();
    _controllerStateStreamController = StreamController<int>.broadcast(
      onListen: _startMonitoringControllerState,
      onCancel: _stopMonitoringControllerState
    );

    _commandController.stream.listen(_handleCommand);
    _dataController.stream.listen(_handleDataChanged);

  }

  void _startMonitoringControllerState() {
    _controllerStateSubscription = Stream.periodic(Duration(milliseconds: 500), sendControllerSettingsRequest).listen((_) { });
  }

  void _stopMonitoringControllerState() {
    _bluetoothInteractor.stopListenSerial();
    _controllerStateSubscription?.cancel();
  }

  void sendControllerSettingsRequest (count) {
    _bluetoothInteractor.sendMessage(Packet(SCREEN_NUMBER, 0, Uint8List(28)));
    _bluetoothInteractor.startListenSerial(_controllerSettingsPacketHandler);
  }

  void _controllerSettingsPacketHandler(Packet packet) {
    if (packet.screenNum == SCREEN_NUMBER) {
      final settings = Mapper.packetToSystemSettings(packet);
      _viewModelController.sink.add(settings);
      if (settings.identificationMode == 0) {
        _stopMonitoringControllerState();
      }
    }
  }

  void _handleDataChanged(Parameter parameter) {
    switch (parameter.name) {
      case "identificationCurrent" :
        final current = int.tryParse(parameter.value);
        current?.let((amps) {
          _settings.identificationCurrent = amps;
        });
        break;
      case "hall1" :
        final value = int.tryParse(parameter.value);
        _settings.hall1 = value;
        break;
      case "hall2" :
        final value = int.tryParse(parameter.value);
        _settings.hall2 = value;
        break;
      case "hall3" :
        final value = int.tryParse(parameter.value);
        _settings.hall3 = value;
        break;
      case "hall4" :
        final value = int.tryParse(parameter.value);
        _settings.hall4 = value;
        break;
      case "hall5" :
        final value = int.tryParse(parameter.value);
        _settings.hall5 = value;
        break;
      case "hall6" :
        final value = int.tryParse(parameter.value);
        _settings.hall6 = value;
        break;
    }
  }

  void _handleCommand(IdentificationCommand command) {
    switch (command) {
      case IdentificationCommand.READ :
        _readSettings();
        _refreshSettings();
        break;
      case IdentificationCommand.DISABLE:
        // Ignore
        break;
      case IdentificationCommand.MEASURE_RS:
        _measureRs();
        break;
      case IdentificationCommand.MEASURE_LS:
        _measureLs();
        break;
      case IdentificationCommand.MEASURE_HALLS:
        _startIdentification();
        break;
      case IdentificationCommand.MEASURE_HALLS_WITH_ROTATION:
        // Ignore
        break;
      case IdentificationCommand.MEASURE_FLUX:
        _measureFlux();
        break;
      case IdentificationCommand.WRITE_HALLS_TABLE:
        _writeHallTable();
        break;
    }
  }

  void _refreshSettings() {
    _viewModelController.sink.add(_settings);
  }

  void _readSettings() {
    _settings = SystemSettings.zero();
  }

  void _startMeasureMotorParameter(IdentificationCommand mode) {
    _settings.identificationMode = IdentificationCommand.values.indexOf(mode);
    final packet = Mapper.systemSettingsToPacket(_settings);
    _bluetoothInteractor.sendMessage(packet);
    _startMonitoringControllerState();
  }

  void _measureRs() {
    _startMeasureMotorParameter(IdentificationCommand.MEASURE_RS);
  }

  void _measureLs() {
    _startMeasureMotorParameter(IdentificationCommand.MEASURE_LS);
  }

  void _measureFlux() {
    _startMeasureMotorParameter(IdentificationCommand.MEASURE_FLUX);
  }

  void _startIdentification() {
    _startMeasureMotorParameter(IdentificationCommand.MEASURE_HALLS);
  }

  void _writeHallTable() {
    _startMeasureMotorParameter(IdentificationCommand.WRITE_HALLS_TABLE);
  }

  void dispose() {
    _controllerStateStreamController.close();
    _commandController.close();
    _dataController.close();
    _viewModelController.close();
  }
}
