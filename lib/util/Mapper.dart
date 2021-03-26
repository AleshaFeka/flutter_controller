import 'dart:typed_data';

import 'package:flutter_controller/bloc/AnalogTabBloc.dart';
import 'package:flutter_controller/bloc/BatteryTabBloc.dart';
import 'package:flutter_controller/bloc/DriveTabBloc.dart';
import 'package:flutter_controller/bloc/FuncTabBloc.dart';
import 'package:flutter_controller/bloc/MotorTabBloc.dart';
import 'package:flutter_controller/bloc/RegTabBloc.dart';
import 'package:flutter_controller/bloc/SystemSettingsTabBloc.dart';
import 'package:flutter_controller/core/Packet.dart';
import 'package:flutter_controller/model/AnalogSettings.dart';
import 'package:flutter_controller/model/BatterySettings.dart';
import 'package:flutter_controller/model/DriveSettings.dart';
import 'package:flutter_controller/model/FuncSettings.dart';
import 'package:flutter_controller/model/MotorSettings.dart';
import 'package:flutter_controller/model/RegSettings.dart';
import 'package:flutter_controller/model/SystemSettings.dart';

class Mapper {
  static const PACKET_LENGTH = 28;
  static const SCREEN_NUM_AND_COMMAND_NUM_OFFSET = 2;

  static const _COMMAND_SCREEN_NUMBER = 127;

  static String mapPwmFrequency(String input) {
    String value;
    switch (input) {
      case "8000":
        value = "0";
        break;
      case "10000":
        value = "1";
        break;
      case "12000":
        value = "2";
        break;
      case "15000":
        value = "3";
        break;
      case "18000":
        value = "4";
        break;
      case "20000":
        value = "5";
        break;
      case "22000":
        value = "6";
        break;
    }
    return value;
  }

  static buildSavePacket() {
    Uint8List data = Uint8List(PACKET_LENGTH);
    ByteData dataBuffer = data.buffer.asByteData();
    int command = 1;

    final saveWord = "SAVE";

    dataBuffer.setInt16(0, saveWord.codeUnitAt(0), Endian.little);
    dataBuffer.setInt16(2, saveWord.codeUnitAt(1), Endian.little);
    dataBuffer.setInt16(4, saveWord.codeUnitAt(2), Endian.little);
    dataBuffer.setInt16(6, saveWord.codeUnitAt(3), Endian.little);

    return Packet(_COMMAND_SCREEN_NUMBER, command, data);
  }

  static Packet funcSettingsToPacket(FuncSettings settings) {
    int command = 1;

    Uint8List data = Uint8List(PACKET_LENGTH);
    ByteData dataBuffer = data.buffer.asByteData();

    int inWord = settings.in1;
    inWord |= (settings.in2 * 16);
    inWord |= (settings.in3 * 256);
    inWord |= (settings.in4 * 4096);

    int inInversionWord = (settings.invertIn1 ? 1 : 0) << 0;
    inInversionWord |= (settings.invertIn2 ? 1 : 0) << 1;
    inInversionWord |= (settings.invertIn3 ? 1 : 0) << 2;
    inInversionWord |= (settings.invertIn4 ? 1 : 0) << 3;

    dataBuffer.setUint16(0, inWord, Endian.little);
    dataBuffer.setUint16(2, inInversionWord, Endian.little);

    dataBuffer.setUint16(4, settings.s1MaxTorqueCurrent, Endian.little);
    dataBuffer.setUint16(6, settings.s1MaxBrakeCurrent.toInt(), Endian.little);
    dataBuffer.setUint16(8, settings.s1MaxSpeed.toInt(), Endian.little);
    dataBuffer.setUint16(10, settings.s1MaxBatteryCurrent.toInt(), Endian.little);
    dataBuffer.setUint16(12, settings.s1MaxFieldWeakingCurrent.toInt(), Endian.little);

    dataBuffer.setUint16(14, settings.s2MaxTorqueCurrent, Endian.little);
    dataBuffer.setUint16(16, settings.s2MaxBrakeCurrent.toInt(), Endian.little);
    dataBuffer.setUint16(18, settings.s2MaxSpeed.toInt(), Endian.little);
    dataBuffer.setUint16(20, settings.s2MaxBatteryCurrent.toInt(), Endian.little);
    dataBuffer.setUint16(22, settings.s2MaxFieldWeakingCurrent.toInt(), Endian.little);

    dataBuffer.setUint16(26, settings.useCan ? 1 : 0, Endian.little);

    return Packet(FuncTabBloc.SCREEN_NUMBER, command, data);
  }

  static FuncSettings packetToFuncSettings(Packet packet) {
    if (packet.cmd == 31) return null;  // todo remove division after firmware update.

    FuncSettings result = FuncSettings.zero();
    ByteBuffer buffer = packet.toBytes.sublist(SCREEN_NUM_AND_COMMAND_NUM_OFFSET).buffer;

    int inWord = ByteData.view(buffer).getUint16(0, Endian.little);
    result.in1 = (inWord>>0) & 0xf;
    result.in2 = (inWord>>4) & 0xf;
    result.in3 = (inWord>>8) & 0xf;
    result.in4 = (inWord>>12) & 0xf;

    int inInversionWord = ByteData.view(buffer).getUint16(2, Endian.little) ~/ 1000; // todo remove division after firmware update.
    result.invertIn1 = ((inInversionWord>>0) & 0x1 == 1);
    result.invertIn2 = ((inInversionWord>>1) & 0x1 == 1);
    result.invertIn3 = ((inInversionWord>>2) & 0x1 == 1);
    result.invertIn4 = ((inInversionWord>>3) & 0x1 == 1);


    result.s1MaxTorqueCurrent = ByteData.view(buffer).getInt16(4, Endian.little);
    result.s1MaxBrakeCurrent = ByteData.view(buffer).getInt16(6, Endian.little);
    result.s1MaxSpeed = ByteData.view(buffer).getInt16(8, Endian.little);
    result.s1MaxBatteryCurrent = ByteData.view(buffer).getInt16(10, Endian.little);
    result.s1MaxFieldWeakingCurrent = ByteData.view(buffer).getInt16(12, Endian.little);

    result.s2MaxTorqueCurrent = ByteData.view(buffer).getInt16(14, Endian.little);
    result.s2MaxBrakeCurrent = ByteData.view(buffer).getInt16(16, Endian.little);
    result.s2MaxSpeed = ByteData.view(buffer).getInt16(18, Endian.little);
    result.s2MaxBatteryCurrent = ByteData.view(buffer).getInt16(20, Endian.little);
    result.s2MaxFieldWeakingCurrent = ByteData.view(buffer).getInt16(22, Endian.little);

    result.useCan = ByteData.view(buffer).getInt16(26, Endian.little) == 1;
    return result;
  }

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
    dataBuffer.setUint16(14, (settings.motorStatorResistance).toInt(), Endian.little);
    dataBuffer.setUint16(16, (settings.motorInductance).toInt(), Endian.little);
    dataBuffer.setUint16(18, (settings.motorFlux * 100000.0).toInt(), Endian.little);
    dataBuffer.setUint16(20, (settings.phaseCorrection * 1000.0).toInt(), Endian.little);
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
    result.phaseCorrection = ByteData.view(buffer).getInt16(20, Endian.little) / 1000.0;
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

  static Packet analogSettingsToPacket(AnalogSettings settings) {
    int command = 1;

    Uint8List data = Uint8List(PACKET_LENGTH);
    ByteData dataBuffer = data.buffer.asByteData();

    dataBuffer.setUint16(0, (settings.throttleMin * 1000).toInt(), Endian.little);
    dataBuffer.setUint16(2, (settings.throttleMax * 1000).toInt(), Endian.little);
    dataBuffer.setUint16(4, (settings.throttleCurveCoefficient1 * 2048).toInt(), Endian.little);
    dataBuffer.setUint16(6, (settings.throttleCurveCoefficient2 * 2048).toInt(), Endian.little);
    dataBuffer.setUint16(8, (settings.throttleCurveCoefficient3 * 2048).toInt(), Endian.little);
    dataBuffer.setUint16(10, (settings.brakeMin * 1000).toInt(), Endian.little);
    dataBuffer.setUint16(12, (settings.brakeMax * 1000).toInt(), Endian.little);
    dataBuffer.setUint16(14, (settings.brakeCurveCoefficient1 * 2048).toInt(), Endian.little);
    dataBuffer.setUint16(16, (settings.brakeCurveCoefficient2 * 2048).toInt(), Endian.little);
    dataBuffer.setUint16(18, (settings.brakeCurveCoefficient3 * 2048).toInt(), Endian.little);

    return Packet(AnalogTabBloc.SCREEN_NUMBER, command, data);
  }

  static AnalogSettings packetToAnalogSettings(Packet packet) {
    AnalogSettings result = AnalogSettings.zero();
    ByteBuffer buffer = packet.toBytes.sublist(SCREEN_NUM_AND_COMMAND_NUM_OFFSET).buffer;

    result.throttleMin = ByteData.view(buffer).getUint16(0, Endian.little) / 1000.0;
    result.throttleMax = ByteData.view(buffer).getUint16(2, Endian.little) / 1000.0;
    result.throttleCurveCoefficient1 = ByteData.view(buffer).getInt16(4, Endian.little) ~/ 2048.0;
    result.throttleCurveCoefficient2 = ByteData.view(buffer).getInt16(6, Endian.little) ~/ 2048.0;
    result.throttleCurveCoefficient3 = ByteData.view(buffer).getInt16(8, Endian.little) ~/ 2048.0;

    result.brakeMin = ByteData.view(buffer).getUint16(10, Endian.little) / 1000.0;
    result.brakeMax = ByteData.view(buffer).getUint16(12, Endian.little) / 1000.0;
    result.brakeCurveCoefficient1 = ByteData.view(buffer).getInt16(14, Endian.little) ~/ 2048.0;
    result.brakeCurveCoefficient2 = ByteData.view(buffer).getInt16(16, Endian.little) ~/ 2048.0;
    result.brakeCurveCoefficient3 = ByteData.view(buffer).getInt16(18, Endian.little) ~/ 2048.0;

    return result;
  }

  static Packet driveSettingsToPacket(DriveSettings settings) {
    int command = 1;

    Uint8List data = Uint8List(PACKET_LENGTH);
    ByteData dataBuffer = data.buffer.asByteData();

    dataBuffer.setUint16(0, settings.throttleUpSpeed, Endian.little);
    dataBuffer.setUint16(2, settings.throttleDownSpeed, Endian.little);
    dataBuffer.setUint16(4, settings.throttlePhaseCurrentMax, Endian.little);

    dataBuffer.setUint16(6, settings.brakeUpSpeed, Endian.little);
    dataBuffer.setUint16(8, settings.brakeDownSpeed, Endian.little);
    dataBuffer.setUint16(10, settings.brakePhaseCurrentMax, Endian.little);

    dataBuffer.setUint16(12, settings.discreetBrakeCurrentUpSpeed, Endian.little);
    dataBuffer.setUint16(14, settings.discreetBrakeCurrentDownSpeed, Endian.little);
    dataBuffer.setUint16(16, settings.discreetBrakeCurrentMax, Endian.little);

    dataBuffer.setUint16(18, settings.controlMode, Endian.little);
    dataBuffer.setUint16(20, settings.phaseWeakingCurrent, Endian.little);
    dataBuffer.setUint16(22, settings.pwmFrequency, Endian.little);
    dataBuffer.setUint16(24, settings.processorIdHigh, Endian.little);
    dataBuffer.setUint16(26, settings.processorIdLow, Endian.little);

    return Packet(DriveTabBloc.SCREEN_NUMBER, command, data);
  }

  static DriveSettings packetToDriveSettings(Packet packet) {
    DriveSettings result = DriveSettings.zero();
    ByteBuffer buffer = packet.toBytes.sublist(SCREEN_NUM_AND_COMMAND_NUM_OFFSET).buffer;

    result.throttleUpSpeed = ByteData.view(buffer).getUint16(0, Endian.little);
    result.throttleDownSpeed = ByteData.view(buffer).getUint16(2, Endian.little);
    result.throttlePhaseCurrentMax = ByteData.view(buffer).getUint16(4, Endian.little);

    result.brakeUpSpeed = ByteData.view(buffer).getUint16(6, Endian.little);
    result.brakeDownSpeed = ByteData.view(buffer).getUint16(8, Endian.little);
    result.brakePhaseCurrentMax = ByteData.view(buffer).getUint16(10, Endian.little);

    result.discreetBrakeCurrentUpSpeed = ByteData.view(buffer).getUint16(12, Endian.little);
    result.discreetBrakeCurrentDownSpeed = ByteData.view(buffer).getUint16(14, Endian.little);
    result.discreetBrakeCurrentMax = ByteData.view(buffer).getUint16(16, Endian.little);

    result.controlMode = ByteData.view(buffer).getUint16(18, Endian.little);
    result.phaseWeakingCurrent = ByteData.view(buffer).getInt16(20, Endian.little);
    result.pwmFrequency = ByteData.view(buffer).getUint16(22, Endian.little);
    result.processorIdHigh = ByteData.view(buffer).getUint16(24, Endian.little);
    result.processorIdLow = ByteData.view(buffer).getUint16(26, Endian.little);

    return result;
  }

  static RegSettings packetToRegSettings(Packet packet) {
    if (packet.cmd == 31) return null;  // todo remove division after firmware update.

    RegSettings result = RegSettings.zero();
    ByteBuffer buffer = packet.toBytes.sublist(SCREEN_NUM_AND_COMMAND_NUM_OFFSET).buffer;

    result.currentBandwidth = ByteData.view(buffer).getUint16(0, Endian.little);

    result.speedKp = ByteData.view(buffer).getUint16(2, Endian.little) ~/ 10000;
    result.speedKi = ByteData.view(buffer).getUint16(4, Endian.little) ~/ 10000;

    result.fieldWeakingKp = ByteData.view(buffer).getUint16(6, Endian.little) ~/ 10000;
    result.fieldWeakingKi = ByteData.view(buffer).getUint16(8, Endian.little) ~/ 10000;

    result.batteryCurrentKp = ByteData.view(buffer).getUint16(10, Endian.little) ~/ 10000;
    result.batteryCurrentKi = ByteData.view(buffer).getUint16(12, Endian.little) ~/ 10000;

    result.powerUpSpeed = ByteData.view(buffer).getUint16(14, Endian.little);
    result.motorCurrentLimitRange = ByteData.view(buffer).getUint16(16, Endian.little);

    return result;
  }

  static Packet regSettingsToPacket(RegSettings settings) {
    int command = 1;

    Uint8List data = Uint8List(PACKET_LENGTH);
    ByteData dataBuffer = data.buffer.asByteData();

    dataBuffer.setUint16(0, settings.currentBandwidth, Endian.little);

    dataBuffer.setUint16(2, settings.speedKp * 10000, Endian.little);
    dataBuffer.setUint16(4, settings.speedKi * 10000, Endian.little);

    dataBuffer.setUint16(6, settings.fieldWeakingKp * 10000, Endian.little);
    dataBuffer.setUint16(8, settings.fieldWeakingKi * 10000, Endian.little);

    dataBuffer.setUint16(10, settings.batteryCurrentKp * 10000, Endian.little);
    dataBuffer.setUint16(12, settings.batteryCurrentKi * 10000, Endian.little);

    dataBuffer.setUint16(14, settings.powerUpSpeed, Endian.little);
    dataBuffer.setUint16(16, settings.motorCurrentLimitRange, Endian.little);

    return Packet(RegTabBloc.SCREEN_NUMBER, command, data);
  }

  static SystemSettings packetToSystemSettings(Packet packet) {
    if (packet.cmd == 31) return null;  // todo remove division after firmware update.

    SystemSettings result = SystemSettings.zero();
    ByteBuffer buffer = packet.toBytes.sublist(SCREEN_NUM_AND_COMMAND_NUM_OFFSET).buffer;

    result.hall1 = ByteData.view(buffer).getUint16(0, Endian.little);
    result.hall2 = ByteData.view(buffer).getUint16(2, Endian.little);
    result.hall3 = ByteData.view(buffer).getUint16(4, Endian.little);
    result.hall4 = ByteData.view(buffer).getUint16(6, Endian.little);
    result.hall5 = ByteData.view(buffer).getUint16(8, Endian.little);
    result.hall6 = ByteData.view(buffer).getUint16(10, Endian.little);

    result.motorResistance = ByteData.view(buffer).getUint16(12, Endian.little) / 1000;
    result.motorInduction = ByteData.view(buffer).getUint16(14, Endian.little) / 1000000;
    result.motorMagnetStream = ByteData.view(buffer).getUint16(16, Endian.little) / 10000;
    result.identificationMode = ByteData.view(buffer).getUint16(18, Endian.little);
    result.identificationCurrent = ByteData.view(buffer).getUint16(20, Endian.little);

    return result;
  }

  static Packet systemSettingsToPacket(SystemSettings settings) {
    int command = 1;

    Uint8List data = Uint8List(PACKET_LENGTH);
    ByteData dataBuffer = data.buffer.asByteData();

    dataBuffer.setUint16(0, settings.identificationMode, Endian.little);
    dataBuffer.setUint16(2, settings.identificationCurrent, Endian.little);

    dataBuffer.setUint16(4, 0, Endian.little);
    dataBuffer.setUint16(6, 0, Endian.little);

    dataBuffer.setUint16(8, settings.hall1, Endian.little);
    dataBuffer.setUint16(10, settings.hall2, Endian.little);
    dataBuffer.setUint16(12, settings.hall3, Endian.little);
    dataBuffer.setUint16(14, settings.hall4, Endian.little);
    dataBuffer.setUint16(16, settings.hall5, Endian.little);
    dataBuffer.setUint16(18, settings.hall6, Endian.little);

    return Packet(SystemSettingsTabBloc.SCREEN_NUMBER, command, data);
  }
}
