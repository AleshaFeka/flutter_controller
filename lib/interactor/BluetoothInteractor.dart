import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_controller/model/MotorSettings.dart';

class BluetoothInteractor {
  FlutterBluetoothSerial instance = FlutterBluetoothSerial.instance;
  bool isConnected = false;
  BluetoothConnection connection;
  BluetoothState bluetoothState = BluetoothState.UNKNOWN;

  BluetoothInteractor() {
    _initState();

    instance
      .onStateChanged()
      .listen((BluetoothState state) {
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

/*

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



    void _onDataReceived(Uint8List data) {
    print("Data received: ");
    print(data);

    // skip till 0x23, search for (0x23, 32 bytes, 0x2A)
    Uint8List buf = Uint8List.fromList(
        inBuffer.toList() + data.toList()); // old data + new data
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
      final msg =
          Uint8List.fromList(<int>[0x23] + packet.toBytes + <int>[0x2A]);
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

*/
}