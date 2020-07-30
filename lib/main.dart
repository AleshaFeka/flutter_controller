import 'package:flutter/material.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:package_info/package_info.dart';

import 'interactor/BluetoothInteractor.dart';
import 'interactor/ResourceInteractor.dart';
import 'screen/MainPage.dart';
import 'common.dart';

init() async {
  await Settings.init(cacheProvider: SharePreferenceCache());
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  appName = packageInfo.appName;
  packageName = packageInfo.packageName;
  appVersion = packageInfo.version;
  buildNumber = packageInfo.buildNumber;
}

Future<void> main() async {
  await init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  BluetoothInteractor _bluetoothInteractor = BluetoothInteractor();
  ResourceInteractor _resourceInteractor = ResourceInteractor();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
      future: _resourceInteractor.init(context),
      builder: (context, snapshot) {
        Widget child;
        if (snapshot.hasError) {
          child = _buildErrorScreen(snapshot.error.toString());
        }
        else if (!snapshot.hasData) {
          child = _buildWaitingScreen();
        } else {
          child = _buildDoneScreen();
        }
        return Provider(
          _resourceInteractor,
          _bluetoothInteractor,
          child: child,
        );
      }
    );
  }

  Widget _buildErrorScreen(String message) {
    return MaterialApp(
      title: 'B&E controller app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: Column(
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
        ),
      )
    );
  }


  Widget _buildDoneScreen() {
    return MaterialApp(
      title: 'B&E controller app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(),
    );
  }

  Widget _buildWaitingScreen() {
    return MaterialApp(
      title: 'B&E controller app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.memory,
                size: 128,
              ),
              Container(height: 24,),
              CircularProgressIndicator(),
            ],
          ),
        )
      )
    );
  }
}
