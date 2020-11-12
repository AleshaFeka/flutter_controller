import 'package:flutter/material.dart';
import 'package:flutter_controller/bloc/BatteryTabBloc.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_controller/model/BatterySettings.dart';
import 'package:flutter_controller/widget/tab/CommonSettingsTab.dart';

class BatteryTab extends StatefulWidget{
  @override
  _BatteryTabState createState() => _BatteryTabState();
}

class _BatteryTabState extends CommonSettingsTabState<BatteryTab, BatterySettings> {
  static const _batteryParameterNames = "batteryParameterNames";

  final _formKey = GlobalKey<FormState>();

  BatteryTabBloc _batteryTabBloc;
  Map _parameterNames;
  Map<String, String Function(String, String)> _validators;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _batteryTabBloc = Provider.of(context).batteryTabBloc;
    _parameterNames = localizedStrings[_batteryParameterNames];
  }

  @override
  Widget buildRow(String parameterName, String value, String variableName) {
    String Function(String) validator = (String value) {
      String validationResult = validateNotNullOrEmpty(value, variableName);

      if (validationResult == null) {
        validationResult = (_validators[variableName] ?? _validators["default"])?.call(value, variableName);
      }

      return validationResult;
    };

    Widget inputField = _buildTextInput(validator, variableName, value);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 4,
        ),
        Expanded(
          flex: 4,
          child: Container(
            height: 40,
            child: Align(
              alignment: Alignment(-1, 0),
              child: Text(parameterName),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            height: 40,
            child: Align(alignment: Alignment(0.5, 0), child: inputField),
          ),
        ),
        Container(
          width: 4,
        )
      ],
    );
  }

  TextFormField _buildTextInput(validator, String variableName, String value) {
    return TextFormField(
      validator: validator,
/*
      onSaved: (value) {
        _motorTabBloc.motorSettingsDataStream.add(Parameter(variableName, value));
      },
*/
      controller: TextEditingController()..text = value,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        errorStyle: TextStyle(height: 0), // Use just red border without text
        border: OutlineInputBorder()));
  }

  @override
  GlobalKey<State<StatefulWidget>> getFormKey() => _formKey;

  @override
  Map getParameterNames() => _parameterNames;

  @override
  Map getParameterValues(AsyncSnapshot<BatterySettings> snapshot) {
    return Map<String, dynamic>();
  }

  @override
  Stream<BatterySettings> getTypedStream() => _batteryTabBloc.batteryInstantSettingsStream;

  @override
  void onRead() {
    print("BatteryTab - onRead");
  }

  @override
  void onSave() {
    print("BatteryTab - onSave");
  }

  @override
  void onWrite() {
    print("BatteryTab - onWrite");
  }
}