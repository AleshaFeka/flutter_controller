import 'package:flutter/material.dart';
import 'package:flutter_controller/bloc/BatteryTabBloc.dart';
import 'package:flutter_controller/di/Provider.dart';

class BatteryTab extends StatefulWidget{
  @override
  _BatteryTabState createState() => _BatteryTabState();
}

class _BatteryTabState extends State<BatteryTab> {
  static const _batteryParameterNames = "batteryParameterNames";

  BatteryTabBloc _batteryTabBloc;
  Map _parameterNames;
  Map _localizedStrings;


  @override
  void didChangeDependencies() {
    _batteryTabBloc = Provider.of(context).batteryTabBloc;
    _localizedStrings = Provider.of(context).localizedStrings;
    _parameterNames = _localizedStrings[_batteryParameterNames];
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent(_parameterNames);
  }

  Widget _buildContent(Map parameterNames) {
    List<Widget> children = List();
    parameterNames.entries.forEach((element) {
      children.add(_buildRow(element.key, element.value, element.key));
      children.add(Divider(
        height: 1,
        color: Colors.grey,
      ));
    });


    return Column(
      children: children,
    );
  }

  Widget _buildRow(String parameterName, String value, String variableName) {
    String Function(String) validator = (String value) {
/*
      String validationResult = _validators["common"].call(value, variableName);

      if (validationResult == null) {
        validationResult = (_validators[variableName] ?? _validators["default"])?.call(value, variableName);
      }

      return validationResult;
*/
      return null;
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
}