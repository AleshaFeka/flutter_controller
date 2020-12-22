import 'dart:async';

import 'package:flutter_controller/model/AnalogSettings.dart';

class AnalogTabBloc {
  StreamController _analogViewModelStreamController = StreamController<AnalogSettings>.broadcast();
  Stream get analogViewModelStream => _analogViewModelStreamController.stream;

  void dispose() {
    _analogViewModelStreamController.close();
  }

}