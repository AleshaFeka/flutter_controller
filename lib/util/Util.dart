import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common.dart';

void showAbout(BuildContext context) {
  const TextStyle linkStyle = const TextStyle(
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );

  showAboutDialog(
    context: context,
    applicationIcon: Icon(
      Icons.memory,
      size: 64,
    ),
    //                              applicationName: appName,
    applicationVersion: appVersion,
    applicationLegalese: "Sergey Averin <s@averin.ru>",
    children: <Widget>[
      Container(height: 12),
      const Text(
        "Программа для настройки и мониторинга параметров контроллера имени Булычева и Ермакова"),
      Container(height: 12),
      RichText(
        text: TextSpan(
          text: 'abc.com',
          style: linkStyle,
          recognizer: new TapGestureRecognizer()
            ..onTap = () async {
              final url = 'https://github.com/flutter/gallery/';
              if (await canLaunch(url)) {
                await launch(
                  url,
                  forceSafariVC: false,
                );
              }
            },
        )),
      Container(height: 12),
      const Text("Прошивка контроллера: 0.1"),
      const Text("Макс. фазный ток: 350А"),
    ]);
}
