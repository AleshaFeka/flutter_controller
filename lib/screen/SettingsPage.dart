import 'package:flutter/material.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_controller/model/MonitorSettings.dart';
import 'package:flutter_controller/util/Util.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

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
  static const _monitorScreenView = "monitorScreenView";
  static const _monitorSettingsParameters = "monitorSettingsParameters";

  Map _localizedStrings;
  Map<int, String> _paramNames;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localizedStrings = Provider.of(context).localizedStrings;
    _paramNames = (_localizedStrings[_monitorSettingsParameters] as Map)
        .map((key, value) => MapEntry(int.parse(key), value));
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
              onPressed: () {showAbout(context);},
            ),
            // action button
          ],
        ),
        body: ListView(
          children: <Widget>[
            SettingsGroup(
                title: _localizedStrings[_monitorScreenView],
                children: <Widget>[
                  DropDownSettingsTile<int>(
                    title: _localizedStrings[_centerParameter],
                    settingKey: MonitorTabSettings.centerTopParameter,
                    values: _paramNames,
                    selected: 4,
                  ),
                  DropDownSettingsTile<int>(
                    title: _localizedStrings[_leftTopParameter],
                    settingKey: MonitorTabSettings.leftTopParameter,
                    values: _paramNames,
                    selected: 1,
                  ),
                  DropDownSettingsTile<int>(
                    title: _localizedStrings[_leftBottomParameter],
                    settingKey: MonitorTabSettings.leftBottomParameter,
                    values: _paramNames,
                    selected: 2,
                  ),
                  DropDownSettingsTile<int>(
                    title: _localizedStrings[_rightTopParameter],
                    settingKey: MonitorTabSettings.rightTopParameter,
                    values: _paramNames,
                    selected: 3,
                  ),
                  DropDownSettingsTile<int>(
                    title: _localizedStrings[_rightBottomParameter],
                    settingKey: MonitorTabSettings.rightBottomParameter,
                    values: _paramNames,
                    selected: 5,
                  ),
                ]),
          ],
        ));
  }
}
