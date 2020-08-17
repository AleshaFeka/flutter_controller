import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_controller/core/LiveData.dart';
import 'package:flutter_controller/core/Packet.dart';
import 'package:flutter_controller/model/MotorSettings.dart';

class BluetoothInteractor {
  FlutterBluetoothSerial instance = FlutterBluetoothSerial.instance;

  bool isConnected = false;
  BluetoothConnection connection;
  BluetoothState bluetoothState = BluetoothState.UNKNOWN;

  Stream<Uint8List> _connectionStream;
  StreamSubscription<Uint8List> _subscription;
  StreamController<Uint8List> _streamController = StreamController<Uint8List>.broadcast();

  Stream<Uint8List> get fromBtConnectionStream => _streamController.stream;

  Uint8List _inBuffer = Uint8List(0);

  BluetoothInteractor() {
    _initState();

    instance.onStateChanged().listen((BluetoothState state) {
      bluetoothState = state;
    });
  }

  void _initState() async {
    bluetoothState = await instance.state;
  }

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

  Future<bool> connect(String address) async {
    print('Connected to the device...');
    await BluetoothConnection.toAddress(address).then((value) {
      connection = value;
      isConnected = true;

//      _streamController = StreamController<Uint8List>.broadcast();

      _connectionStream = connection.input.asBroadcastStream();
      _subscription = _connectionStream.listen((event) {
        _streamController.sink.add(event);
      })
        ..onDone(() { 
          print("onDone");
          _streamController.sink.addError(Exception("Connection closed."));
        })
        ..onError((e) { 
          print("Error - $e");
          _streamController.sink.addError(e);
        });
    }).catchError((error) {
      isConnected = false;
      _onError(error.toString());
    });
    print('BluetoothInteractor. isConnected - $isConnected');

    return isConnected;
  }

  Future<void> disconnect() async {
    connection?.close();
  }

  void _onError(String error) {
    print("Error - $error");
  }

  void _onDataReceived(Uint8List data, Function(Packet) packetHandler) {
    print("Data received: ");
    print(data);

    // skip till 0x23, search for (0x23, 32 bytes, 0x2A)
    Uint8List buf = Uint8List.fromList(_inBuffer.toList() + data.toList()); // old data + new data
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

          packetHandler(packet);

          pos = 0;
          continue;
        }
      }

      pos++;
    }

    _inBuffer = buf;
  }

  void sendMessage(Packet packet) async {
    try {
      final msg = Uint8List.fromList(<int>[0x23] + packet.toBytes + <int>[0x2A]);
      connection.output.add(msg);
      print("Sent");
      print(msg);
      await connection.output.allSent;
    } catch (e) {
      print("_sendMessage error - ${e.toString()}");
    }
  }

  void stopMonitoring() {
    _subscription.cancel();
  }

  void startMonitoring(Function(Packet) packetHandler) {
    _subscription = _streamController.stream.listen((event) {
      _onDataReceived(event, packetHandler);
    })
      ..onDone(() {
        print('Disconnected');
      })
      ..onError((e) {
        print('Error! - $e');
      }); //todo add handling
  }
}
