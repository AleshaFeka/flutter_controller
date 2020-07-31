import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_controller/core/LiveData.dart';
import 'package:flutter_controller/model/MonitorSettings.dart';

enum MonitorTabCommand { READ }

class MonitorTabBloc {
  static final rawBytesStub = <int>[
//      0, 0, //screenNum, cmd
    113, 29, // [0] udc 0x1D71 Little-endian = 75,37
    8, 0, // [1] Uz 0x0008 Little-endian = 8.00
    0, 0, // [2] Iamp 0x0000 Little-endian = 0
    10, 0, // [3] Speed 0x0000 Little-endian = 0
    0, 0, // [4] Pel 0x0000 Little-endian = 0
    7, 0, // [5] Tfet 0x0007 Little-endian = 7
    167, 2, // [6] Active_Flux 0x02A7 Little-endian = 0,0679
    143, 10, // [7] Brake 0x0A8F Little-endian = 2,703
    254, 201, // [8] Teta_shift 0x0000 Little-endian = 0
    0, 0, // [9] Tmot 0x0000 Little-endian = 0
    7, 0, // [10] Hall_cnt 0x0007 Little-endian = 7
    6, 3, // [11] Trottle_Act 0x0306 Little-endian = 0,774
    3, 128, // [12] statuc_word 0x8003 Little-endian
    0, 0, // [13] alg_mode 0x0000
//      114, 2 // crc
  ];
  LiveData liveDataStub = LiveData.fromBytes(Uint8List.fromList(rawBytesStub));

  MonitorTabSettingsData _settings;

  StreamController<MonitorTabSettingsData> _monitorSettingsStreamController = StreamController<MonitorTabSettingsData>.broadcast();
  Stream<MonitorTabSettingsData> get monitorSettingsStream => _monitorSettingsStreamController.stream;

  StreamController<MonitorTabCommand> _monitorSettingsCommandStreamController = StreamController<MonitorTabCommand>.broadcast();
  StreamSink<MonitorTabCommand> get monitorSettingsCommandStream => _monitorSettingsCommandStreamController.sink;

  MonitorTabBloc() {
    _monitorSettingsCommandStreamController.stream.listen(_handleCommand);
  }

  void _handleCommand(MonitorTabCommand command) {
    switch (command) {
      case MonitorTabCommand.READ :
      _settings = MonitorTabSettingsData.build(liveDataStub, MonitorTabSettings.load());
      _monitorSettingsStreamController.sink.add(_settings);
      break;
    }
  }

  void dispose() {
    _monitorSettingsStreamController.close();
    _monitorSettingsCommandStreamController.close();
  }
}