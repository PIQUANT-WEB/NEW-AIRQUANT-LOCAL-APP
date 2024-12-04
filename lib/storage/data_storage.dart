
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:airquant_monitor_local/widgets/alert_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utilities/socket_timer.dart';

class DataStorage extends ChangeNotifier {
  // ip, port (24.04.18 정아 추가)
  late String _ip;
  late int _port;

  String get ip => _ip;
  int get port => _port;

  void setIp(String ip) {
    _ip = ip;
    print('ip $ip');
    notifyListeners();
  }

  void setPort(int port) {
    _port = port;
    print('port $port');
    notifyListeners();
  }

  String SN = "";
  String MAC = "";
  double PM010 = 0.0;
  double PM025 = 0.0;
  double PM040 = 0.0;
  double PM100 = 0.0;
  double CO2 = 0.0;
  double TEMPE = 0.0;
  double HUMID = 0.0;
  double TVOC = 0;
  double SO2 = 0;
  double NO2 = 0;
  double CO = 0;
  double SOUND = 0;
  double LIGHT = 0;

  String Date = "";           // 기기에서 데이터가 들어온 시간(엑셀 및 갱신주기)
  String currentDate = '';    // 현재 시간(년월일)
  String currentTime = "";    // 현재 시간(시분초)

  List<Map<String, dynamic>>? cardData = [];  // 카드 데이터
  late String overallState;                   // 전체 공기질 상태

  bool loading = true;               // 로딩중

  List<String>? displayItems = [];                        // 표시할 6개의 공기질 항목
  List<Map<String, List<String>>> infoDisplayItems = [];  // displayItems의 항목 및 기준들

  int createExcelIndex = 0;   // 엑셀 저장할 시간 카운트(5분)

  Timer? timer;         // 소켓 타이머
  Timer? currentTimer;  // 현재 시간 타이머

  bool checkCycle = false;  // 데이터 갱신 주기 변경 했는지 위함

  // 엑셀 데이터
  get keys => ['Date', 'PM025', 'PM100', 'CO2', 'TVOC', 'HUMID', 'TEMPE',
    'PM040', 'PM010', 'SO2', 'NO2', 'CO', 'SOUND', 'LIGHT'];
  get values => [Date, PM025, PM100, CO2, TVOC, HUMID, TEMPE,
    PM040, PM010, SO2, NO2, CO, SOUND, LIGHT];

  // '[]' 연산자를 추가
  dynamic operator [](String key) {
    switch (key) {
      case "SN":
        return SN;
      case "MAC":
        return MAC;
      case "PM010":
        return PM010;
      case "PM025":
        return PM025;
      case "PM040":
        return PM040;
      case "PM100":
        return PM100;
      case "CO2":
        return CO2;
      case "TEMPE":
        return TEMPE;
      case "HUMID":
        return HUMID;
      case "TVOC":
        return TVOC;
      case "SO2":
        return SO2;
      case "NO2":
        return NO2;
      case "CO":
        return CO;
      case "SOUND":
        return SOUND;
      case "LIGHT":
        return LIGHT;
      default:
        throw Exception("Invalid key: $key");
    }
  }

  static void setValue(String key, dynamic value, DataStorage dataStorage) {
    switch (key) {
      case "SN" :
        dataStorage.SN = value;
        break;
      case "MAC" :
        dataStorage.MAC = value;
        break;
      case "PM010":
        dataStorage.PM010 = value;
        break;
      case "PM025":
        dataStorage.PM025 = value;
        break;
      case "PM040":
        dataStorage.PM040 = value;
        break;
      case "PM100":
        dataStorage.PM100 = value;
        break;
      case "CO2":
        dataStorage.CO2 = value;
        break;
      case "TEMPE":
        dataStorage.TEMPE = value;
        break;
      case "HUMID":
        dataStorage.HUMID = value;
        break;
      case "TVOC":
        dataStorage.TVOC = value;
        break;
      case "SO2":
        dataStorage.SO2 = value;
        break;
      case "NO2":
        dataStorage.NO2 = value;
        break;
      case "CO":
        dataStorage.CO = value;
        break;
      case "SOUND":
        dataStorage.SOUND = value;
        break;
      case "LIGHT":
        dataStorage.LIGHT = value;
        break;
    }
  }

  // 기기에서 넘어오는 데이터 업데이트
  static void saveDataToStorage(dynamic data, DataStorage dataStorage, BuildContext context) {
    // 소켓 및 타이머 클래스 연결
    SocketTimer socketTimer = SocketTimer();
    DateTime now = DateTime.now();
    dataStorage.Date = DateFormat('yyyy/MM/dd HH:mm:ss').format(now);

    try {
      /// 이더넷 data
      if (data is String) {
        Map<String, dynamic> dataMap = jsonDecode(data);
        for (var entry in dataMap.entries) {
          dynamic value;
          value = entry.value;
          if (entry.value is double) {
            value = (entry.value * 100).round() / 100.0;
          }
          setValue(entry.key, value, dataStorage);
        }
        return;
      }

      /// softAP data
      for (var i = 0; i < data.length; i += 2) {
        if(i + 1 < data.length) {
          final key = data[i];
          dynamic value;
          if(data[i] == "SN" || data[i] == "MAC") { // SN과 MAC일 때만
            value = data[i + 1];
          }else {
            value = (double.parse(data[i + 1]) * 100).round() / 100.0;
          }
          setValue(key, value, dataStorage);
        }
      }
    } catch (error) {
        print("=== save data error : $error");
        socketTimer.cancelTimer(context);
        socketTimer.cancelCurrentTime(context);
        showNoticeDialog(
            context: context,
            contents: "Invalid data format",
            color: Colors.redAccent);
    }
  }
}