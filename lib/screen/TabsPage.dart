import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_controller/widget/tab/MonitorTab.dart';
import 'package:flutter_controller/widget/tab/MotorTab.dart';
import 'package:flutter_controller/widget/tab/MotorTabM.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:url_launcher/url_launcher.dart';

import 'SettingsPage.dart';
import '../common.dart';
import '../core/Packet.dart';

final tabNames = <int, String>{
  1: 'Monitor',
  2: 'Motor',
  3: 'Drive',
  4: 'Analog',
  5: 'Regs',
  6: 'SensorLess',
  7: 'Ident',
  8: 'Logs',
};

final tabIcons = <int, IconData>{
  1: Icons.computer,
  2: Icons.adjust,
  3: Icons.motorcycle,
  4: Icons.surround_sound,
  5: Icons.build,
  6: Icons.leak_remove,
  7: Icons.leak_add,
  8: Icons.short_text,
};

class TabsPage extends StatefulWidget {
  final BluetoothDevice server;

  const TabsPage({this.server});

  @override
  _TabsPage createState() => new _TabsPage();
}

class _TabsPage extends State<TabsPage> {
  BluetoothConnection connection;
  bool isConnecting = true;

  bool get isConnected => connection != null && connection.isConnected;
  bool isDisconnecting = false;

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  int _selectedChoice = 1; // Selected tab

  int byteCnt = 0; // received bytes counter
  Uint8List inBuffer = Uint8List(0);

  AppSettings settings = AppSettings.load();

  @override
  void initState() {
    super.initState();

    if (widget.server == null) return;

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });

//      final packet = Packet(0, 0, Uint8List(28));
//      print(Uint8List(28));
//      _sendMessage(packet);
//      _sendMessage(packet);
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  void _onDataReceived(Uint8List data) {
    print("Data received: ");
    print(data);

    // skip till 0x23, search for (0x23, 32 bytes, 0x2A)
    Uint8List buf = Uint8List.fromList(inBuffer.toList() + data.toList()); // old data + new data
    int pos = 0;
    while (buf.length >= pos + 34) {
      // enough bytes?
      if (buf[pos] == 0x23 && buf[pos + 33] == 0x2A) {
        Uint8List packetData = buf.sublist(pos + 1, pos + 33);
        Packet packet = Packet.fromBytes(packetData);
        if (packet.crcValid) {
          buf = buf.sublist(pos + 34);
          print("Packet received: ");
          print(packetData);
          pos = 0;
          continue;
        }
      }

      pos++;
    }

    inBuffer = buf;
  }

  void _sendMessage(Packet packet) async {
    try {
      final msg = Uint8List.fromList(<int>[0x23] + packet.toBytes + <int>[0x2A]);
      connection.output.add(msg);
      print("Sent");
      print(msg);
      await connection.output.allSent;

//        setState(() {
//          messages.add(_Message(clientID, text));
//        });

//        Future.delayed(Duration(milliseconds: 333)).then((_) {
//          listScrollController.animateTo(listScrollController.position.maxScrollExtent, duration: Duration(milliseconds: 333), curve: Curves.easeOut);
//        });
    } catch (e) {
      print("_sendMessage error");
      // Ignore error, but notify state
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final handleSettingsTap = () async {
      await Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SettingsPage()));
      setState(() {
        settings = AppSettings.load();
      });
    };

    const TextStyle linkStyle = const TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    );

    return Scaffold(
      appBar: AppBar(
        leading: PopupMenuButton<int>(
          onSelected: _select,
          itemBuilder: (BuildContext context) {
            return tabNames.keys.map((int num) {
              return PopupMenuItem<int>(
                value: num,
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: new EdgeInsets.only(right: 10),
                      child: Icon(tabIcons[num], size: 24, color: Colors.grey),
                    ),
                    Text(tabNames[num]),
                  ],
                ),
              );
            }).toList();
          },
        ),
        title: Text(tabNames[_selectedChoice]),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                  context: context,
                  applicationIcon: Icon(
                    Icons.memory,
                    size: 64,
                  ),
//                              applicationName: appName,
                  applicationVersion: appVersion,
                  applicationLegalese: "Sergey Averin <s@averin.ru>",
                  children: <Widget>[
                    Container(height: 12),
                    const Text(
                        "Программа для настройки и мониторинга параметров контроллера имени Булычева и Ермакова"),
                    Container(height: 12),
                    RichText(
                        text: TextSpan(
                      text: 'abc.com',
                      style: linkStyle,
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () async {
                          final url = 'https://github.com/flutter/gallery/';
                          if (await canLaunch(url)) {
                            await launch(
                              url,
                              forceSafariVC: false,
                            );
                          }
                        },
                    )),
                    Container(height: 12),
                    const Text("Прошивка контроллера: 0.1"),
                    const Text("Макс. фазный ток: 350А"),
                  ]);
            },
          ),
          // action button
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: handleSettingsTap,
          ),
        ],
      ),
      body: Container(
        child: (int num) {
          switch (num) {
            case 1:
              return MonitorTab(settings);
            case 2:
              return MotorTabM();
//            case 3: return DriveTab();
//            case 4: return AnalogTab();
//            case 5: return RegsTab();
//            case 6: return SensorLessTab();
//            case 7: return IdentTab();
//            case 8: return LogsTab();
            default:
              return Container();
          }
        }(_selectedChoice),
      ),
    );
  }

  void _select(int choice) {
    // Causes the app to rebuild with the new _selectedChoice.
    setState(() {
      _selectedChoice = choice;
    });
  }
}

class AppSettings {
  int param1, param2, param3, param4, param5;

  AppSettings.load() {
    this.param1 = Settings.getValue<int>('setting-monitor-param1', 1);
    this.param2 = Settings.getValue<int>('setting-monitor-param2', 2);
    this.param3 = Settings.getValue<int>('setting-monitor-param3', 3);
    this.param4 = Settings.getValue<int>('setting-monitor-param4', 4);
    this.param5 = Settings.getValue<int>('setting-monitor-param5', 5);
  }
}
