import 'dart:async';

import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/BatterySettings.dart';

class BatteryTabBloc {
  BluetoothInteractor _bluetoothInteractor;
  BatterySettings _settings;

  BatteryTabBloc(this._bluetoothInteractor);

  StreamController _batteryInstantSettingsStreamController = StreamController<BatterySettings>.broadcast();
  Stream get batteryInstantSettingsStream => _batteryInstantSettingsStreamController.stream;


  void dispose() {
    _batteryInstantSettingsStreamController.close();
  }
}