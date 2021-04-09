import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
class ResourceInteractor {
  static const _localizedStringsFileNameRu = "assets/strings/ru.json";
  static const _localizedStringsFileNameEn = "assets/strings/en.json";
  Map localizedStrings;

  Future<bool> init(BuildContext context) async {
    final stringResourcesFileName = ui.window.locale.languageCode.toLowerCase().contains("ru")
      ? _localizedStringsFileNameRu
      : _localizedStringsFileNameEn;

    var rawStrings = await DefaultAssetBundle.of(context)
      .loadString(stringResourcesFileName);
    localizedStrings = await json.decode(rawStrings) as Map;
    return Future<bool>.delayed(Duration(milliseconds: 500),() => true,); //Just for debug )))
  }
}