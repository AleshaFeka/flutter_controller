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
  MotorTabBloc _motorTabBloc = MotorTabBloc();
  Map _parameterNames;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parameterNames = Provider.of(context).localizedStrings;
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return StreamBuilder<MotorSettings>(
      stream: _motorTabBloc.motorInstantSettingsStream,
      initialData: _motorTabBloc.motorSettingsInitial,
      builder: (context, snapshot) {
        return buildForm(_parameterNames, _formKey);
      },
    );
  }

  Widget buildForm(Map parameterNames, Key key) {
    List<Widget> children = List();
    parameterNames.entries.forEach((element) {
      children.add(buildRow(element.value));
      children.add(Divider(
        height: 1,
        color: Colors.grey,
      ));
    });

    return Form(
        key: key,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
          children: children
        )
    );
  }

  Widget buildRow(String name) {
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
                child: TextFormField(keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: ""))),
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
    _motorTabBloc.dispose();
    super.dispose();
  }
}
