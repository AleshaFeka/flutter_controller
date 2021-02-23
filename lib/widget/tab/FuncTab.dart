import 'package:flutter/material.dart';
import 'package:flutter_controller/bloc/FuncTabBloc.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_controller/model/FuncSettings.dart';
import 'package:flutter_controller/model/Parameter.dart';

import 'CommonSettingsTab.dart';

class FuncTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FuncTabState();
}

class _FuncTabState extends State<FuncTab> {
  static const _possibleNegativeValues = [];
  static const _onlyIntegerValues = [];
  static const _emptyValue = "emptyValue";
  static const _read = "read";
  static const _write = "write";
  static const _save = "save";

  static const _CAN_CONTROL = "canBusControl";
  static const _ACTIVE_FUNCTIONS = "activeFunctions";
  static const _PROFILE_1 = "profile1";
  static const _PROFILE_2 = "profile2";
  static const _FUNC_PARAMS_NAMES = "functionParameterNames";
  static const _INVERT = "invert";

  Map _localizedStrings;
  Map _parameterNames;
  FuncTabBloc _bloc;
  Map<String, String Function(String, String)> _validators;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localizedStrings = Provider.of(context).localizedStrings;
    _parameterNames = _localizedStrings[_FUNC_PARAMS_NAMES];
    _bloc = Provider.of(context).funcTabBloc;

    _validators = {
      "validateNotNullOrEmpty": (String value, String variableName) {
        if (value == null) {
          return _localizedStrings[_emptyValue];
        }
        if (value.isEmpty) {
          return _localizedStrings[_emptyValue];
        }

        return null;
      },
      "default": (String value, String variableName) {
        double number = double.parse(value, (e) => null);
        if (number == null) {
          return _localizedStrings[CommonSettingsTabState.NOT_NUMBER];
        }
        if (_onlyIntegerValues.contains(variableName) && number.round() != number) {
          return _localizedStrings[CommonSettingsTabState.NOT_INTEGER_NUMBER];
        }
        if (!_possibleNegativeValues.contains(variableName) && number < 0) {
          return _localizedStrings[CommonSettingsTabState.LESS_THAN_ZERO];
        }

        return null;
      },
    };

    _bloc.funcSettingsCommandStream.add(FuncSettingsCommand.REFRESH);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FuncSettings>(
        stream: _bloc.funcViewModelStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return buildError(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return buildLoading();
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: _buildContent(context, snapshot.data),
          );
        });
  }

  Widget buildError(String message) {
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

  Widget buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, FuncSettings settings) {
    return Column(
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildInOptions(context, settings),
                _buildCanOption(context, "canInput", "dropDownTitle", (value) => print(value), settings.useCan),
                _buildS1ProfileOptions(context, settings),
                _buildS2ProfileOptions(context, settings),
              ],
            ),
          ),
        ),
        _buildButtons()
      ],
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          RaisedButton(
            child: Text(_localizedStrings[_read]),
            onPressed: () {
//              onRead();
            },
          ),
          Expanded(
            child: Container(),
          ),
          RaisedButton(
            onPressed: () {
//              onWrite();
            },
            child: Text(_localizedStrings[_write]),
          ),
          Expanded(child: Container()),
          RaisedButton(
            onPressed: () {
//              onSave();
            },
            child: Text(_localizedStrings[_save]),
          ),
        ],
      ),
    );
  }

  Widget _buildS1ProfileOptions(BuildContext context, FuncSettings settings) {
    final s1MaxTorqueCurrent = "s1MaxTorqueCurrent";
    final s1MaxBrakeCurrent = "s1MaxBrakeCurrent";
    final s1MaxSpeed = "s1MaxSpeed";
    final s1MaxBatteryCurrent = "s1MaxBatteryCurrent";
    final s1MaxFieldWeakingCurrent = "s1MaxFieldWeakingCurrent";

    return TitledCard(
        title: _PROFILE_1,
        child: Column(
          children: [
            _buildRow(_parameterNames[s1MaxTorqueCurrent], settings.s1MaxTorqueCurrent.toString(), s1MaxTorqueCurrent),
            _buildRow(_parameterNames[s1MaxBrakeCurrent], settings.s1MaxBrakeCurrent.toString(), s1MaxBrakeCurrent),
            _buildRow(_parameterNames[s1MaxSpeed], settings.s1MaxSpeed.toString(), s1MaxSpeed),
            _buildRow(
                _parameterNames[s1MaxBatteryCurrent], settings.s1MaxBatteryCurrent.toString(), s1MaxBatteryCurrent),
            _buildRow(_parameterNames[s1MaxFieldWeakingCurrent], settings.s1MaxFieldWeakingCurrent.toString(),
                s1MaxFieldWeakingCurrent),
            Container(
              height: 8,
            )
          ],
        ));
  }

  Widget _buildS2ProfileOptions(BuildContext context, FuncSettings settings) {
    final s2MaxTorqueCurrent = "s1MaxTorqueCurrent";
    final s2MaxBrakeCurrent = "s1MaxBrakeCurrent";
    final s2MaxSpeed = "s1MaxSpeed";
    final s2MaxBatteryCurrent = "s1MaxBatteryCurrent";
    final s2MaxFieldWeakingCurrent = "s1MaxFieldWeakingCurrent";

    return TitledCard(
        title: _PROFILE_2,
        child: Column(
          children: [
            _buildRow(_parameterNames[s2MaxTorqueCurrent], settings.s2MaxTorqueCurrent.toString(), s2MaxTorqueCurrent),
            _buildRow(_parameterNames[s2MaxBrakeCurrent], settings.s2MaxBrakeCurrent.toString(), s2MaxBrakeCurrent),
            _buildRow(_parameterNames[s2MaxSpeed], settings.s2MaxSpeed.toString(), s2MaxSpeed),
            _buildRow(
                _parameterNames[s2MaxBatteryCurrent], settings.s2MaxBatteryCurrent.toString(), s2MaxBatteryCurrent),
            _buildRow(_parameterNames[s2MaxFieldWeakingCurrent], settings.s2MaxFieldWeakingCurrent.toString(),
                s2MaxFieldWeakingCurrent),
            Container(
              height: 8,
            )
          ],
        ));
  }

  Widget _buildRow(String parameterName, String value, String variableName) {
    String Function(String) validator = (String value) {
      String validationResult = _validators["default"](value, variableName);

      if (validationResult == null) {
        validationResult = (_validators[variableName] ?? _validators["default"])?.call(value, variableName);
      }

      return validationResult;
    };

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
            child: Align(alignment: Alignment(0.5, 0), child: _buildTextInput(validator, variableName, value)),
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
//        _driveTabBloc.driveSettingsDataStream.add(Parameter(variableName, value));
        },
        controller: TextEditingController()..text = value,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            errorStyle: TextStyle(height: 0), // Use just red border without text
            border: OutlineInputBorder()));
  }

  void _onInvertChecked(String variableName, String isChecked) {
    _bloc.funcSettingsDataStream.add(Parameter(variableName, isChecked));
    _bloc.funcSettingsCommandStream.add(FuncSettingsCommand.REFRESH);
  }

  void _onDropDownChecked(String variableName, String newDropDownValue) {
    _bloc.funcSettingsDataStream.add(Parameter(variableName, newDropDownValue));
    _bloc.funcSettingsCommandStream.add(FuncSettingsCommand.REFRESH);
  }

  Widget _buildInOptions(BuildContext context, FuncSettings settings) => TitledCard(
        title: _ACTIVE_FUNCTIONS,
        elevation: 0.4,
        child: Column(
          children: [
            _buildSingleInOption(context, "in1", settings.in1, "invertIn1", settings.invertIn1),
          Divider(
            height: 1,
          ),
            _buildSingleInOption(context, "in2", settings.in2, "invertIn2", settings.invertIn2),
          Divider(
            height: 1,
          ),
            _buildSingleInOption(context, "in3", settings.in3, "invertIn3", settings.invertIn3),
          Divider(
            height: 1,
          ),
            _buildSingleInOption(context, "in4", settings.in4, "invertIn4", settings.invertIn4),
          Divider(
            height: 1,
          ),
          ],
        ),
      );

  Widget _buildSingleInOption(
    BuildContext context,
    String dropDownVariableName,
    int dropDownVariableValue,
    String checkBoxVariableName,
    bool checkBoxVariableValue,
  ) {
    final dropDownTitle = getString(InputFunctions.values[dropDownVariableValue]);
    final optionTitle = _parameterNames[dropDownVariableName];
    final checkBoxTitle = _parameterNames[_INVERT];

    final onCheckBoxChanged = (isChecked) => _onInvertChecked(checkBoxVariableName, isChecked.toString());
    final onDropDownSelect =
        (newDropDownValue) => _onDropDownChecked(dropDownVariableName, newDropDownValue.toString());

    final options = InputFunctions.values.map((inputFunction) => getString(inputFunction)).toList();
    final dropDown = _buildDropDownMenu(context, dropDownTitle, options, onDropDownSelect, dropDownTitle);

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(optionTitle),
        ),
        Flexible(child: dropDown),
        Container(
          width: 16,
        ),
        Text(checkBoxTitle),
        Checkbox(
          value: checkBoxVariableValue,
          onChanged: onCheckBoxChanged,
        )
      ],
    );
  }

  Widget _buildDropDownMenu(
      BuildContext context, String title, List<String> options, Function(String) onSelect, String initial) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: PopupMenuButton<String>(
          onSelected: (value) {
            final index = options.indexOf(value);
            onSelect(InputFunctions.values[index].toString());
          },
          child: Row(
            children: [
              Icon(Icons.arrow_drop_down),
              Flexible(
                  child: Text(
                initial,
                overflow: TextOverflow.fade,
                maxLines: 1,
              )),
            ],
          ),
          itemBuilder: (BuildContext context) {
            return options
                .map((optionName) => PopupMenuItem<String>(
                      child: Text(optionName),
                      value: optionName,
                    ))
                .toList();
          }),
    );
  }

  Widget _buildCanOption(
      BuildContext context, String optionTitle, String dropDownTitle, Function(String) onDropDownSelect, bool useCan) {
    final options = [getString("yes"), getString("no")];
    final dropDown =
        _buildDropDownMenu(context, dropDownTitle, options, onDropDownSelect, useCan ? options[0] : options[1]);
    return TitledCard(
      title: _CAN_CONTROL,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(optionTitle),
          ),
          Flexible(child: dropDown),
          Expanded(child: Container()),
        ],
      ),
    );
  }

  String getString(dynamic key) => _localizedStrings[key.toString()].toString();
}

class TitledCard extends StatelessWidget {
  final Widget child;
  final String title;
  final double elevation;

  TitledCard({this.title, this.child, this.elevation = 0.5});

  @override
  Widget build(BuildContext context) {
    final cardContent = Align(
        alignment: Alignment(-0.9, 0),
        child: Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ));

    return Card(
      elevation: elevation,
      child: Column(
        children: [
          Align(alignment: Alignment(-0.9, 0), child: cardContent),
          child,
        ],
      ),
    );
  }
}
