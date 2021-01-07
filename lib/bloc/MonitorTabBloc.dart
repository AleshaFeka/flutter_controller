import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_controller/core/LiveData.dart';
import 'package:flutter_controller/core/Packet.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/MonitorSettings.dart';

enum MonitorTabCommand { READ, START_MONITORING, STOP_MONITORING }

class MonitorTabBloc {
  static const _SCREEN_NUMBER = 0;
  static const _MONITORING_INTERVAL = 500;

  LiveData liveDataStub = LiveData.fromBytes(Uint8List(28));
  StreamSubscription _monitoringSubscription;

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
    print('MonitorTabBloc   _packetHandler');
    if (packet.screenNum == 0) {
      _settings = MonitorTabSettingsData.build(LiveData.fromBytes(packet.toBytes), MonitorTabSettings.load());
      _monitorSettingsStreamController.sink.add(_settings);
    }
  }

  void _stopMonitoring() {
    _interactor.stopListenSerial();
    _monitoringSubscription.cancel();
  }

  void _startMonitoring() async {
    _interactor.startListenSerial(_packetHandler);

    dynamic Function(int) computation = (count) {
      _interactor.sendMessage(Packet(_SCREEN_NUMBER, 0, Uint8List(28)));
    };

    _monitoringSubscription = Stream.periodic(Duration(milliseconds: _MONITORING_INTERVAL), computation).listen((_) {});

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
      case MonitorTabCommand.STOP_MONITORING:
        _stopMonitoring();
        break;
    }
  }

  void dispose() {
    _monitorSettingsStreamController.close();
    _monitorSettingsCommandStreamController.close();
  }
}
