import 'package:flutter/material.dart';
import 'package:flutter_controller/di/Provider.dart';


abstract class CommonSettingsTabState <TWidget extends StatefulWidget, TData> extends State<TWidget> {
  static const _read = "read";
  static const _write = "write";
  static const _save = "save";

  Map localizedStrings;

  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = Provider.of(context).localizedStrings;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getTypedStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return buildError(snapshot.error.toString());
        }

        return ListView(children: [buildForm(getParameterNames(), getFormKey(), snapshot), buildBottomButtons()]);
      },
    );
  }

  Widget buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          RaisedButton(
            child: Text(localizedStrings[_read]),
            onPressed: () {
              onRead();
            },
          ),
          Expanded(
            child: Container(),
          ),
          RaisedButton(
            onPressed: () {
              onWrite();
            },
            child: Text(localizedStrings[_write]),
          ),
          Expanded(child: Container()),
          RaisedButton(
            onPressed: () {
              onSave();
            },
            child: Text(localizedStrings[_save]),
          ),
        ],
      ),
    );
  }


  Widget buildError(String message) {
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

  Widget buildForm(Map parameterNames, Key key, AsyncSnapshot<TData> snapshot);

  Stream<TData> getTypedStream();

  Map getParameterNames();

  GlobalKey getFormKey();

  void onRead();

  void onWrite();

  void onSave();
}