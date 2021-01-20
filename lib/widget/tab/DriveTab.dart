import 'package:flutter/material.dart';
import 'package:flutter_controller/bloc/DriveTabBloc.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_controller/model/DriveSettings.dart';
import 'package:flutter_controller/model/Parameter.dart';
import 'package:flutter_controller/util/Mapper.dart';
import 'package:flutter_controller/widget/tab/CommonSettingsTab.dart';

class DriveTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DriveTabState();

}

class _DriveTabState extends CommonSettingsTabState<DriveTab, DriveSettings> {

  static const _driveParameterNames = "driveParameterNames";
  static const _possibleNegativeValues = ["phaseWeakingCurrent"];
  static const _onlyIntegerValues = [];
  static const _dropDownInputs = ["pwmFrequency", "controlMode"];
  static const _sensorType = "sensorType";


  DriveTabBloc _driveTabBloc;
  Map _parameterNames;
  Map<String, String Function(String, String)> _validators;
  final _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _driveTabBloc = Provider.of(context).driveTabBloc;
    _parameterNames = localizedStrings[_driveParameterNames];

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

    _driveTabBloc.driveSettingsCommandStream.add(DriveSettingsCommand.REFRESH);
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
      case "pwmFrequency":
        value = Mapper.mapPwmFrequency(value);

        options = DrivePwmFrequency.values.map((e) => e.toString()).toList();
        break;
      case "controlMode":
        options = DriveControlMode.values.map((e) => e.toString()).toList();
        break;
    }

    print("options = ${options}");
    print("value = ${value}");

    String title;
    try {
      title = localizedStrings[options[int.parse(value)]];
    } catch (exc) {
      print(exc);
      title = localizedStrings[_sensorType];
    }

    return PopupMenuButton<String>(
      onSelected: (newValue) {
        _driveTabBloc.driveSettingsDataStream.add(Parameter(variableName, newValue));
        _driveTabBloc.driveSettingsCommandStream.add(DriveSettingsCommand.REFRESH);
      },
      child: Row(
        children: [
          Icon(Icons.arrow_drop_down),
          Flexible(child: Text(title, overflow: TextOverflow.fade, maxLines: 1,)),
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
        _driveTabBloc.driveSettingsDataStream.add(Parameter(variableName, value));
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
  Map getParameterValues(AsyncSnapshot<DriveSettings> snapshot) {
    if (snapshot.hasData) {
      return snapshot.data.toJson();
    } else {
      return Map<String, dynamic>();
    }
  }

  @override
  Stream<DriveSettings> getViewModelStream() => _driveTabBloc.driveViewModelStream;

  @override
  void onRead() {
    print("onRead");
    _driveTabBloc.driveSettingsCommandStream.add(DriveSettingsCommand.READ);
  }

  @override
  void onSave() {
    print("onSave");
    _driveTabBloc.driveSettingsCommandStream.add(DriveSettingsCommand.SAVE);
  }

  @override
  void onWrite() {
    print("onWrite");
    if (!_formKey.currentState.validate()) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(localizedStrings[CommonSettingsTabState.WRITING_NOT_ALLOWED])));
      return;
    } else {
      _formKey.currentState.save();
      _driveTabBloc.driveSettingsCommandStream.add(DriveSettingsCommand.WRITE);
    }
  }

}