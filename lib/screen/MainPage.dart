
import 'package:flutter/material.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_controller/screen/ConnectPage.dart';
import 'package:flutter_controller/screen/SettingsPage.dart';
import 'package:flutter_controller/screen/TabsPage.dart';
import 'package:flutter_controller/util/Util.dart';
import 'package:flutter_controller/widget/Voltmeter.dart';
import 'package:flutter_controller/widget/tab/AnalogTab.dart';
import 'package:flutter_controller/widget/tab/BatteryTab.dart';
import 'package:flutter_controller/widget/tab/DriveTab.dart';
import 'package:flutter_controller/widget/tab/FuncTab.dart';
import 'package:flutter_controller/widget/tab/MotorTab.dart';
import 'package:flutter_controller/widget/tab/IdentificationTab.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return ConnectPage();

//    return debugScreen(AnalogTab());
  }

  Widget debugScreen(Widget child) {
    return Scaffold(
      appBar: AppBar(
        title: Text("debug"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline),
          ),
          IconButton(
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Container(child: child),
    );
  }

  @override
  void dispose() {
    Provider.of(context).motorTabBloc.dispose();
    Provider.of(context).monitorTabBloc.dispose();
    Provider.of(context).connectPageBloc.dispose();
  }
}

