import 'package:flutter/material.dart';
import 'package:flutter_controller/TabsPage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    return TabsPage();
//    return ConnectPage(checkAvailability: false,);
  }
}
