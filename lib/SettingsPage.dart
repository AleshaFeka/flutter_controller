import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import 'core/LiveData.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage();

  @override
  _SettingsPage createState() => new _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {},
            ),
            // action button
          ],
        ),
        body: ListView(
          children: <Widget>[
            SettingsGroup(title: "Экран «Мониторинг»", children: <Widget>[
              DropDownSettingsTile<int>(
                title: 'Главный параметр',
                settingKey: 'setting-monitor-param1',
                values: ParamNames,
                selected: 2,
                onChange: (value) {
                  debugPrint('setting-monitor-param1: $value');
                },
              ),
              DropDownSettingsTile<int>(
                title: 'Параметр слева 1',
                settingKey: 'setting-monitor-param2',
                values: ParamNames,
                selected: 2,
                onChange: (value) {
                  debugPrint('setting-monitor-param2: $value');
                },
              ),
              DropDownSettingsTile<int>(
                title: 'Параметр слева 2',
                settingKey: 'setting-monitor-param3',
                values: ParamNames,
                selected: 2,
                onChange: (value) {
                  debugPrint('setting-monitor-param3: $value');
                },
                ),
              DropDownSettingsTile<int>(
                title: 'Параметр справа 1',
                settingKey: 'setting-monitor-param4',
                values: ParamNames,
                selected: 2,
                onChange: (value) {
                  debugPrint('setting-monitor-param4: $value');
                },
                ),
              DropDownSettingsTile<int>(
                title: 'Параметр справа 2',
                settingKey: 'setting-monitor-param5',
                values: ParamNames,
                selected: 2,
                onChange: (value) {
                  debugPrint('setting-monitor-param5: $value');
                },
                ),
            ]),
          ],
        ));
  }
}
