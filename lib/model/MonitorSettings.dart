import 'package:flutter_controller/core/LiveData.dart';
import 'package:flutter_controller/model/Parameter.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class MonitorTabSettings {
  static const centerTopParameter = "centerTopParameter";
  static const leftTopParameter = "leftTopParameter";
  static const leftBottomParameter = "leftBottomParameter";
  static const rightTopParameter = "rightTopParameter";
  static const rightBottomParameter = "rightBottomParameter";

  int centerParam;
  int leftTop;
  int leftBottom;
  int rightTop;
  int rightBottom;

  MonitorTabSettings.load() {
    this.centerParam = Settings.getValue<int>(centerTopParameter, 1);
    this.leftTop = Settings.getValue<int>(leftTopParameter, 2);
    this.leftBottom = Settings.getValue<int>(leftBottomParameter, 3);
    this.rightTop = Settings.getValue<int>(rightTopParameter, 4);
    this.rightBottom = Settings.getValue<int>(rightBottomParameter, 5);
//    print("centerParam - $centerParam.  leftTop - $leftTop.  leftBottom - $leftBottom.  rightTop - $rightTop.  rightBottom - $rightBottom.  ");
  }
}

class MonitorTabSettingsData {
  String centerParam;
  String leftTop;
  String leftBottom;
  String rightTop;
  String rightBottom;

  MonitorTabSettingsData.build(LiveData liveData, MonitorTabSettings values) {
    centerParam = liveData.getParameter(values.centerParam);
    leftTop = liveData.getParameter(values.leftTop);
    leftBottom = liveData.getParameter(values.leftBottom);
    rightTop = liveData.getParameter(values.rightTop);
    rightBottom = liveData.getParameter(values.rightBottom);
  }
}