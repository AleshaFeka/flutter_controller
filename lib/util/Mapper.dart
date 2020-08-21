import 'dart:typed_data';

import 'package:flutter_controller/core/Packet.dart';
import 'package:flutter_controller/model/MotorSettings.dart';

class Mapper {
  static const PACKET_LENGTH = 28;
  static const SCREEN_NUM_AND_COMMAND_NUM_OFFSET = 2;

  static Packet motorSettingsToPacket(MotorSettings settings) {
    int screenNumber = 1;
    int command = 1;

    Uint8List data = Uint8List(PACKET_LENGTH);
    ByteData dataBuffer = data.buffer.asByteData();

    dataBuffer.setUint16(0, settings.motorPolePairs, Endian.little);
    dataBuffer.setUint16(2, settings.motorTemperatureMax.toInt(), Endian.little);
    dataBuffer.setUint16(4, settings.motorTemperatureLimit.toInt(), Endian.little);

    dataBuffer.setUint16(6, settings.motorSpeedMax, Endian.little);
    dataBuffer.setUint16(8, settings.motorDirection, Endian.little);
    dataBuffer.setUint16(10, settings.motorTemperatureSensorType, Endian.little);
    dataBuffer.setUint16(12, settings.motorPositionSensorType, Endian.little);
    dataBuffer.setUint16(14, ( settings.motorStatorResistance * 1000.0 ).toInt(), Endian.little);
    dataBuffer.setUint16(16, ( settings.motorInductance * 1000000.0 ).toInt(), Endian.little);
    dataBuffer.setUint16(18, ( settings.motorFlux * 100000.0 ).toInt(), Endian.little);
    dataBuffer.setUint16(20, ( settings.phaseCorrection * 1000.0 ).toInt(), Endian.little);
    dataBuffer.setUint16(22, settings.wheelDiameter, Endian.little);


    return Packet(screenNumber, command, data);
  }

  static MotorSettings packetToMotorSettings(Packet packet) {
    MotorSettings result = MotorSettings.zero();
    ByteBuffer buffer = packet.toBytes.sublist(SCREEN_NUM_AND_COMMAND_NUM_OFFSET).buffer;

    result.motorPolePairs = ByteData.view(buffer).getUint16(0, Endian.little);
    result.motorTemperatureMax = ByteData.view(buffer).getUint16(2, Endian.little).toDouble();
    result.motorTemperatureLimit = ByteData.view(buffer).getUint16(4, Endian.little).toDouble();
    result.motorSpeedMax = ByteData.view(buffer).getUint16(6, Endian.little);
    result.motorDirection = ByteData.view(buffer).getUint16(8, Endian.little);
    result.motorTemperatureSensorType = ByteData.view(buffer).getUint16(10, Endian.little);
    result.motorPositionSensorType = ByteData.view(buffer).getUint16(12, Endian.little);
    result.motorStatorResistance = ByteData.view(buffer).getUint16(14, Endian.little).toDouble();
    result.motorInductance = ByteData.view(buffer).getUint16(16, Endian.little).toDouble();
    result.motorFlux = ByteData.view(buffer).getUint16(18, Endian.little).toDouble();
    result.phaseCorrection = ByteData.view(buffer).getUint16(20, Endian.little).toDouble();
    result.wheelDiameter = ByteData.view(buffer).getUint16(22, Endian.little);

    return result;
  }
}