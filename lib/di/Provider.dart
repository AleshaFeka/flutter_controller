import 'dart:convert';

import 'package:flutter/material.dart';

class Provider extends InheritedWidget {
  static Provider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>();
  }

  var localizedStrings;

  Provider(BuildContext context, {Key key, Widget child})
    : super(key: key, child: child) {
    init(context);
  }

  void init(BuildContext context) async {
    var strings = await DefaultAssetBundle.of(context)
      .loadString('assets/strings/ru.json');
    localizedStrings = json.decode(strings) as Map;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
