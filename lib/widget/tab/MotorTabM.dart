import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_controller/bloc/MotorTabBloc.dart';
import 'package:flutter_controller/model/MotorSettings.dart';
import 'package:flutter_controller/screen/MainPage.dart';

class MotorTabM extends StatefulWidget {
  @override
  _MotorTabMState createState() => _MotorTabMState();
}

class _MotorTabMState extends State<MotorTabM> {
  MotorTabBloc _motorTabBloc = MotorTabBloc();
  Map _parameterNames;

  @override
  void didChangeDependencies() {
    _parameterNames = Provider.of(context).localizedStrings;
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return StreamBuilder<MotorSettings>(
      stream: _motorTabBloc.motorInstantSettingsStream,
      initialData: _motorTabBloc.motorSettingsInitial,
      builder: (context, snapshot) {
        return Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  buildRow(),
                  Divider(height: 1, color: Colors.grey,),
                  buildRow()
                ]));
      },
    );
  }

  Widget buildRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 4,),
        Expanded(
          flex: 3,
          child: Container(
            height: 40,
            child: Align(
              alignment: Alignment(-1, 0),
              child: Text("Name"),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 40,
            child: Align(
                alignment: Alignment(0.5, 0),
                child: TextFormField(
                    decoration: InputDecoration(border: OutlineInputBorder(), labelText: ""))),
          ),
        ),
        Container(width: 4,)
      ],
    );
  }

  @override
  void dispose() {
    _motorTabBloc.dispose();
    super.dispose();
  }
}
