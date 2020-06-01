import 'package:flutter/material.dart';

class MotorTab extends StatefulWidget {
  @override
  _MotorTab createState() => new _MotorTab();
}

class _MotorTab extends State<MotorTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return SingleChildScrollView(
            child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraint.maxHeight),
          child: IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.all(12),
              child: Column(
                children: <Widget>[
                  Row(children: <Widget>[
                    Expanded(child: const Text("Param 1", style: TextStyle(fontSize: 20),)),
                    Expanded(child: TextField(enabled: false, decoration: new InputDecoration(hintText: "I am the TextField"))),
                  ]),
                  Row(children: <Widget>[
                    Expanded(child: const Text("Param 2")),
//                    Expanded(child: TextField(decoration: new InputDecoration(hintText: "I am the TextField"))),
                  ]),
                  Row(children: <Widget>[
                    Expanded(child: const Text("Param 3")),
//                    Expanded(child: TextField(decoration: new InputDecoration(hintText: "I am the TextField"))),
                  ]),
                  Row(children: <Widget>[
                    Expanded(child: const Text("Param 4")),
//                    Expanded(child: TextField(decoration: new InputDecoration(hintText: "I am the TextField"))),
                  ]),
                  Row(children: <Widget>[
                    Expanded(child: const Text("Param 5")),
//                    Expanded(child: TextField(decoration: new InputDecoration(hintText: "I am the TextField"))),
                  ]),
                  Row(children: <Widget>[
                    Expanded(child: const Text("Param 6")),
//                    Expanded(child: TextField(decoration: new InputDecoration(hintText: "I am the TextField"))),
                  ]),
                  Container(
                    height: 700,
                    color: Colors.blue,
                  ),
//                  Container(
//                    height: 700,
//                    color: Colors.blue,
//                  ),
//                  Flexible(
//                    fit: FlexFit.loose,
//                    child: Container(),
//                  ),
                  Spacer(),
//                  Expanded(child: Container()),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                    RaisedButton(
                      child: const Text("Read"),
                      onPressed: null,
                    ),
                    RaisedButton(
                      child: const Text("Write"),
                      onPressed: null,
                    ),
                    RaisedButton(
                      child: const Text("Save"),
                      onPressed: null,
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ));
      },
    );
  }
}
