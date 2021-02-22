import 'dart:typed_data';

class LiveData {
  final double udc; // Actual DC voltage (V)
  final double uz; // Motor voltage (V)
  final int iAmp; // Motor current (A)
  final int speed; // Motor speed (rad\s)
  final int pel; // Motor power electric (W)
  final int tFet; // controller plate temp (ºC)
  final double activeFlux; // Calculated flux of motor (Weber)
  final double brake; // Brake voltage
  final double tetaShift; // Hall phase shift (rad)
  final int tMot; // motor winding temp (ºC)
  final int hallCnt; // [unsigned] Sum of Hall inputs (0...6)
  final double throttleAct; // RAW voltage of Gas Lever (V)

  LiveData.fromBytes(Uint8List data)
      : udc = ByteData.view(data.buffer).getUint16(0, Endian.little) / 100.0,
        uz = ByteData.view(data.buffer).getUint16(2, Endian.little) / 100.0,
        iAmp = ByteData.view(data.buffer).getInt16(4, Endian.little),
        speed = ByteData.view(data.buffer).getInt16(6, Endian.little),
        pel = ByteData.view(data.buffer).getUint16(8, Endian.little),
        tFet = ByteData.view(data.buffer).getInt16(10, Endian.little),
        activeFlux = ByteData.view(data.buffer).getUint16(12, Endian.little) / 10000.0,
        brake = ByteData.view(data.buffer).getUint16(14, Endian.little) / 1000.0,
        tetaShift = ByteData.view(data.buffer).getInt16(16, Endian.little) / 1000.0,
        tMot = ByteData.view(data.buffer).getInt16(18, Endian.little),
        hallCnt = ByteData.view(data.buffer).getUint16(20, Endian.little),
        throttleAct = ByteData.view(data.buffer).getUint16(22, Endian.little) / 1000.0;


  @override
  String toString() => "udc = $udc | uz = $uz | iAmp = $iAmp | speed = $speed | pel = $pel | tFet = $tFet | "
    "activeFlux = $activeFlux | brake = $brake | tetaShift = $tetaShift | tMot = $tMot | hallCnt = $hallCnt | throttleAct = $throttleAct ";

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
      case 6:
        return tFet.toString() + " ºC";
      case 7:
        return activeFlux.toStringAsFixed(2) + " Вб";
      case 8:
        return brake.toStringAsFixed(3) + " В";
      case 9:
        return tetaShift.toStringAsFixed(2) + " Рад";
      case 10:
        return tMot.toString() + " ºC";
      case 11:
        return hallCnt.toString();
      case 12:
        return throttleAct.toStringAsFixed(3) + " В";

      default:
        return "";
    }
  }
}

