import 'package:flutter/material.dart';
import 'package:flutter_controller/bloc/AnalogTabBloc.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_controller/model/AnalogSettings.dart';
import 'package:flutter_controller/model/Parameter.dart';
import 'package:flutter_controller/widget/Voltmeter.dart';
import 'package:flutter_controller/widget/tab/CommonSettingsTab.dart';

class AnalogTab extends StatefulWidget {
  @override
  _AnalogTabState createState() => _AnalogTabState();
}

class _AnalogTabState extends CommonSettingsTabState<AnalogTab, AnalogSettings> {
  static const _analogParameterNames = "analogParameterNames";
  static const _possibleNegativeValues = [
    "throttleCurveCoefficient1",
    "throttleCurveCoefficient2",
    "throttleCurveCoefficient3",
    "brakeCurveCoefficient1",
    "brakeCurveCoefficient2",
    "brakeCurveCoefficient3"
  ];
  static const _onlyIntegerValues = [];

  final _formKey = GlobalKey<FormState>();
  AnalogTabBloc _analogTabBloc;
  Map _parameterNames;
  Map<String, String Function(String, String)> _validators;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parameterNames = localizedStrings[_analogParameterNames];
    _analogTabBloc = Provider.of(context).analogTabBloc;
    _validators = {
      "default": (String value, String variableName) {
        double number = double.parse(value);
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
    _analogTabBloc.analogSettingsCommandStream.add(AnalogSettingsCommand.REFRESH);
  }

  @override
  Map getParameterNames() {
    return _parameterNames;
  }

  @override
  Map getParameterValues(AsyncSnapshot<AnalogSettings> snapshot) {
    if (snapshot.hasData) {
      return snapshot.data.toJson();
    } else {
      return Map<String, dynamic>();
    }
  }

  @override
  Stream<AnalogSettings> getViewModelStream() => _analogTabBloc.analogViewModelStream;

  @override
  Widget buildRow(String parameterName, String value, String variableName) {
    if (variableName == "throttleVoltmeter") {
      return _buildThrottleVoltmeter();
    }

    if (variableName == "brakeVoltmeter") {
      return _buildBrakeVoltmeter();
    }

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

  @override
  void dispose() {
    super.dispose();
    _analogTabBloc.analogSettingsCommandStream.add(AnalogSettingsCommand.STOP_MONITORING);
  }

  Widget _buildThrottleVoltmeter() =>
      _buildVoltmeter(_analogTabBloc.throttleValueStream, localizedStrings['monitorSettingsParameters']['12']);

  Widget _buildBrakeVoltmeter() =>
      Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: _buildVoltmeter(_analogTabBloc.brakeValueStream, localizedStrings['monitorSettingsParameters']['8']),
      );

  StreamBuilder<int> _buildVoltmeter(Stream<int> stream, String title,) {
    return StreamBuilder<int>(
        stream: stream,
        builder: (context, snapshot) {
          Voltmeter voltmeter;
          if (snapshot.hasData) {
            voltmeter = Voltmeter(
              milliVolts: snapshot.data,
            );
          } else {
            voltmeter = Voltmeter(
              milliVolts: 0,
            );
          }
          return FittedBox(
            child: Column(
              children: [
                Text(title, style: TextStyle(fontSize: 24),),
                Row(
                  children: [
                    voltmeter,
                    SizedBox(
                        height: 200,
                        width: 200,
                        child: Center(
                            child: Text(
                          voltmeter.volts,
                          style: TextStyle(fontSize: 48),
                        )))
                  ],
                ),
              ],
            ),
          );
        });
  }

  TextFormField _buildTextInput(validator, String variableName, String value) {
    return TextFormField(
        validator: validator,
        onSaved: (value) {
          _analogTabBloc.analogSettingsDataStream.add(Parameter(variableName, value));
        },
        controller: TextEditingController()..text = value,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            errorStyle: TextStyle(height: 0), // Use just red border without text
            border: OutlineInputBorder()));
  }

  @override
  void onRead() {
    _analogTabBloc.analogSettingsCommandStream.add(AnalogSettingsCommand.READ);
  }

  @override
  void onSave() {
    _analogTabBloc.analogSettingsCommandStream.add(AnalogSettingsCommand.SAVE);
  }

  @override
  void onWrite() {
    if (!_formKey.currentState.validate()) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(localizedStrings[CommonSettingsTabState.WRITING_NOT_ALLOWED])));
      return;
    } else {
      _formKey.currentState.save();
      _analogTabBloc.analogSettingsCommandStream.add(AnalogSettingsCommand.WRITE);
    }
  }

  @override
  GlobalKey<State<StatefulWidget>> getFormKey() => _formKey;
}
