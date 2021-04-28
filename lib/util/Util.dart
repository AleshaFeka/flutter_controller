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
      applicationLegalese: "B&E llc.",

      children: <Widget>[_buildAboutContent(context)]
  );
}

Widget _buildAboutContent(BuildContext context) {
  final localizedStrings = Provider.of(context).localizedStrings;
  return FutureBuilder<ControllerInfo>(
    future: _getControllerInfoFuture(Provider.of(context).bluetoothInteractor),
    builder: (ctx, snapshot) {
      if (snapshot.hasData) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(height: 12),
            Text(
              localizedStrings['appDescription'],
              textAlign: TextAlign.justify,),
            Container(height: 12),
            Container(height: 12),
            Text("${localizedStrings['firmwareVersion']} ${snapshot.data.firmwareDateBig}.${snapshot.data.firmwareDateLittle}", textAlign: TextAlign.center),
            Container(height: 12),
            Text("${localizedStrings['maxVoltage']} ${snapshot.data.controllerMaxVoltage}V"),
            Text("${localizedStrings['maxPhaseCurrent']} ${snapshot.data.controllerMaxCurrent}А"),
            Container(height: 12),
            Text("${localizedStrings['processor']} ${snapshot.data.processorIdBig}.${snapshot.data.processorIdLittle}"),
          ],
        );
      } else {
        return Center(child: CircularProgressIndicator());
      }
    });
}

Future<ControllerInfo> _getControllerInfoFuture(BluetoothInteractor interactor) {
  Completer<ControllerInfo> completer = Completer();

  interactor.sendMessage(Mapper.buildControllerInfoPacket());
  interactor.startListenSerial((packet) {
    if (packet.screenNum == Mapper.INFO_SCREEN_NUMBER) {
      ControllerInfo controllerInfo = Mapper.packetToControllerInfo(packet);
      completer.complete(controllerInfo);
    }
  });

//  completer.complete(ControllerInfo.zero());

  return completer.future;
}
