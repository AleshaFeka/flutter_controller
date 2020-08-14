import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_controller/core/LiveData.dart';
import 'package:flutter_controller/core/Packet.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/MonitorSettings.dart';

enum MonitorTabCommand { READ, START_MONITORING }

class MonitorTabBloc {

  LiveData liveDataStub = LiveData.fromBytes(Uint8List(28));

  MonitorTabSettingsData _settings;
  BluetoothInteractor _interactor;

  StreamController<MonitorTabSettingsData> _monitorSettingsStreamController =
      StreamController<MonitorTabSettingsData>.broadcast();

  Stream<MonitorTabSettingsData> get monitorSettingsStream => _monitorSettingsStreamController.stream;

  StreamController<MonitorTabCommand> _monitorSettingsCommandStreamController =
      StreamController<MonitorTabCommand>.broadcast();

  StreamSink<MonitorTabCommand> get monitorSettingsCommandStream => _monitorSettingsCommandStreamController.sink;

  MonitorTabBloc(this._interactor) {
    _monitorSettingsCommandStreamController.stream.listen(_handleCommand);
  }

  void _packetHandler(Packet packet) {
    print("Packet Handler. ");
    print(packet.toBytes);

    _settings = MonitorTabSettingsData.build(LiveData.fromBytes(packet.toBytes), MonitorTabSettings.load());
    _monitorSettingsStreamController.sink.add(_settings);

  }

  void _startMonitoring() {
    _interactor.sendMessage(Packet(0, 0, Uint8List(28)));
    _interactor.startMonitoring(_packetHandler);
  }

  void _handleCommand(MonitorTabCommand command) {
    switch (command) {
      case MonitorTabCommand.READ:
        _settings = MonitorTabSettingsData.build(liveDataStub, MonitorTabSettings.load());
        _monitorSettingsStreamController.sink.add(_settings);
        break;
      case MonitorTabCommand.START_MONITORING:
        _startMonitoring();
        break;

    }
  }

  void dispose() {
    _monitorSettingsStreamController.close();
    _monitorSettingsCommandStreamController.close();
  }
}
