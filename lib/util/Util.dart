import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/ControllerInfo.dart';
import 'package:flutter_controller/util/Mapper.dart';

import '../common.dart';

void showAbout(BuildContext context) {
  showAboutDialog(
      context: context,
      applicationIcon: Icon(
        Icons.memory,
        size: 64,
      ),
      applicationVersion: appVersion,
      applicationLegalese: "Sergey Averin <s@averin.ru>",

      children: <Widget>[_buildAboutContent(context)]
  );
}

Widget _buildAboutContent(BuildContext context) => FutureBuilder<ControllerInfo>(
    future: _getControllerInfoFuture(Provider.of(context).bluetoothInteractor),
    builder: (ctx, snapshot) {
      if (snapshot.hasData) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(height: 12),
            const Text(
              "Программа для настройки и мониторинга параметров контроллера имени Булычева и Ермакова",
              textAlign: TextAlign.justify,),
            Container(height: 12),
            Container(height: 12),
            Text("Прошивка контроллера: ${snapshot.data.firmwareDateBig}.${snapshot.data.firmwareDateLittle}"),
            Container(height: 12),
            Text("Макс. напряжение: ${snapshot.data.controllerMaxVoltage}V"),
            Text("Макс. фазный ток: ${snapshot.data.controllerMaxCurrent}А"),
            Container(height: 12),
            Text("Процессор: ${snapshot.data.processorIdBig}.${snapshot.data.processorIdLittle}"),
          ],
        );
      } else {
        return Center(child: CircularProgressIndicator());
      }
    });

Future<ControllerInfo> _getControllerInfoFuture(BluetoothInteractor interactor) {
  Completer<ControllerInfo> completer = Completer();

  interactor.sendMessage(Mapper.buildControllerInfoPacket());
  interactor.startListenSerial((packet) {
    if (packet.screenNum == Mapper.INFO_SCREEN_NUMBER) {
      ControllerInfo controllerInfo = Mapper.packetToControllerInfo(packet);
      print(controllerInfo.controllerMaxVoltage);
      completer.complete(controllerInfo);
    }
  });

//  completer.complete(ControllerInfo.zero());

  return completer.future;
}
