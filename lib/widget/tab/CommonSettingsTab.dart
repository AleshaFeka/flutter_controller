import 'package:flutter/material.dart';
import 'package:flutter_controller/di/Provider.dart';


abstract class CommonSettingsTabState <TWidget extends StatefulWidget, TData> extends State<TWidget> {
  static const _parameterValueAccuracy = 3;
  static const _read = "read";
  static const _write = "write";
  static const _save = "save";
  static const emptyValue = "emptyValue";
  static const NOT_INTEGER_NUMBER = "notIntegerNumber";
  static const LESS_THAN_ZERO = "lessThanZero";
  static const NOT_NUMBER = "notANumber";
  static const WRITING_NOT_ALLOWED = "writingNotAllowed";

  Map localizedStrings;


  Widget buildRow(String parameterName, String value, String variableName);

  Stream<TData> getViewModelStream();

  Map getParameterNames();

  Map getParameterValues(AsyncSnapshot<TData> snapshot);

  GlobalKey getFormKey();

  Function(String, String) validateNotNullOrEmpty;

  void onRead();

  void onWrite();

  void onSave();

  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = Provider.of(context).localizedStrings;
    validateNotNullOrEmpty = (String value, String variableName) {
      if (value == null) {
        return localizedStrings[emptyValue];
      }
      if (value.isEmpty) {
        return localizedStrings[emptyValue];
      }

      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getViewModelStream(),
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

  Widget buildForm(Map parameterNames, Key key, AsyncSnapshot<TData> snapshot) {
    var parameterValues = getParameterValues(snapshot);

    List<Widget> children = List();
    children.add(Container(
      height: 8,
    ));
    parameterNames.entries.forEach((nameEntry) {
      String parameterValue = _extractParameterValueFromNum((parameterValues[nameEntry.key] as num));
      String parameterName = nameEntry.value;

      children.add(buildRow(parameterName, parameterValue, nameEntry.key));
      children.add(Divider(
        height: 1,
        color: Colors.grey,
      ));
    });

    return Form(key: key, child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: children));
  }

  String _extractParameterValueFromNum(num raw) {
    if (raw == null) return "";
    String parameterValue = raw.toStringAsFixed(_parameterValueAccuracy);
    if (raw.roundToDouble() == raw) {
      parameterValue = raw.toInt().toString();
    }
    return parameterValue;
  }
}