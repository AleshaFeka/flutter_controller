
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class ResourceInteractor {
  Map localizedStrings;

  Future<bool> init(BuildContext context) async {
    var rawStrings = await DefaultAssetBundle.of(context)
      .loadString('assets/strings/ru.json');
    localizedStrings = await json.decode(rawStrings) as Map;
    return Future<bool>.delayed(Duration(milliseconds: 100),() => true,); //Just for debug )))
  }
}