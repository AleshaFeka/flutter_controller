import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/Pair.dart';

enum ConnectPageDiscoveryCommand { START_DISCOVERY, STOP_DISCOVERY, GET_BONDED_DEVICES, CONNECT, DISCONNECT }
enum ConnectPageState { IDLE, DISCOVERING, CONNECTING }

class ConnectPageBloc {
  final BluetoothInteractor _interactor;
  FlutterBluetoothSerial _bluetooth;

  final List<BluetoothDiscoveryResult> _availableDevices = List<BluetoothDiscoveryResult>();

  StreamController<List<BluetoothDiscoveryResult>> _discoveryResultStreamController =
      StreamController<List<BluetoothDiscoveryResult>>.broadcast();
  Stream<List<BluetoothDiscoveryResult>> get discoveryResultStream => _discoveryResultStreamController.stream;

  StreamController<ConnectPageState> _connectStateStreamController =
      StreamController<ConnectPageState>.broadcast();
  Stream<ConnectPageState> get connectPageStateStream => _connectStateStreamController.stream;

  StreamController<ConnectPageDiscoveryCommand> _commandStreamController =
      StreamController<ConnectPageDiscoveryCommand>.broadcast();
  StreamSink<ConnectPageDiscoveryCommand> get commandStream => _commandStreamController.sink;

  StreamController<Pair<BluetoothDevice, ConnectPageDiscoveryCommand>> _userActionsStreamController =
      StreamController<Pair<BluetoothDevice, ConnectPageDiscoveryCommand>>.broadcast();
  StreamSink<Pair<BluetoothDevice, ConnectPageDiscoveryCommand>> get userActionsStream =>
      _userActionsStreamController.sink;

  ConnectPageBloc(this._interactor) {
    _bluetooth = _interactor.instance;
    _commandStreamController.stream.listen(_handleCommand);
    _userActionsStreamController.stream.listen(_handleUserAction);
  }
  
  void _handleUserAction(Pair<BluetoothDevice, ConnectPageDiscoveryCommand> action) async {
    switch (action.second) {
      case ConnectPageDiscoveryCommand.CONNECT : {
        print(action.first.name);
        print(action.second);
        await _interactor.connect(action.first.address);
        break;
      }
      case ConnectPageDiscoveryCommand.DISCONNECT : {
        print(action.first.name);
        print(action.second);
        await _interactor.disconnect();
        break;
      }
      default : break;
    }
  }

  void _handleCommand(ConnectPageDiscoveryCommand command) {
    switch (command) {
      case ConnectPageDiscoveryCommand.START_DISCOVERY:
        _startDiscovery();
        break;
      case ConnectPageDiscoveryCommand.STOP_DISCOVERY:
        _stopDiscovery();
        break;
      case ConnectPageDiscoveryCommand.GET_BONDED_DEVICES:
        _getBondedDevices();
        break;
      default : break;
    }
  }

  void _getBondedDevices() {
    _bluetooth.getBondedDevices().then((bondedDevice) => {
          bondedDevice.forEach((bondedDevice) {
            BluetoothDiscoveryResult result = BluetoothDiscoveryResult(device: bondedDevice);
            _availableDevices.add(result);
          })
        });
  }

  void _startDiscovery() {
    _connectStateStreamController.sink.add(ConnectPageState.DISCOVERING);
    _availableDevices.clear();
    _discoveryResultStreamController.sink.add(_availableDevices);

    _bluetooth.startDiscovery().listen((device) {
      bool alreadyDiscovered = false; //In case of unstable Bluetooth work. Some devices can be discovered not once
      _availableDevices.forEach((element) {
        if (element.device.name == device.device.name) {
          alreadyDiscovered = true;
        }
      });
      if (!alreadyDiscovered) {
        _availableDevices.add(device);
      }
      _discoveryResultStreamController.sink.add(_availableDevices);
    }).onDone(() {
      _connectStateStreamController.sink.add(ConnectPageState.IDLE);
    });
  }

  void _stopDiscovery() {
    _bluetooth.cancelDiscovery();
    _discoveryResultStreamController.sink.add(_availableDevices);
  }

  void dispose() {
    _connectStateStreamController.close();
    _userActionsStreamController.close();
    _discoveryResultStreamController.close();
    _commandStreamController.close();
  }
}
