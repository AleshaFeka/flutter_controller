import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_controller/bloc/MotorTabBloc.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';

class Provider extends InheritedWidget {
  static Provider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>();
  }

  BluetoothInteractor bluetoothInteractor;
  MotorTabBloc motorTabBloc;
  Map localizedStrings;

  Provider(BuildContext context, {Key key, Widget child})
    : super(key: key, child: child) {
    init(context);
  }

  void init(BuildContext context) async {
    bluetoothInteractor = BluetoothInteractor();
    motorTabBloc = MotorTabBloc(bluetoothInteractor);

    var rawStrings = await DefaultAssetBundle.of(context)
      .loadString('assets/strings/ru.json');
    localizedStrings = json.decode(rawStrings) as Map;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
