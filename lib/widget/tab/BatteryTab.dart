import 'package:flutter/material.dart';
import 'package:flutter_controller/bloc/BatteryTabBloc.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_controller/model/BatterySettings.dart';
import 'package:flutter_controller/model/Parameter.dart';
import 'package:flutter_controller/widget/tab/CommonSettingsTab.dart';

class BatteryTab extends StatefulWidget {
  @override
  _BatteryTabState createState() => _BatteryTabState();
}

class _BatteryTabState extends CommonSettingsTabState<BatteryTab, BatterySettings> {
  static const _batteryParameterNames = "batteryParameterNames";
  static const _possibleNegativeValues = [ ];
  static const _onlyIntegerValues = [ ];

  final _formKey = GlobalKey<FormState>();

  BatteryTabBloc _batteryTabBloc;
  Map _parameterNames;
  Map<String, String Function(String, String)> _validators;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _batteryTabBloc = Provider.of(context).batteryTabBloc;
    _parameterNames = localizedStrings[_batteryParameterNames];

    _validators = {
      "default": (String value, String variableName) {
        double number = double.parse(value, (e) => null);
        if (number == null) {
          return localizedStrings[CommonSettingsTabState.NOT_NUMBER];
        }
        if (_onlyIntegerValues.contains(variableName) && number.round() != number) {
          return localizedStrings[CommonSettingsTabState.NOT_INTEGER_NUMBER];
        }
        if (!_possibleNegativeValues.contains(variableName) && number < 0) {
          return localizedStrings[CommonSettingsTabState.LESS_THAN_ZERO];
        }

        return null;
      },
    };
    
    _batteryTabBloc.batterySettingsCommandStream.add(BatterySettingsCommand.REFRESH);
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
      onSaved: (value) {
        _batteryTabBloc.batterySettingsDataStream.add(Parameter(variableName, value));
      },
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
    if (snapshot.hasData) {
      return snapshot.data.toJson();
    } else {
      return Map<String, dynamic>();
    }
  }

  @override
  Stream<BatterySettings> getTypedStream() => _batteryTabBloc.batteryInstantSettingsStream;

  @override
  void onRead() {
    _batteryTabBloc.batterySettingsCommandStream.add(BatterySettingsCommand.READ);
  }

  @override
  void onSave() {
    _batteryTabBloc.batterySettingsCommandStream.add(BatterySettingsCommand.SAVE);
  }

  @override
  void onWrite() {
    if (!_formKey.currentState.validate()) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(localizedStrings[CommonSettingsTabState.WRITING_NOT_ALLOWED])));
      return;
    } else {
      _formKey.currentState.save();
      _batteryTabBloc.batterySettingsCommandStream.add(BatterySettingsCommand.WRITE);
    }

  }
}
