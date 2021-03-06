import 'package:flutter/material.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
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
  BluetoothInteractor _bluetoothInteractor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bluetoothInteractor = Provider.of(context).bluetoothInteractor;
    _localizedStrings = Provider.of(context).localizedStrings;
    _paramNames =
        (_localizedStrings[_monitorSettingsParameters] as Map).map((key, value) => MapEntry(int.parse(key), value));
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
              onPressed: () {
                showAbout(context);
              },
            ),
            // action button
          ],
        ),
        body: ListView(
          children: <Widget>[
            SettingsGroup(title: _localizedStrings[_monitorScreenView], children: <Widget>[
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
              Container(height: 24,),
              ElevatedButton(
                child: Text(_localizedStrings['restartController']),
                onPressed: () {
                  _showConfirmationDialog(context, _localizedStrings['askRestartController'], () {
                    _bluetoothInteractor.restartController();
                  });
                },
              ),
              ElevatedButton(
                child: Text(_localizedStrings['resetToDefaults']),
                onPressed: () {
                  _showConfirmationDialog(context, _localizedStrings['askResetToDefaults'], () {
                    _bluetoothInteractor.resetController();
                  });
                },
              ),
              ElevatedButton(
                child: Text(_localizedStrings['bootloaderMode']),
                onPressed: () {
                  _showConfirmationDialog(context, _localizedStrings['askBootloaderMode'], () {
                    _bluetoothInteractor.turnToBootloaderMode();
                  });
                },
              ),
            ]),
          ],
        ));
  }

  Future<void> _showConfirmationDialog(BuildContext context, String confirmationText, Function onApprove) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_localizedStrings['confirmation']),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(confirmationText),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                onApprove();
                Navigator.of(context).pop();
              },
            ),
            Container(width: 8,),
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
