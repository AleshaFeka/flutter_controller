import 'package:flutter_controller/model/MotorSettings.dart';

class BluetoothInteractor {
  MotorSettings read() {
    MotorSettings result = MotorSettings.random(50);
    return result;
  }

  void write(MotorSettings motorSettings) {
    print("BluetoothInteractor - WRITE - ${motorSettings.toJson()}");
  }
  void save() {
    print("BluetoothInteractor - SAVE");
  }
}