import 'dart:async';
import 'dart:io';

import 'package:flutter_controller/model/MotorSettings.dart';
import 'package:flutter_controller/screen/MainPage.dart';
import 'package:rxdart/rxdart.dart';

enum MotorSettingsCommand { READ, WRITE }

class MotorTabBloc {
  var motorSettingsInitial = MotorSettings();

  var _motorInstantSettingsStreamController = StreamController<MotorSettings>();
  get motorInstantSettingsStream => _motorInstantSettingsStreamController.stream;

  var _motorSettingsCommandStreamController = StreamController<MotorSettingsCommand>();
  StreamSink<MotorSettingsCommand> get motorSettingsCommandStream => _motorSettingsCommandStreamController.sink;
  
  MotorTabBloc() {
    _motorSettingsCommandStreamController.stream.listen(_commandListener);
  }

  void _commandListener(MotorSettingsCommand event) {
    switch (event) {
      case MotorSettingsCommand.READ:
        _motorSettingsRead();
        break;
      case MotorSettingsCommand.WRITE:
        _motorSettingsWrite();
        break;
    }
  }

  void _motorSettingsRead() {
    print("motorSettingsRead");
    sleep(Duration(seconds: 2));
    _motorInstantSettingsStreamController.sink.add(motorSettingsInitial);
  }
  
  void _motorSettingsWrite() {
    print("motorSettingsWrite");
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
