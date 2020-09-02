import 'package:flutter/material.dart';
import 'package:flutter_controller/bloc/MotorTabBloc.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_controller/model/MotorSettings.dart';
import 'package:flutter_controller/model/Parameter.dart';

class MotorTab extends StatefulWidget {
  @override
  _MotorTabState createState() => _MotorTabState();
}

class _MotorTabState extends State<MotorTab> {
  static const _motorParameterNames = "motorParameterNames";
  static const _read = "read";
  static const _write = "write";
  static const _save = "save";
  static const _invalidValue = "invalidValue";
  static const _notIntegerNumber = "notIntegerNumber";
  static const _lessThanZero = "lessThanZero";
  static const _notANumber = "notANumber";
  static const _writingNotAllowed = "writingNotAllowed";
  static const _parameterValueAccuracy = 2;
  static const _sensorType = "sensorType";

  static const _unknownTemperatureSensor = "unknownTemperatureSensor";
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
  Map _localizedStrings;

  final _formKey = GlobalKey<FormState>();
  Map<String, String Function(String, String)> _validators;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motorTabBloc = Provider.of(context).motorTabBloc;
    _localizedStrings = Provider.of(context).localizedStrings;
    _parameterNames = _localizedStrings[_motorParameterNames];

    _validators = {
      "default": (String value, String variableName) {
        double number = double.parse(value, (e) => null);
        if (number == null) {
          return _localizedStrings[_notANumber];
        }
        if (_onlyIntegerValues.contains(variableName) && number.round() != number) {
          return _localizedStrings[_notIntegerNumber];
        }
        if (!_possibleNegativeValues.contains(variableName) && number < 0) {
          return _localizedStrings[_lessThanZero];
        }

        return null;
      },
      "common": (String value, String variableName) {
        if (value == null) {
          return _localizedStrings[_invalidValue];
        }
        if (value.isEmpty) {
          return _localizedStrings[_invalidValue];
        }

        return null;
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MotorSettings>(
      stream: _motorTabBloc.motorInstantSettingsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }

        return ListView(children: [_buildForm(_parameterNames, _formKey, snapshot), _buildBottomButtons()]);
      },
    );
  }

  Widget _buildForm(Map parameterNames, Key key, AsyncSnapshot<MotorSettings> snapshot) {
    var parameterValues = Map<String, dynamic>();
    if (snapshot.hasData) {
      parameterValues = snapshot.data.toJson();
    }

    List<Widget> children = List();
    children.add(Container(
      height: 8,
    ));
    parameterNames.entries.forEach((nameEntry) {
      String parameterValue = _extractParameterValueFromNum((parameterValues[nameEntry.key] as num));
      String parameterName = nameEntry.value;

      children.add(_buildRow(parameterName, parameterValue, nameEntry.key));
      children.add(Divider(
        height: 1,
        color: Colors.grey,
      ));
    });

    return Form(key: key, child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: children));
  }

  Widget _buildRow(String parameterName, String value, String variableName) {
    String Function(String) validator = (String value) {
      String validationResult = _validators["common"].call(value, variableName);

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
      title = _localizedStrings[options[int.parse(value)]];
    } catch (exc) {
      print(exc);
      title = _localizedStrings[_sensorType];
    }

    return PopupMenuButton<String>(
        onSelected: (newValue) {
          _motorTabBloc.motorSettingsDataStream.add(Parameter(variableName, newValue));
          _motorTabBloc.motorSettingsCommandStream.add(MotorSettingsCommand.READ);
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
                    child: Text(_localizedStrings[optionName]),
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

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          RaisedButton(
            child: Text(_localizedStrings[_read]),
            onPressed: () {
              _motorTabBloc.motorSettingsCommandStream.add(MotorSettingsCommand.READ);
            },
          ),
          Expanded(
            child: Container(),
          ),
          RaisedButton(
            onPressed: () {
              if (!_formKey.currentState.validate()) {
                Scaffold.of(context).showSnackBar(SnackBar(content: Text(_localizedStrings[_writingNotAllowed])));
                return;
              } else {
                _formKey.currentState.save();
                _motorTabBloc.motorSettingsCommandStream.add(MotorSettingsCommand.WRITE);
              }
            },
            child: Text(_localizedStrings[_write]),
          ),
          Expanded(child: Container()),
          RaisedButton(
            onPressed: () {
              _motorTabBloc.motorSettingsCommandStream.add(MotorSettingsCommand.SAVE);
            },
            child: Text(_localizedStrings[_save]),
          ),
        ],
      ),
    );
  }

  String _extractParameterValueFromNum(num raw) {
    if (raw == null) return "";
    String parameterValue = raw.toStringAsFixed(_parameterValueAccuracy);
    if (raw.roundToDouble() == raw) {
      parameterValue = raw.toInt().toString();
    }
    return parameterValue;
  }
}
