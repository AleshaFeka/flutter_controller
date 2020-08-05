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
  static const _controllerNameStarts = "ws-";

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
        initialData: [],
        builder: (context, snapshot) {
          return StreamBuilder<ConnectPageState>(
              stream: _bloc.connectPageStateStream,
              initialData: ConnectPageState.IDLE,
              builder: (context, stateSnapshot) {
                String title;
                if (stateSnapshot.data == ConnectPageState.IDLE) {
                  title = "Доступные устройства";
                } else {
                  title = stateSnapshot.data == ConnectPageState.DISCOVERING ? "Поиск..." : "Соединение...";
                }

                IconData actionIcon = stateSnapshot.data == ConnectPageState.IDLE ? Icons.replay : Icons.cancel;
                void Function() actionOnPressed = stateSnapshot.data == ConnectPageState.IDLE
                    ? () {
                        _bloc.commandStream.add(ConnectPageDiscoveryCommand.START_DISCOVERY);
                      }
                    : () {
                        _bloc.commandStream.add(ConnectPageDiscoveryCommand.STOP_DISCOVERY);
                      };

                Widget child;
                if (snapshot.hasError) {
                  child = _buildError(snapshot.error.toString());
                } else {
                  if (!snapshot.hasData) {
                    child = _buildWaiting();
                  } else {
                    child = _buildContent(snapshot.data, stateSnapshot.data);
                  }
                }

                return Scaffold(
                    appBar: AppBar(
                      title: Text(title),
                      actions: [
                        IconButton(icon: Icon(actionIcon), onPressed: actionOnPressed),
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
        });
  }

  Widget _buildItem(BluetoothDiscoveryResult discoveryResult) {
    var device = discoveryResult.device;
    int rssi = discoveryResult.rssi;

    var fontSize = device.isConnected ? 18.0 : 16.0;
    var color = device.isConnected ? Colors.green : device.name.startsWith(_controllerNameStarts) ? Colors.black : Colors.grey;

    return ListTile(
      onTap: () {
        _onItemClick(discoveryResult);
      },
      onLongPress: () {
        _onItemLongClick(discoveryResult);
      },
      enabled: true,
      leading: Icon(
        device.name.startsWith(_controllerNameStarts) ? Icons.memory : Icons.devices,
        color: device.isConnected ? Colors.green : device.name.startsWith(_controllerNameStarts) ? Colors.blueAccent : IconTheme.of(context).color,
      ),
      title: Text(
        device.name ?? "Unknown device",
        style: TextStyle(fontSize: fontSize, color: color),
      ),
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
          device.isConnected
              ? Icon(
                  Icons.import_export,
                  color: Colors.green,
                )
              : Container(width: 0, height: 0),
          device.isBonded ? Icon(Icons.link) : Container(width: 0, height: 0),
        ],
      ),
    );
  }

  void _onItemClick(BluetoothDiscoveryResult device) {
    _bloc.userActionsStream.add(Pair(device, ConnectPageDiscoveryCommand.CONNECT));
  }

  void _onItemLongClick(BluetoothDiscoveryResult device) {
    _bloc.userActionsStream.add(Pair(device, ConnectPageDiscoveryCommand.DISCONNECT));
  }

  Widget _buildContent(List<BluetoothDiscoveryResult> discoveryResults, ConnectPageState state) {
    var items = List<Widget>();
    for (BluetoothDiscoveryResult discoveryResult in discoveryResults) {
      items.add(_buildItem(discoveryResult));
    }
    if (state == ConnectPageState.DISCOVERING) {
      items.add(ListTile(
        enabled: true,
        title: Center(child: CircularProgressIndicator()),
      ));
    }

    return Stack(children: [
      state == ConnectPageState.CONNECTING ? Center(child: CircularProgressIndicator()) : Container(),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: items,
      ),
    ]);
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
