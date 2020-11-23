import 'package:flutter/material.dart';
import 'package:flutter_controller/bloc/MotorTabBloc.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_controller/model/MotorSettings.dart';
import 'package:flutter_controller/model/Parameter.dart';
import 'package:flutter_controller/widget/tab/CommonSettingsTab.dart';

class MotorTab extends StatefulWidget {
  @override
  _MotorTabState createState() => _MotorTabState();
}

class _MotorTabState extends CommonSettingsTabState<MotorTab, MotorSettings> {
  static const _motorParameterNames = "motorParameterNames";
  static const _sensorType = "sensorType";

  static const _possibleNegativeValues = ["phaseCorrection"];
  static const _onlyIntegerValues = [
    "motorPolePairs",
    "motorDirection",
    "motorSpeedMax",
    "motorVoltageMax",
    "fieldWakingCurrent"
  ];
  static const _dropDownInputs = ["motorTemperatureSensorType", "motorPositionSensorType"];

  MotorTabBloc _motorTabBloc;
  Map _parameterNames;

  final _formKey = GlobalKey<FormState>();
  Map<String, String Function(String, String)> _validators;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motorTabBloc = Provider.of(context).motorTabBloc;
    _parameterNames = localizedStrings[_motorParameterNames];

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

    Widget inputField = _dropDownInputs.contains(variableName)
        ? _buildDropDownInput(variableName, value)
        : _buildTextInput(validator, variableName, value);

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

  Widget _buildDropDownInput(String variableName, String value) {
    List<String> options;
    switch (variableName) {
      case "motorTemperatureSensorType":
        options = MotorTemperatureSensor.values.map((e) => e.toString()).toList();
        break;
      case "motorPositionSensorType":
        options = MotorPositionSensor.values.map((e) => e.toString()).toList();
        break;
    }

    String title;
    try {
      title = localizedStrings[options[int.parse(value)]];
    } catch (exc) {
      print(exc);
      title = localizedStrings[_sensorType];
    }

    return PopupMenuButton<String>(
        onSelected: (newValue) {
          _motorTabBloc.motorSettingsDataStream.add(Parameter(variableName, newValue));
          _motorTabBloc.motorSettingsCommandStream.add(MotorSettingsCommand.REFRESH);
        },
        child: Row(
          children: [
            Icon(Icons.arrow_drop_down),
            Text(title),
          ],
        ),
        itemBuilder: (BuildContext context) {
          return options
              .map((optionName) => PopupMenuItem<String>(
                    child: Text(localizedStrings[optionName]),
                    value: optionName,
                  ))
              .toList();
        });
  }

  TextFormField _buildTextInput(validator, String variableName, String value) {
    return TextFormField(
        validator: validator,
        onSaved: (value) {
          _motorTabBloc.motorSettingsDataStream.add(Parameter(variableName, value));
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
  Map getParameterValues(AsyncSnapshot<MotorSettings> snapshot) {
    if (snapshot.hasData) {
      return snapshot.data.toJson();
    } else {
      return Map<String, dynamic>();
    }
  }

  @override
  Stream<MotorSettings> getTypedStream() => _motorTabBloc.motorInstantSettingsStream;

  @override
  void onWrite() {
    if (!_formKey.currentState.validate()) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(localizedStrings[CommonSettingsTabState.WRITING_NOT_ALLOWED])));
      return;
    } else {
      _formKey.currentState.save();
      _motorTabBloc.motorSettingsCommandStream.add(MotorSettingsCommand.WRITE);
    }
  }

  @override
  void onSave() {
    _motorTabBloc.motorSettingsCommandStream.add(MotorSettingsCommand.SAVE);
  }

  @override
  void onRead() {
    _motorTabBloc.motorSettingsCommandStream.add(MotorSettingsCommand.READ);
  }
}
