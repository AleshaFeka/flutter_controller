import 'dart:async';

import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/MotorSettings.dart';
import 'package:rxdart/rxdart.dart';

enum MotorSettingsCommand { READ, WRITE, SAVE }

class MotorTabBloc {
  var motorSettingsInitial = MotorSettings.zero();
  BluetoothInteractor _bluetoothInteractor;

  var _motorInstantSettingsStreamController = StreamController<MotorSettings>();
  get motorInstantSettingsStream => _motorInstantSettingsStreamController.stream;

  var _motorSettingsCommandStreamController = StreamController<MotorSettingsCommand>();
  StreamSink<MotorSettingsCommand> get motorSettingsCommandStream => _motorSettingsCommandStreamController.sink;
  
  MotorTabBloc(this._bluetoothInteractor) {
    _motorSettingsCommandStreamController.stream.listen(_handleCommand);
  }

  void _handleCommand(MotorSettingsCommand event) {
    switch (event) {
      case MotorSettingsCommand.READ:
        _motorSettingsRead();
        break;
      case MotorSettingsCommand.WRITE:
        _motorSettingsWrite();
        break;
      case MotorSettingsCommand.SAVE:
        _motorSettingsSave();
        break;
    }
  }

  void _motorSettingsRead() {
    MotorSettings data = _bluetoothInteractor.read();
    print("Readed from bluetooht - $data");
    _motorInstantSettingsStreamController.sink.add(data);
  }

  void _motorSettingsWrite() {
    _bluetoothInteractor.write();
  }

  void _motorSettingsSave() {
    _bluetoothInteractor.save();
  }

  void dispose() {
    _motorInstantSettingsStreamController.close();
    _motorSettingsCommandStreamController.close();
  }
}

class CounterBloc {
  int _counter;

  CounterBloc() {
    _counter = 1;
    _actionController.stream.listen(_increaseStream);
  }

  final _counterStream = BehaviorSubject<int>.seeded(1);

  Stream get pressedCount => _counterStream.stream;

  Sink get _addValue => _counterStream.sink;

  StreamController _actionController = StreamController();

  StreamSink get incrementCounter => _actionController.sink;

  void _increaseStream(data) {
    _counter += 1;
    _addValue.add(_counter);
  }

  void dispose() {
    _counterStream.close();
    _actionController.close();
  }
}
