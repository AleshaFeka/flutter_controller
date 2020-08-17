import 'dart:async';

import 'package:flutter_controller/interactor/BluetoothInteractor.dart';

class TabsPageBloc {
  BluetoothInteractor _interactor;
  StreamController<int> _tabsStreamController = StreamController<int>.broadcast();

  Stream<int> get monitorSettingsStream => _tabsStreamController.stream;

  StreamController<int> _tabsCommandStreamController = StreamController<int>.broadcast();

  StreamSink<int> get tabsCommandStream => _tabsCommandStreamController.sink;

  StreamController<int> _btConnectionStreamController = StreamController<int>.broadcast();

  Stream<int> get btConnectionStream => _btConnectionStreamController.stream;

  TabsPageBloc(this._interactor) {
    _tabsCommandStreamController.stream.listen(_handleCommand);
    _interactor.fromBtConnectionStream.listen((event) { /* do nothing */ })
      ..onDone(() {
        _tabsStreamController.sink.addError(Exception("Connection closed."));
      })
      ..onError((error) {
        _tabsStreamController.sink.addError(error);
      });
  }

  void _handleCommand(int tabIndex) {
    _tabsStreamController.sink.add(tabIndex);
  }

  void dispose() {
    _tabsStreamController.close();
    _tabsCommandStreamController.close();
  }
}
