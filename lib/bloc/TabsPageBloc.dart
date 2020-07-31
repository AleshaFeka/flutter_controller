import 'dart:async';

class TabsPageBloc {
  StreamController<int> _tabsStreamController = StreamController<int>.broadcast();
  Stream<int> get monitorSettingsStream => _tabsStreamController.stream;

  StreamController<int> _tabsCommandStreamController = StreamController<int>.broadcast();
  StreamSink<int> get tabsCommandStream => _tabsCommandStreamController.sink;

  TabsPageBloc() {
    _tabsCommandStreamController.stream.listen(_handleCommand);
  }

  void _handleCommand(int choise) {
    _tabsStreamController.sink.add(choise);
  }

  void dispose() {
    _tabsStreamController.close();
    _tabsCommandStreamController.close();
  }
}