import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_controller/bloc/MotorTabBloc.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_controller/model/MotorSettings.dart';

class MotorTab extends StatefulWidget {
  @override
  _MotorTabState createState() => _MotorTabState();
}

class _MotorTabState extends State<MotorTab> {
  static const _motorParameterNames = "motorParameterNames";
  static const _read = "read";
  static const _write = "write";
  static const _save = "save";
  static const _parameterValueAccuracy = 2;

  MotorTabBloc _motorTabBloc;
  Map _parameterNames;
  Map _localizedStrings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motorTabBloc = Provider.of(context).motorTabBloc;
    _localizedStrings = Provider.of(context).localizedStrings;
    _parameterNames = _localizedStrings[_motorParameterNames];
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return StreamBuilder<MotorSettings>(
      stream: _motorTabBloc.motorInstantSettingsStream,
      initialData: _motorTabBloc.motorSettingsInitial,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }

        return ListView(children: [
          _buildForm(_parameterNames, _formKey, snapshot),
          _buildBottomButtons()
        ]);
      },
    );
  }

  Widget _buildForm(Map parameterNames, Key key, AsyncSnapshot<MotorSettings> snapshot) {
    var parameterValues = Map<String, dynamic>();
    if (snapshot.hasData) {
      parameterValues = snapshot.data.toJson();
    }

    List<Widget> children = List();
    parameterNames.entries.forEach((nameEntry) {
      String parameterValue = _extractParameterValueFromNum((parameterValues[nameEntry.key] as num));
      String parameterName = nameEntry.value;

      children.add(_buildRow(parameterName, parameterValue));
      children.add(Divider(
        height: 1,
        color: Colors.grey,
      ));
    });

    return Form(
        key: key,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, children: children));
  }
  String _extractParameterValueFromNum(num raw) {
    String parameterValue = raw.toStringAsFixed(_parameterValueAccuracy);
    if (raw.roundToDouble() == raw) {
      parameterValue = raw.toInt().toString();
    } 
    return parameterValue;
  }

  Widget _buildRow(String name, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 4,
        ),
        Expanded(
          flex: 3,
          child: Container(
            height: 40,
            child: Align(
              alignment: Alignment(-1, 0),
              child: Text(name),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 40,
            child: Align(
              alignment: Alignment(0.5, 0),
              child: TextFormField(controller: TextEditingController()..text = value,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder())
              )
            ),
          ),
        ),
        Container(
          width: 4,
        )
      ],
    );
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
        Container(height: 16,),
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
              _motorTabBloc.motorSettingsCommandStream
                  .add(MotorSettingsCommand.READ);
            },
          ),
          Expanded(
            child: Container(),
          ),
          RaisedButton(
            onPressed: () {
              _motorTabBloc.motorSettingsCommandStream
                  .add(MotorSettingsCommand.WRITE);
            },
            child: Text(_localizedStrings[_write]),
          ),
          Expanded(child: Container()),
          RaisedButton(
            onPressed: () {
              _motorTabBloc.motorSettingsCommandStream
                  .add(MotorSettingsCommand.SAVE);
            },
            child: Text(_localizedStrings[_save]),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _motorTabBloc.dispose();
    super.dispose();
  }
}
