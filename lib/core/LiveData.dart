import 'dart:typed_data';

//typedef struct{
//  float Udc; //Actual DC voltage
//  float Uz; //Motor voltage
//  float Iamp;//Motor current
//  float Speed;//Motor speed Rad\s
//  float Pel; //Motor power electric
//  float P;//Motor power mechanic
//  float Tfet;//controller plate tempr
//  float Tmot;//motor winding temp
//  float Trottle;//Trottle level in percent
//  float Active_Flux;//Calculated flux of motor
//  float Brake;//Brake level in percent
//  float Teta_shift;// Hall phase shift
//  unsigned int Hall_cnt; //Summ of Hall inputs
//  float Trottle_Act;// RAW voltage of Gas Lever
//} Live_st;

/*
final ParamNames = <int, String>{
  1: 'Battery voltage',
  2: 'Motor voltage',
  3: 'Motor current',
  4: 'Motor speed',
  5: 'Motor power',
  //6: 'Motor power mechanic (W)
  7: 'Controller temp',
  8: 'Motor temp',
  //9: 'Throttle level (%)
  10: 'Motor flux',
  11: 'Brake voltage',
  12: 'Halls phase shift',
  13: 'Halls position',
  14: 'Throttle voltage',
};
*/

class LiveData {
  final double udc; // Actual DC voltage (V)
  final double uz; // Motor voltage (V)
  final int iAmp; // Motor current (A)
  final int speed; // Motor speed (rad\s)
  final int pel; // Motor power electric (W)
//  final double p; // Motor power mechanic (W)
  final int tFet; // controller plate temp (ºC)
  final int tMot; // motor winding temp (ºC)
//  final double throttle; // Throttle level (%)
  final double activeFlux; // Calculated flux of motor (Weber)
  final double brake; // Brake voltage
  final double tetaShift; // Hall phase shift (rad)
  final int hallCnt; // [unsigned] Sum of Hall inputs (0...6)
  final double throttleAct; // RAW voltage of Gas Lever (V)

//  LiveData() {
//    print("Non-parameterized constructor invoked");
//  }

//  my_Live.Udc = uart_msg->message.message_layer.data_buffer[0] / 100.;
//  my_Live.Uz = uart_msg->message.message_layer.data_buffer[1] / 100.;
//  my_Live.Iamp = (reinterpret_cast<short&>(uart_msg->message.message_layer.data_buffer[2]));
//  my_Live.Speed = (reinterpret_cast<short&>(uart_msg->message.message_layer.data_buffer[3]));
//  my_Live.Pel = uart_msg->message.message_layer.data_buffer[4];
//  my_Live.Tfet = (reinterpret_cast<short&>(uart_msg->message.message_layer.data_buffer[5]));
//  my_Live.Trottle = uart_msg->message.message_layer.data_buffer[6] / 10000.;
//  my_Live.Active_Flux = uart_msg->message.message_layer.data_buffer[6] / 10000.;
//  my_Live.Brake = uart_msg->message.message_layer.data_buffer[7] / 1000.;
//  my_Live.Teta_shift = (reinterpret_cast<short&>(uart_msg->message.message_layer.data_buffer[8])) / 1e3;
//  my_Live.Tmot = (reinterpret_cast<short&>(uart_msg->message.message_layer.data_buffer[9]));
//  my_Live.Hall_cnt = uart_msg->message.message_layer.data_buffer[10];
//  my_Live.Trottle_Act = uart_msg->message.message_layer.data_buffer[11] / 1000.;
//  my_Control.statuc_word = uart_msg->message.message_layer.data_buffer[12];
//  my_Control.alg_mode = uart_msg->message.message_layer.data_buffer[13];

  LiveData.fromBytes(Uint8List data)
      : udc = ByteData.view(data.buffer).getUint16(0, Endian.little) / 100.0,
        uz = ByteData.view(data.buffer).getUint16(2, Endian.little) / 100.0,
        iAmp = ByteData.view(data.buffer).getInt16(4, Endian.little),
        speed = ByteData.view(data.buffer).getInt16(6, Endian.little),
        pel = ByteData.view(data.buffer).getUint16(8, Endian.little),
//        p = 8923.45,
        tFet = ByteData.view(data.buffer).getInt16(10, Endian.little),
//        throttle = ByteData.view(data.buffer).getUint16(12, Endian.little) / 10000.0,
        activeFlux = ByteData.view(data.buffer).getUint16(12, Endian.little) / 10000.0,
        brake = ByteData.view(data.buffer).getUint16(14, Endian.little) / 1000.0,
        tetaShift = ByteData.view(data.buffer).getInt16(16, Endian.little) / 1000.0,
        tMot = ByteData.view(data.buffer).getInt16(18, Endian.little),
        hallCnt = ByteData.view(data.buffer).getUint16(20, Endian.little),
        throttleAct = ByteData.view(data.buffer).getUint16(22, Endian.little) / 1000.0;

  String getParameter(int paramNum) {
    switch (paramNum) {
      case 1:
        return udc.toStringAsFixed(2) + " В";
      case 2:
        return uz.toStringAsFixed(2) + " В";
      case 3:
        return iAmp.toStringAsFixed(2) + " А";
      case 4:
        return speed.toStringAsFixed(2) + " рад/с";
      case 5:
        return pel.toStringAsFixed(2) + " Вт";
//      case 6:
//        return pel.toStringAsFixed(2) + " Вт";
      case 7:
        return tFet.toString() + " ºC";
      case 8:
        return tMot.toString() + " ºC";
//      case 9:
//        return pel.toStringAsFixed(2) + " Вт";
      case 10:
        return activeFlux.toStringAsFixed(2) + " Вб";
      case 11:
        return brake.toStringAsFixed(3) + " В";
      case 12:
        return tetaShift.toStringAsFixed(2) + " Рад";
      case 13:
        return hallCnt.toString();
      case 14:
        return throttleAct.toStringAsFixed(3) + " В";
      default:
        return "";
    }
  }
}

