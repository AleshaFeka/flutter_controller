import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_controller/bloc/TabsPageBloc.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_controller/util/Util.dart';
import 'package:flutter_controller/widget/tab/MonitorTab.dart';
import 'package:flutter_controller/widget/tab/MotorTab.dart';

import 'SettingsPage.dart';

class TabsPage extends StatefulWidget {
  final BluetoothDevice server;

  const TabsPage({this.server});

  @override
  _TabsPage createState() => new _TabsPage();
}

class _TabsPage extends State<TabsPage> {
  static const _firstTab = 0;
  static const _tabNames = "tabNames";
  static const tabIcons = <int, IconData>{
    0: Icons.computer,
    1: Icons.adjust,
    2: Icons.motorcycle,
    3: Icons.surround_sound,
    4: Icons.build,
    5: Icons.leak_remove,
    6: Icons.leak_add,
    7: Icons.short_text,
  };

//  List<Widget> _tabs = [ MonitorTab(), MotorTab()/*, DriveTab(), AnalogTab(), RegsTab(), SensorLessTab(), IdentTab(), LogsTab()*/ ];

  TabsPageBloc _tabsPageBloc;
  Map<int, String> tabNames;
  Map<String, dynamic> _localizedStrings;

  int _selectedChoice = 1; // Selected tab

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tabsPageBloc = Provider.of(context).tabsPageBloc;
    _localizedStrings = Provider.of(context).localizedStrings;
    tabNames = (_localizedStrings[_tabNames] as Map)
        .map((key, value) => MapEntry(int.parse(key), value.toString()));
  }

  @override
  Widget build(BuildContext context) {
    _tabsPageBloc.tabsCommandStream.add(_firstTab);

    return StreamBuilder<int>(
        stream: _tabsPageBloc.monitorSettingsStream,
        builder: (context, snapshot) {
          Widget child;
          if (snapshot.hasError) {
            _buildError(snapshot.error.toString());
          } else if (!snapshot.hasData) {
            child = Center(child: CircularProgressIndicator());
          } else {
            child = _buildTab(snapshot.data);
          }

          return Scaffold(
            appBar: AppBar(
              leading: PopupMenuButton<int>(
                onSelected: _handleTabSelectClick,
                itemBuilder: (BuildContext context) {
                  return _buildMenuItems();
                },
              ),
              title: Text(tabNames[_selectedChoice]),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: _handleAboutClick,
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: _handleSettingsClick,
                ),
              ],
            ),
            body: Container(child: child),
          );
        });
  }

  Widget _buildError(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Icon(
            Icons.error,
            size: 64,
            color: Colors.red,
          ),
        ),
        Container(
          height: 16,
        ),
        Text(message)
      ],
    );
  }

  Widget _buildTab(int tabIndex) {
    //todo replace later...
    List<Widget> _tabs = [ MonitorTab(), MotorTab()/*, DriveTab(), AnalogTab(), RegsTab(), SensorLessTab(), IdentTab(), LogsTab()*/ ];

    if (tabIndex > 1) return _tabs[0];//todo change when new tabs will added, remove at the end))
    return _tabs[tabIndex];
  }

  List<PopupMenuItem<int>> _buildMenuItems() {
    return tabNames.keys.map((int num) {
      return PopupMenuItem<int>(
        value: num,
        child: Row(
          children: <Widget>[
            Container(
              margin: new EdgeInsets.only(right: 10),
              child: Icon(tabIcons[num], size: 24, color: Colors.grey),
            ),
            Text(tabNames[num]),
          ],
        ),
      );
    }).toList();
  }

  void _handleSettingsClick() async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) => SettingsPage()));
    setState(() {
      print("setState");
    }); // Applying new settings
  }

  void _handleTabSelectClick(int choice) {
    _tabsPageBloc.tabsCommandStream.add(choice);
    // Causes the app to rebuild with the new _selectedChoice.
/*
    setState(() {
      _selectedChoice = choice;
    });
*/
  }

  void _handleAboutClick() {
    showAbout(context);
  }
}
