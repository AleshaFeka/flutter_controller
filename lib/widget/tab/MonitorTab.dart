import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_controller/screen/TabsPage.dart';
import 'package:flutter_controller/core/LiveData.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:google_fonts/google_fonts.dart';

class MonitorTab extends StatefulWidget {
  final AppSettings settings;
  const MonitorTab([this.settings]);

  @override
  _MonitorTab createState() => new _MonitorTab();
}

class _MonitorTab extends State<MonitorTab> {
  static final rawBytes = <int>[
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
  LiveData liveData = LiveData.fromBytes(Uint8List.fromList(rawBytes));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final large = GoogleFonts.oswald(textStyle: TextStyle(fontSize: 80));
    final small = GoogleFonts.oswald(textStyle: TextStyle(fontSize: 28));

    final param1 = this.liveData.getParameter(Settings.getValue<int>('setting-monitor-param1', 1));
    final param2 = this.liveData.getParameter(Settings.getValue<int>('setting-monitor-param2', 2));
    final param3 = this.liveData.getParameter(Settings.getValue<int>('setting-monitor-param3', 3));
    final param4 = this.liveData.getParameter(Settings.getValue<int>('setting-monitor-param4', 4));
    final param5 = this.liveData.getParameter(Settings.getValue<int>('setting-monitor-param5', 5));

    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
//          Row(
//            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//            children: <Widget>[
              Text(param1, textAlign: TextAlign.center, style: large),
//        ],
//          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
            Expanded(
                child: Column(children: <Widget>[
              Text(param2, style: small),
              Divider(),
              Text(param3, style: small),
            ])),
            Expanded(
                child: Column(children: <Widget>[
              Container(padding: EdgeInsets.all(4), color: Colors.green, child: Text('Ошибка', style: small)),
              Container(padding: EdgeInsets.all(4), color: Colors.green, child: Text('Работа', style: small)),
              Container(padding: EdgeInsets.all(4), color: Colors.green, child: Text('Режим', style: small)),
            ])),
            Expanded(
                child: Column(children: <Widget>[
              Text(param4, textAlign: TextAlign.center, style: small),
              Divider(),
              Text(param5, style: small),
            ])),
          ]),
        ],
      ),
    );
  }
}
