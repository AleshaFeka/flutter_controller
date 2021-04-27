import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_controller/bloc/AnalogTabBloc.dart';
import 'package:flutter_controller/bloc/BatteryTabBloc.dart';
import 'package:flutter_controller/bloc/ConnectPageBloc.dart';
import 'package:flutter_controller/bloc/DriveTabBloc.dart';
import 'package:flutter_controller/bloc/FuncTabBloc.dart';
import 'package:flutter_controller/bloc/MonitorTabBloc.dart';
import 'package:flutter_controller/bloc/MotorTabBloc.dart';
import 'package:flutter_controller/bloc/RegTabBloc.dart';
import 'package:flutter_controller/bloc/IdentificationTabBloc.dart';
import 'package:flutter_controller/bloc/TabsPageBloc.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/interactor/ResourceInteractor.dart';

class Provider extends InheritedWidget {
  static Provider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>();
  }

  BluetoothInteractor bluetoothInteractor;
  ResourceInteractor _resourceInteractor;

  ConnectPageBloc connectPageBloc;
  TabsPageBloc tabsPageBloc;
  MotorTabBloc motorTabBloc;
  MonitorTabBloc monitorTabBloc;
  BatteryTabBloc batteryTabBloc;
  AnalogTabBloc analogTabBloc;
  DriveTabBloc driveTabBloc;
  FuncTabBloc funcTabBloc;
  RegTabBloc regTabBloc;
  IdentificationTabBloc ssTabBloc;

  Map get localizedStrings => _resourceInteractor.localizedStrings;

  Provider(this._resourceInteractor, this.bluetoothInteractor, {Key key, Widget child})
      : super(key: key, child: child) {
    connectPageBloc = ConnectPageBloc(bluetoothInteractor);
    tabsPageBloc = TabsPageBloc(bluetoothInteractor);
    monitorTabBloc = MonitorTabBloc(bluetoothInteractor);
    motorTabBloc = MotorTabBloc(bluetoothInteractor);
    batteryTabBloc = BatteryTabBloc(bluetoothInteractor);
    analogTabBloc = AnalogTabBloc(bluetoothInteractor);
    driveTabBloc = DriveTabBloc(bluetoothInteractor);
    funcTabBloc = FuncTabBloc(bluetoothInteractor);
    regTabBloc = RegTabBloc(bluetoothInteractor);
    ssTabBloc = IdentificationTabBloc(bluetoothInteractor);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
