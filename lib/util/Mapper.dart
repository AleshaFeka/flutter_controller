import 'dart:typed_data';

import 'package:flutter_controller/bloc/AnalogTabBloc.dart';
import 'package:flutter_controller/bloc/BatteryTabBloc.dart';
import 'package:flutter_controller/bloc/MotorTabBloc.dart';
import 'package:flutter_controller/core/Packet.dart';
import 'package:flutter_controller/model/AnalogSettings.dart';
import 'package:flutter_controller/model/BatterySettings.dart';
import 'package:flutter_controller/model/MotorSettings.dart';

class Mapper {
  static const PACKET_LENGTH = 28;
  static const SCREEN_NUM_AND_COMMAND_NUM_OFFSET = 2;

  static Packet motorSettingsToPacket(MotorSettings settings) {
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


    return Packet(MotorTabBloc.SCREEN_NUMBER, command, data);
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
    result.motorFlux = ByteData.view(buffer).getUint16(18, Endian.little) / 100000.0;
    result.phaseCorrection = ByteData.view(buffer).getUint16(20, Endian.little) / 1000.0;
    result.wheelDiameter = ByteData.view(buffer).getUint16(22, Endian.little);

    return result;
  }

  static Packet batterySettingsToPacket(BatterySettings settings) {
    int command = 1;

    Uint8List data = Uint8List(PACKET_LENGTH);
    ByteData dataBuffer = data.buffer.asByteData();

    dataBuffer.setUint16(0, settings.fullVoltage, Endian.little);
    dataBuffer.setUint16(2, settings.lowVoltage.toInt(), Endian.little);
    dataBuffer.setUint16(4, settings.driveCurrent.toInt(), Endian.little);
    dataBuffer.setUint16(6, settings.regenCurrent, Endian.little);
    dataBuffer.setUint16(8, settings.maxPower, Endian.little);
    dataBuffer.setUint16(10, settings.powerReductionVoltage, Endian.little);


    return Packet(BatteryTabBloc.SCREEN_NUMBER, command, data);
  }

  static BatterySettings packetToBatterySettings(Packet packet) {
    BatterySettings result = BatterySettings.zero();
    ByteBuffer buffer = packet.toBytes.sublist(SCREEN_NUM_AND_COMMAND_NUM_OFFSET).buffer;

    result.fullVoltage = ByteData.view(buffer).getUint16(0, Endian.little);
    result.lowVoltage = ByteData.view(buffer).getUint16(2, Endian.little);
    result.driveCurrent = ByteData.view(buffer).getUint16(4, Endian.little);
    result.regenCurrent = ByteData.view(buffer).getUint16(6, Endian.little);
    result.maxPower = ByteData.view(buffer).getUint16(8, Endian.little);
    result.powerReductionVoltage = ByteData.view(buffer).getUint16(10, Endian.little);

    return result;
  }

  static AnalogSettings packetToAnalogSettings(Packet packet) {
    AnalogSettings result = AnalogSettings.zero();
    ByteBuffer buffer = packet.toBytes.sublist(SCREEN_NUM_AND_COMMAND_NUM_OFFSET).buffer;

    result.throttleMin = ByteData.view(buffer).getUint16(0, Endian.little) / 1000.0;
    result.throttleMax = ByteData.view(buffer).getUint16(2, Endian.little) / 1000.0;
    result.throttleCurveCoefficient1 = ByteData.view(buffer).getUint16(4, Endian.little) ~/ 2048.0;
    result.throttleCurveCoefficient2 = ByteData.view(buffer).getUint16(6, Endian.little) ~/ 2048.0;
    result.throttleCurveCoefficient3 = ByteData.view(buffer).getUint16(8, Endian.little) ~/ 2048.0;

    result.brakeMin = ByteData.view(buffer).getUint16(10, Endian.little) / 1000.0;
    result.brakeMax = ByteData.view(buffer).getUint16(12, Endian.little) / 1000.0;
    result.brakeCurveCoefficient1 = ByteData.view(buffer).getUint16(14, Endian.little) ~/ 2048.0;
    result.brakeCurveCoefficient2 = ByteData.view(buffer).getUint16(16, Endian.little) ~/ 2048.0;
    result.brakeCurveCoefficient3 = ByteData.view(buffer).getUint16(18, Endian.little) ~/ 2048.0;


    return result;
  }

  static Packet analogSettingsToPacket(AnalogSettings settings) {
    int command = 1;

    Uint8List data = Uint8List(PACKET_LENGTH);
    ByteData dataBuffer = data.buffer.asByteData();

    dataBuffer.setUint16(0, (settings.throttleMin * 1000).toInt(), Endian.little);
    dataBuffer.setUint16(0, (settings.throttleMax * 1000).toInt(), Endian.little);
    dataBuffer.setUint16(0, (settings.throttleCurveCoefficient1 * 2048).toInt(), Endian.little);
    dataBuffer.setUint16(0, (settings.throttleCurveCoefficient2 * 2048).toInt(), Endian.little);
    dataBuffer.setUint16(0, (settings.throttleCurveCoefficient3 * 2048).toInt(), Endian.little);
    dataBuffer.setUint16(0, (settings.brakeMin * 1000).toInt(), Endian.little);
    dataBuffer.setUint16(0, (settings.brakeMax * 1000).toInt(), Endian.little);
    dataBuffer.setUint16(0, (settings.brakeCurveCoefficient1 * 2048).toInt(), Endian.little);
    dataBuffer.setUint16(0, (settings.brakeCurveCoefficient2 * 2048).toInt(), Endian.little);
    dataBuffer.setUint16(0, (settings.brakeCurveCoefficient3 * 2048).toInt(), Endian.little);

    return Packet(AnalogTabBloc.SCREEN_NUMBER, command, data);
  }

}