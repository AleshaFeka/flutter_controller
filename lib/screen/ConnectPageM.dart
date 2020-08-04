import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_controller/bloc/ConnectPageBloc.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_controller/model/Pair.dart';

class ConnectPageM extends StatefulWidget {
  @override
  _ConnectPageM createState() => _ConnectPageM();
}

class _ConnectPageM extends State<ConnectPageM> {
  static const _logoAssetPath = "assets/images/logo.png";

  ConnectPageBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = Provider.of(context).connectPageBloc;
  }

  @override
  Widget build(BuildContext context) {
    _bloc.commandStream.add(ConnectPageDiscoveryCommand.START_DISCOVERY);

    return StreamBuilder<List<BluetoothDiscoveryResult>>(
        stream: _bloc.discoveryResultStream,
        builder: (context, snapshot) {
          Widget child;
          if (snapshot.hasError) {
            child = _buildError(snapshot.error.toString());
          } else {
            if (!snapshot.hasData) {
              child = _buildWaiting();
            } else {
              child = _buildContent(snapshot.data);
            }
          }

          return Scaffold(
              appBar: AppBar(
                title: Text("Устройства"),
                actions: [
                  IconButton(
                      icon: Icon(Icons.replay),
                      onPressed: () {
                        _bloc.commandStream.add(ConnectPageDiscoveryCommand.START_DISCOVERY);
                      })
                ],
              ),
              body: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(_logoAssetPath),
                          fit: BoxFit.fitWidth,
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop))),
                  child: child));
        });
  }

  Widget _buildItem(BluetoothDiscoveryResult discoveryResult) {
    var device = discoveryResult.device;
    int rssi = discoveryResult.rssi;

    return ListTile(
      onTap: () {
        _onItemClick(device);
      },
      onLongPress: () {
        _onItemLongClick(device);
      },
      enabled: true,
      leading: Icon(Icons.devices),
      // @TODO . !BluetoothClass! class aware icon
      title: Text(device.name ?? "Unknown device"),
      subtitle: Text(device.address.toString()),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          rssi != null
              ? Container(
                  margin: new EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(rssi.toString()),
                      Text('dBm'),
                    ],
                  ),
                )
              : Container(width: 0, height: 0),
          device.isConnected ? Icon(Icons.import_export) : Container(width: 0, height: 0),
          device.isBonded ? Icon(Icons.link) : Container(width: 0, height: 0),
        ],
      ),
    );
  }

  void _onItemClick(BluetoothDevice device) {
    _bloc.userActionsStream.add(Pair(device, ConnectPageDiscoveryCommand.CONNECT));
  }

  void _onItemLongClick(BluetoothDevice device) {
    _bloc.userActionsStream.add(Pair(device, ConnectPageDiscoveryCommand.DISCONNECT));
  }

  Widget _buildContent(List<BluetoothDiscoveryResult> discoveryResults) {
    var items = List<Widget>();
    for (BluetoothDiscoveryResult discoveryResult in discoveryResults) {
      items.add(_buildItem(discoveryResult));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: items,
    );
  }

  Widget _buildWaiting() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 24,
          ),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Icon(
            Icons.error,
            size: 64,
            color: Colors.red,
          ),
        ),
        Container(
          height: 16,
        ),
        Text(message)
      ],
    );
  }
}
