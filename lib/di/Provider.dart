import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_controller/bloc/MotorTabBloc.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/interactor/ResourceInteractor.dart';

class Provider extends InheritedWidget {
  static Provider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>();
  }

  BluetoothInteractor bluetoothInteractor;
  ResourceInteractor resourceInteractor;
  MotorTabBloc motorTabBloc;

  Map get localizedStrings => resourceInteractor.localizedStrings;

  Provider(this.resourceInteractor, this.bluetoothInteractor, {Key key, Widget child})
      : super(key: key, child: child) {
    motorTabBloc = MotorTabBloc(bluetoothInteractor);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
