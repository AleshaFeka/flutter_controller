import 'package:flutter_controller/model/MotorSettings.dart';

class BluetoothInteractor {
  MotorSettings read() {
    MotorSettings result = MotorSettings.random(50);
    return result;
  }

  void write() {
    print("BluetoothInteractor - WRITE");
  }
  void save() {
    print("BluetoothInteractor - SAVE");
  }
}