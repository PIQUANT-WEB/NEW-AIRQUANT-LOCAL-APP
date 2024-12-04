import 'package:airquant_monitor_local/utilities/shared_prefs.dart';
import 'package:provider/provider.dart';

import '../storage/data_storage.dart';
import 'common_data.dart';

class Sensor {

  // standard List 데이터 가져 와서 dataStorage에 넣기
  static void getStandardList(context) async {
    final items = await SharedPrefsUtils.getDisplayItems();
    final dataStorage = Provider.of<DataStorage>(context, listen: false);
    dataStorage.displayItems = items;
    dataStorage.infoDisplayItems = []; // 초기화 필요

    for (var showItem in items!) {
      List<String>? itemData = await SharedPrefsUtils.getStandards(showItem);
      if (itemData != null) {
        Map<String, List<String>> itemMap = {showItem: itemData};
        dataStorage.infoDisplayItems.add(itemMap);
      }
    }
    // print("=====getData infoDisplayItems : ${dataStorage.infoDisplayItems}");
  }

  // 표시할 카드 데이터 만들기
  static Future<void> createCardData(DataStorage dataStorage) async {

    try {
      List<Map<String, dynamic>> cardData = [];
      for (var sensor in dataStorage.displayItems!) {
        for (var data in dataStorage.infoDisplayItems!) {
          if (data.keys.contains(sensor)) {  // PM100, PM025, TVOC ...
            var itemStandard = data[sensor]; // [2000, 3000, ㎍/㎥, 500㎍/㎥ 이하]
            var dataList = _createCardDataList(sensor, itemStandard, dataStorage[sensor]);
            double value = dataStorage[sensor];
            _updateRatioAtCardData(dataList, sensor, itemStandard, value);
            cardData.add(dataList);
          }
        }
      }
      // print("====cardDatas: $cardData");
      dataStorage.cardData = cardData;
      dataStorage.notifyListeners();
    } catch (error) {
      print("======cardDatas error : $error");
    }
  }

  // 전체 기준 구하기
  static calculateStatus(DataStorage dataStorage) {
    final displayItems = dataStorage.cardData; // 각 카드에 있는 공기질 항목 데이터
    List<String> statusList = [];              // 각 공기질 항목을 넣을 statusList

    try {
      for (var items in displayItems!) {
        statusList.add(items['status']);
      }

      int cCount = 0;   // caution
      int wCount = 0;   // warning
      for (var status in statusList) {
        if (status == 'C') {
          cCount++;
        } else if (status == 'W') {
          wCount++;
        }
      }

      // C : C나 W가 2개 이상, C와 W가 합해서 2개, W가 2개 / W : W가 4개 이상 이면 W
      if (cCount >= 2 || wCount >= 2 || (cCount == 1 && wCount == 1)) {
        dataStorage.overallState = 'C';
      } else if (wCount >= 4) {
        dataStorage.overallState = 'W';
      } else {
        dataStorage.overallState = 'S'; // 'S' 또는 다른 경우에 대한 기본 값
      }
    }catch(error) {
      print("====== calculateStatus error : $error");
    }
  }

  // 공기질 항목 각 센서 데이터 리스트로 만들기
  static Map<String, dynamic> _createCardDataList(String sensor,
                            List<String>? itemStandard, double value) {
    var dataList = <String, dynamic>{};
    dataList["item"] = sensor;
    dataList["value"] = value;
    dataList["unit"] = itemStandard?[4];
    dataList["description"] = itemStandard?[5];
    return dataList;
  }

  // 데이터 리스트의 퍼센트 업데이트 위한 함수
  static void _updateRatioAtCardData(Map<String, dynamic> dataList,
                  String sensor, List<String>? itemStandard, double value) {

    double sensorMin = CommonData.sensorRange[sensor]?[0] ?? 0;
    double sensorMax = CommonData.sensorRange[sensor]?[1] ?? 60000;

    if(CommonData.exceptionItems.contains(sensor)) {
      _updateExceptionData(dataList, sensor, itemStandard, value, sensorMin, sensorMax);
    }else {
      _updateNormalData(dataList, sensor, itemStandard, value, sensorMin, sensorMax);
    }
  }

  // 온도, 습도 일 때
  static void _updateExceptionData(Map<String, dynamic> dataList, String sensor,
      List<String>? itemStandard, double value, sensorMin, sensorMax) {

      double safeMin = double.parse(itemStandard![0]);
      double safeMax = double.parse(itemStandard![1]);
      double caution = double.parse(itemStandard![2]);

      double cautionMin = safeMin - caution;
      double cautionMax = safeMax + caution;

      if (safeMin <= value && value <= safeMax) {
        dataList["status"] = "S";
        dataList["ratio"] = Sensor._getRatio(value, safeMin, safeMax);
      } else if (cautionMin < value && value < safeMin) {
        dataList["status"] = "C";
        dataList["ratio"] = Sensor._getRatio(value, safeMin, cautionMin);
      } else if (safeMax < value && value < cautionMax) {
        dataList["status"] = "C";
        dataList["ratio"] = Sensor._getRatio(value, safeMax, cautionMax);
      } else if (value <= cautionMin) {
        dataList["status"] = "W";
        dataList["ratio"] = Sensor._getRatio(value, cautionMin, sensorMin);
      } else {
        dataList["status"] = "W";
        dataList["ratio"] = Sensor._getRatio(value, cautionMax, sensorMax);
      }
  }

  // 그 외 항목들
  static void _updateNormalData(Map<String, dynamic> dataList, String sensor,
      List<String>? itemStandard, double value, double sensorMin, double sensorMax) {

      double caution = double.parse(itemStandard![2]);
      double warning = double.parse(itemStandard![3]);

      if (value < caution) {
        dataList["status"] = "S";
        dataList["ratio"] = Sensor._getRatio(value, sensorMin, caution);
      } else if (caution <= value && value <= warning) {
        dataList["status"] = "C";
        dataList["ratio"] = Sensor._getRatio(value, caution, warning);
      } else {
        dataList["status"] = "W";
        dataList["ratio"] = Sensor._getRatio(value, warning, sensorMax);
      }
  }

  // 퍼센트 구하기
  static double _getRatio(double value, double inMin, double inMax) {
    return ((value - inMin) * 100 / (inMax - inMin)) / 100;
  }


}