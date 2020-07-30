import 'package:flutter/material.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import '../core/LiveData.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage();

  @override
  _SettingsPage createState() => new _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  static const _settings = "settings";
  static const _centerParameter = "centerParameter";
  static const _leftTopParameter = "leftTopParameter";
  static const _leftBottomParameter = "leftBottomParameter";
  static const _rightTopParameter = "rightTopParameter";
  static const _rightBottomParameter = "rightBottomParameter";

  Map _localizedStrings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localizedStrings = Provider.of(context).localizedStrings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_localizedStrings[_settings]),
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
                title: _localizedStrings[_centerParameter],
                settingKey: 'setting-monitor-param1',
                values: ParamNames,
                selected: 4,
                onChange: (value) {
                  debugPrint('setting-monitor-param1: $value');
                },
              ),
              DropDownSettingsTile<int>(
                title: _localizedStrings[_leftTopParameter],
                settingKey: 'setting-monitor-param2',
                values: ParamNames,
                selected: 1,
                onChange: (value) {
                  debugPrint('setting-monitor-param2: $value');
                },
              ),
              DropDownSettingsTile<int>(
                title: _localizedStrings[_leftBottomParameter],
                settingKey: 'setting-monitor-param3',
                values: ParamNames,
                selected: 2,
                onChange: (value) {
                  debugPrint('setting-monitor-param3: $value');
                },
                ),
              DropDownSettingsTile<int>(
                title: _localizedStrings[_rightTopParameter],
                settingKey: 'setting-monitor-param4',
                values: ParamNames,
                selected: 3,
                onChange: (value) {
                  debugPrint('setting-monitor-param4: $value');
                },
                ),
              DropDownSettingsTile<int>(
                title: _localizedStrings[_rightBottomParameter],
                settingKey: 'setting-monitor-param5',
                values: ParamNames,
                selected: 5,
                onChange: (value) {
                  debugPrint('setting-monitor-param5: $value');
                },
                ),
            ]),
          ],
        ));
  }
}
