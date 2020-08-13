
import 'package:flutter/material.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_controller/screen/ConnectPage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
//    return TabsPage();
    return ConnectPage();
  }

  @override
  void dispose() {
    Provider.of(context).motorTabBloc.dispose();
    Provider.of(context).monitorTabBloc.dispose();
    Provider.of(context).connectPageBloc.dispose();
  }
}

