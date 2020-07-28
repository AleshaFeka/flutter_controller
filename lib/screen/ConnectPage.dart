import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_controller/screen/TabsPage.dart';

import '../widget/BluetoothDeviceListEntry.dart';

class ConnectPage extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not avaliable, they would be disabled from the selection.
  final bool checkAvailability;

  const ConnectPage({this.checkAvailability = true});

  @override
  _ConnectPage createState() => new _ConnectPage();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability extends BluetoothDevice {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class _ConnectPage extends State<ConnectPage> {
  List<_DeviceWithAvailability> devices = List<_DeviceWithAvailability>();

  // Availability
  StreamSubscription<BluetoothDiscoveryResult> _discoveryStreamSubscription;
  bool _isDiscovering;

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  _ConnectPage();

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _isDiscovering = widget.checkAvailability;
    if (_isDiscovering) {
      _startDiscovery();
    }

    // Setup a list of the bonded devices
    FlutterBluetoothSerial.instance.getBondedDevices().then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map((device) => _DeviceWithAvailability(
                device, widget.checkAvailability ? _DeviceAvailability.maybe : _DeviceAvailability.yes))
            .toList();
      });
    });
  }

  void _restartDiscovery() {
    setState(() {
      _isDiscovering = true;
    });

    _startDiscovery();
  }

  void addDiscoveredDevice(BluetoothDiscoveryResult r) {
    setState(() {
      Iterator i = devices.iterator;
      while (i.moveNext()) {
        _DeviceWithAvailability _device = i.current;
        if (_device.device == r.device) {
          _device.availability = _DeviceAvailability.yes;
          _device.rssi = r.rssi;
          return;
        }
      }

      devices.add(_DeviceWithAvailability(r.device, _DeviceAvailability.yes, r.rssi));
    });
  }

  void _startDiscovery() {
    devices = List<_DeviceWithAvailability>();

    _discoveryStreamSubscription = FlutterBluetoothSerial.instance.startDiscovery().listen(addDiscoveredDevice);

    _discoveryStreamSubscription.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _discoveryStreamSubscription?.cancel();

    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  Widget listViewItemBuilder(BuildContext context, int index) {
    if (index == 0) {
      return SwitchListTile(
        title: Text('Bluetooth is ' + (_bluetoothState.isEnabled ? 'ON' : 'OFF')),
        value: _bluetoothState.isEnabled,
        onChanged: (bool value) {
          // Do the request and update with the true value then
          future() async {
            // async lambda seems to not working
            if (value)
              await FlutterBluetoothSerial.instance.requestEnable();
            else
              await FlutterBluetoothSerial.instance.requestDisable();
          }

          future().then((_) {
            setState(() {});
          });
        },
      );
    }

    final _device = devices[index - 1];
    final Decoration decoration = BoxDecoration(
      border: Border(
        top: Divider.createBorderSide(context),
      ),
    );
    final tile = BluetoothDeviceListEntry(
      device: _device.device,
      rssi: _device.rssi,
      enabled: _device.availability == _DeviceAvailability.yes,
      onTap: () {
        _connectTo(context, _device.device);
      },
      onLongPress: null,
    );
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: decoration,
      child: tile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select bluetooth device"),
        actions: <Widget>[
          (_isDiscovering
              ? FittedBox(
                  child: Container(
                      margin: new EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))))
              : IconButton(icon: Icon(Icons.replay), onPressed: _restartDiscovery)),
          // action button
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {},
          ),
//          // action button
//          IconButton(
//            icon: Icon(Icons.settings),
//            onPressed: () {},
//          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child:
            ListView.builder(
          itemCount: devices.length + 1,
          itemBuilder: listViewItemBuilder,
        ),
      ),
    );
  }

  void _connectTo(BuildContext context, BluetoothDevice server) async {
    if (server.bondState.isBonded) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return TabsPage(server: server);
      }));
    } else {
      try {
        print('Bonding with ${server.address}...');
        final bonded = await FlutterBluetoothSerial.instance.bondDeviceAtAddress(server.address);
        print('Bonding with ${server.address} has ${bonded ? 'succed' : 'failed'}.');

        // TODO:
//        setState(() {
//          Iterator i = devices.iterator;
//          while (i.moveNext()) {
//            _DeviceWithAvailability _device = i.current;
//            if (_device.device == server) {
//              _device.availability = _DeviceAvailability.yes;
//              _device.bondState = bonded ? BluetoothBondState.bonded : BluetoothBondState.none;
//              return;
//            }
//          }
//
//          results[result.device.address] = BluetoothDiscoveryResult(
//              device: BluetoothDevice(
//                name: result.device.name,
//                address: result.device.address,
//                type: result.device.type,
//                bondState: bonded ? BluetoothBondState.bonded : BluetoothBondState.none,
//                ),
//              rssi: result.rssi);
//        });

        if (bonded) { //TODO: duplicate code
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return TabsPage(server: server);
          }));
        }
      } catch (ex) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error occured while bonding'),
              content: Text("${ex.toString()}"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }
}
