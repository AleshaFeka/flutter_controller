import 'package:flutter/material.dart';

class TitledCard extends StatelessWidget {
  final Widget child;
  final String title;
  final double elevation;

  TitledCard({this.title, this.child, this.elevation = 0.5});

  @override
  Widget build(BuildContext context) {
    final cardTitle = Align(
      alignment: Alignment(-0.9, 0),
      child: Text(
        title,
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ));

    return Card(
      elevation: elevation,
      child: Column(
        children: [
          Align(alignment: Alignment(-0.9, 0), child: cardTitle),
          child,
        ],
      ),
    );
  }
}
