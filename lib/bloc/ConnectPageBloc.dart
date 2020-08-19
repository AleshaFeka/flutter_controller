import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_controller/interactor/BluetoothInteractor.dart';
import 'package:flutter_controller/model/Pair.dart';

enum ConnectPageCommand { START_DISCOVERY, STOP_DISCOVERY, GET_BONDED_DEVICES, CONNECT, DISCONNECT, ENABLE_BLUETOOTH }
enum ConnectPageState { IDLE, DISCOVERING, CONNECTING, BLUETOOTH_DISABLED, BLUETOOTH_UNAVAILABLE }

class ConnectPageBloc {
  final BluetoothInteractor _interactor;
  FlutterBluetoothSerial _bluetooth;
  StreamSubscription<BluetoothDiscoveryResult> _discoverySubscription;

  final List<BluetoothDiscoveryResult> _availableDevices = List<BluetoothDiscoveryResult>();

  StreamController<List<BluetoothDiscoveryResult>> _discoveryResultStreamController =
  StreamController<List<BluetoothDiscoveryResult>>.broadcast();

  Stream<List<BluetoothDiscoveryResult>> get discoveryResultStream => _discoveryResultStreamController.stream;

  StreamController<ConnectPageState> _connectStateStreamController = StreamController<ConnectPageState>.broadcast();

  Stream<ConnectPageState> get connectPageStateStream => _connectStateStreamController.stream;

  StreamController<ConnectPageCommand> _commandStreamController =
  StreamController<ConnectPageCommand>.broadcast();

  StreamSink<ConnectPageCommand> get commandStream => _commandStreamController.sink;

  StreamController<Pair<BluetoothDiscoveryResult, ConnectPageCommand>> _userActionsStreamController =
  StreamController<Pair<BluetoothDiscoveryResult, ConnectPageCommand>>.broadcast();

  StreamSink<Pair<BluetoothDiscoveryResult, ConnectPageCommand>> get userActionsStream =>
    _userActionsStreamController.sink;

  ConnectPageBloc(this._interactor) {
    _bluetooth = _interactor.instance;
    _commandStreamController.stream.listen(_handleCommand);
    _userActionsStreamController.stream.listen(_handleUserAction);
  }

  void _handleUserAction(Pair<BluetoothDiscoveryResult, ConnectPageCommand> action) async {
    _stopDiscovery();
    _connectStateStreamController.sink.add(ConnectPageState.CONNECTING);
    switch (action.second) {
      case ConnectPageCommand.CONNECT:
        await _connect(action);
        break;
      case ConnectPageCommand.DISCONNECT:
        await _disconnect(action);
        break;
      default:
        break;
    }
    _connectStateStreamController.sink.add(ConnectPageState.IDLE);
  }

  Future _connect(Pair<BluetoothDiscoveryResult, ConnectPageCommand> action) async {
    return _interactor.connect(action.first.device.address).then((value) {
      _setConnectionStateAndReplaceItem(action.first, value);
    });
  }

  Future _disconnect(Pair<BluetoothDiscoveryResult, ConnectPageCommand> action) async {
    return _interactor.disconnect().then((value) {
      _setConnectionStateAndReplaceItem(action.first, false);
    });
  }

  void _setConnectionStateAndReplaceItem(BluetoothDiscoveryResult oldItem, bool isConnected) {
    var oldItemMap = oldItem.device.toMap();
    oldItemMap['isConnected'] = isConnected;
    BluetoothDiscoveryResult newItem = BluetoothDiscoveryResult(
      device: BluetoothDevice.fromMap(oldItemMap), rssi: oldItem.rssi);

    _addToAvailableDevices(newItem, replace: true);
  }

  void _handleCommand(ConnectPageCommand command) async {
    if (!_interactor.bluetoothState.isEnabled) {
      if (command ==  ConnectPageCommand.ENABLE_BLUETOOTH) {
        await _enableBluetooth();
        _startDiscovery();
      } else {
        _connectStateStreamController.sink.add(ConnectPageState.BLUETOOTH_DISABLED);
      }
      return;
    }

    switch (command) {
      case ConnectPageCommand.START_DISCOVERY:
        _startDiscovery();
        break;
      case ConnectPageCommand.STOP_DISCOVERY:
        _stopDiscovery();
        break;
      case ConnectPageCommand.GET_BONDED_DEVICES:
        _getBondedDevices();
        break;
      default:
        break;
    }
  }
  
  void _enableBluetooth() async {
    bool isEnabled = false;
    try {
      isEnabled = await _bluetooth.requestEnable();
    } catch (exc) {
      print(exc);
      _connectStateStreamController.sink.add(ConnectPageState.BLUETOOTH_UNAVAILABLE);
    }
    if (!isEnabled) {
      _connectStateStreamController.sink.add(ConnectPageState.BLUETOOTH_UNAVAILABLE);
    } else {
      _connectStateStreamController.sink.add(ConnectPageState.IDLE);
    }
  }

  void _getBondedDevices() {
    _bluetooth.getBondedDevices().then((bondedDevice) =>
    {
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

    _discoverySubscription?.cancel();
    _discoverySubscription = _bluetooth.startDiscovery().listen(_addToAvailableDevices)
      ..onDone(() {
        _connectStateStreamController.sink.add(ConnectPageState.IDLE);
      });
  }

  void _stopDiscovery() {
    _connectStateStreamController.sink.add(ConnectPageState.IDLE);
    _discoverySubscription?.cancel();
    _discoveryResultStreamController.sink.add(_availableDevices);
  }

  void _addToAvailableDevices(BluetoothDiscoveryResult result, {bool replace = false}) {
    bool alreadyDiscovered = false; //In case of unstable Bluetooth work. Some devices can be discovered more than once
    BluetoothDiscoveryResult toReplace;

    _availableDevices.forEach((element) {
      if (element.device.name == result.device.name) {
        alreadyDiscovered = true;
        toReplace = element;
      }
    });

    if (replace && toReplace != null) {
      _availableDevices.remove(toReplace);
      alreadyDiscovered = false;
    }

    if (!alreadyDiscovered) {
      _availableDevices.add(result);
    }
    _discoveryResultStreamController.sink.add(_availableDevices);
  }

  void dispose() {
    _connectStateStreamController.close();
    _userActionsStreamController.close();
    _discoveryResultStreamController.close();
    _commandStreamController.close();
  }
}
