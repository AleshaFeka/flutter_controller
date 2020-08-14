import 'package:flutter/material.dart';
import 'package:flutter_controller/bloc/MonitorTabBloc.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_controller/model/MonitorSettings.dart';
import 'package:google_fonts/google_fonts.dart';

class MonitorTab extends StatefulWidget {
  @override
  _MonitorTab createState() => new _MonitorTab();
}

class _MonitorTab extends State<MonitorTab> {
  static const _error = "error";
  static const _online = "online";
  static const _mode = "mode";

  MonitorTabBloc _monitorTabBloc;
  Map _localizedStrings;


  @override
  void dispose() {
    _monitorTabBloc.monitorSettingsCommandStream.add(MonitorTabCommand.STOP_MONITORING);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localizedStrings = Provider.of(context).localizedStrings;
    _monitorTabBloc = Provider.of(context).monitorTabBloc;
    _monitorTabBloc.monitorSettingsCommandStream.add(MonitorTabCommand.READ);
  }

  @override
  Widget build(BuildContext context) {
    _monitorTabBloc.monitorSettingsCommandStream.add(MonitorTabCommand.START_MONITORING);

    final large = GoogleFonts.oswald(textStyle: TextStyle(fontSize: 80));
    final small = GoogleFonts.oswald(textStyle: TextStyle(fontSize: 28));

    return StreamBuilder<MonitorTabSettingsData>(
        stream: _monitorTabBloc.monitorSettingsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return Container(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(snapshot.data.centerParam,
                    textAlign: TextAlign.center, style: large),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(
                          child: Column(children: <Widget>[
                        Text(snapshot.data.leftTop,
                            style: small),
                        Divider(),
                        Text(snapshot.data.leftBottom,
                            style: small),
                      ])),
                      Expanded(
                          child: Column(children: <Widget>[
                        Container(
                            padding: EdgeInsets.all(4),
                            color: Colors.green,
                            child:
                                Text(_localizedStrings[_error], style: small)),
                        Container(
                            padding: EdgeInsets.all(4),
                            color: Colors.green,
                            child:
                                Text(_localizedStrings[_online], style: small)),
                        Container(
                            padding: EdgeInsets.all(4),
                            color: Colors.green,
                            child:
                                Text(_localizedStrings[_mode], style: small)),
                      ])),
                      Expanded(
                          child: Column(children: <Widget>[
                        Text(snapshot.data.rightTop,
                            textAlign: TextAlign.center, style: small),
                        Divider(),
                        Text(snapshot.data.rightBottom,
                            style: small),
                      ])),
                    ]),
              ],
            ),
          );
        });
  }
}
