import 'dart:convert';
import 'package:flutter/material.dart';

class ResourceInteractor {
  static const _localizedStringsFileName = "assets/strings/ru.json";
  Map localizedStrings;

  Future<bool> init(BuildContext context) async {
    var rawStrings = await DefaultAssetBundle.of(context)
      .loadString(_localizedStringsFileName);
    localizedStrings = await json.decode(rawStrings) as Map;
    return Future<bool>.delayed(Duration(milliseconds: 500),() => true,); //Just for debug )))
  }
}