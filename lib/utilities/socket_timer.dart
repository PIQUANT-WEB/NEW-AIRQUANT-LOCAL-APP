import 'dart:async';
import 'dart:convert';

import 'package:airquant_monitor_local/models/measurement_data.dart';
import 'package:airquant_monitor_local/repositories/measurement_date_repo.dart';
import 'package:airquant_monitor_local/utilities/sensor.dart';
import 'package:airquant_monitor_local/utilities/shared_prefs.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Socket;
import '../models/measurement_date.dart';
import '../repositories/measurement_data_repo.dart';
import '../storage/data_storage.dart';
import 'excel.dart';

class SocketTimer {
  static Socket? socket;
  static MeasurementDateRepo measurementDateRepo = MeasurementDateRepo();
  static MeasurementDataRepo measurementDataRepo = MeasurementDataRepo();

  // 10초마다 소켓을 통해 기기로 데이터 전송
  Future<void> connectToDeviceTimer(BuildContext context) async {
    print("JJJJJJJJ : connectToDeviceTimer ${DateTime.now()}");

    final cycle = await SharedPrefsUtils.getCycle();
    final dataStorage = Provider.of<DataStorage>(context, listen: false);

    try {
      // 이전 타이머가 있다면 취소
      dataStorage.timer?.cancel();

      dataStorage.timer = Timer.periodic(Duration(seconds: cycle!), (timer) async {
        print("==Main Timer tick: ${timer.tick}");
        DateTime now = DateTime.now();
        print("==Now!! : $now");
        connectToSocket(context, false); // 10초마다 한 번씩 소켓 실행
      });
    } catch (error) {
      print("타이머 예외 발생 :  $error");
      cancelTimer(context);
      cancelCurrentTime(context);
      updateExcelIndex(context);
      connectToDeviceTimer(context);
      getCurrentTime(context);
      dataStorage.loading = true;
    }
  }

  // 소켓으로 기기 연결
  int cnt = 1;

  Future<void> connectToSocket(BuildContext context, bool isFirst) async {
    socket?.close();

    final dataStorage = Provider.of<DataStorage>(context, listen: false);
    final cycle = await SharedPrefsUtils.getCycle();
    // final standardDataList = await standardDataListFuture; // standardDataList를 기다림

    try {
      // 소켓 연결
      print("=== try to connect to socket");
      // socket = await Socket.connect('192.168.4.1', 80);
      /// 아래 코드 살리기
      socket = await Socket.connect(dataStorage.ip, dataStorage.port, timeout: Duration(seconds: 30));
      print("Socket connected.");

      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: Text('Alert'),
      //       content: Column(
      //         children: [
      //           Text('$socket'),
      //           Text('Socket connected'),
      //         ],
      //       ),
      //       actions: [
      //         TextButton(
      //           onPressed: () {
      //             Navigator.of(context).pop(); // 다이얼로그 닫기
      //           },
      //           child: Text('Close'),
      //         ),
      //       ],
      //     );
      //   },
      // );

      socket!.listen((event) async {
        String data = String.fromCharCodes(event);

        if (isFirst) {
          await socket!.close();
          return;
        }

        if (data.contains("SITE")) {
          /// ethernet data
          DataStorage.saveDataToStorage(data, dataStorage, context);
        } else {
          DataStorage.saveDataToStorage(data.split(","), dataStorage, context);
        }

        print("========= 기기에서 넘어온 data: $data");

        // 데이터 저장
        Sensor.createCardData(dataStorage); // 카드 데이터 만들기

        /// db 저장 ----------
        // 날짜 조회
        String date = dataStorage.Date.split(' ')[0]; // 2024/12/03
        MeasurementDate? measurementDate = await measurementDateRepo.findByMeasurementDate(date);
        int? measurementDateId;
        if (measurementDate == null) {
          measurementDateId = await measurementDateRepo.create(MeasurementDate(measurementDate: date));
        } else {
          measurementDateId = measurementDate.id!;
        }
        // 데이터 저장
        if (measurementDateId != null) {
          int? measurementDataId = await measurementDataRepo.create(MeasurementData(
            measurementDateId: measurementDateId,
            measurementDatetime: dataStorage.Date,
            pm010: dataStorage.PM010,
            pm025: dataStorage.PM025,
            pm040: dataStorage.PM040,
            pm100: dataStorage.PM100,
            co2: dataStorage.CO2,
            tempe: dataStorage.TEMPE,
            humid: dataStorage.HUMID,
            tvoc: dataStorage.TVOC,
            so2: dataStorage.SO2,
            no2: dataStorage.NO2,
            co: dataStorage.CO,
            sound: dataStorage.SOUND,
            light: dataStorage.LIGHT,
          ));

          if (measurementDataId != null) print("db에 측정 데이터 저장 완료");
        }

        // 소켓 연결 끊기
        await socket!.close();

        // 5분마다 엑셀 데이터 저장
        // if(dataStorage.createExcelIndex == 0) {
        //   dataStorage.createExcelIndex = 300 ~/ (cycle ?? 1);
        //   ExcelUtils.createExcelFile(dataStorage, context);
        // }
        // ExcelUtils.createExcelFile(dataStorage, context);
        await ExcelUtils.writeCsv(dataStorage, context);

        dataStorage.createExcelIndex--;
        print("=====excel 생성 위한 count : ${dataStorage.createExcelIndex}");
      }, onDone: () {
        // 소켓이 정상적으로 닫힌 경우 호출됨
        print("Socket closed.");
        _disconnectSocket();
      }, onError: (error) {
        // 오류가 발생한 경우 호출됨
        print("Socket error: $error");
      });

      socket!.write("READY");
    } catch (error) {
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: Text('Alert'),
      //       content: Column(
      //         children: [
      //           Text("ERROR: $error"),
      //           Text('$socket'),
      //         ],
      //       ),
      //       actions: [
      //         TextButton(
      //           onPressed: () {
      //             Navigator.of(context).pop(); // 다이얼로그 닫기
      //           },
      //           child: Text('Close'),
      //         ),
      //       ],
      //     );
      //   },
      // );

      socket?.close();
      print("=====소켓 에러 : ${error}");
      cancelTimer(context);
      cancelCurrentTime(context);
      updateExcelIndex(context);
      connectToDeviceTimer(context);
      print("======새로운 타이머 실행하기");
      getCurrentTime(context);
      dataStorage.cardData = [];
      dataStorage.loading = true;
      print("===dataStorage.loading : ${dataStorage.loading}");
    }
  }

  // 현재 시간 가져 오기
  void getCurrentTime(BuildContext context) {
    final dataStorage = Provider.of<DataStorage>(context, listen: false);
    try {
      dataStorage.currentTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
        DateTime now = DateTime.now();
        String date = DateFormat('yyyy.MM.dd').format(now);
        String time = DateFormat('HH:mm:ss').format(now);
        dataStorage.currentDate = date;
        dataStorage.currentTime = time;
        dataStorage.notifyListeners();
      });
    } catch (error) {
      print("======현재 시간 갖고오기 error : $error}");
      cancelTimer(context);
      cancelCurrentTime(context);
      updateExcelIndex(context);
      connectToDeviceTimer(context);
      getCurrentTime(context);
      dataStorage.loading = true;
    }
  }

  // 소켓 연결 끊기
  void _disconnectSocket() {
    socket?.destroy();
    print("Socket disconnected.");
  }

  // 엑셀 타이머 인덱스
  void updateExcelIndex(BuildContext context) {
    final dataStorage = Provider.of<DataStorage>(context, listen: false);
    dataStorage.createExcelIndex = 0;
  }

  // 타이머 가져 오기
  Timer? getInitialTimer(BuildContext context) {
    final dataStorage = Provider.of<DataStorage>(context, listen: false);
    return dataStorage.timer;
  }

  // 타이머 삭제
  void cancelTimer(BuildContext context) {
    print("===타이머 삭제");
    final dataStorage = Provider.of<DataStorage>(context, listen: false);
    dataStorage.timer?.cancel();
  }

  // 현재 시간 삭제
  void cancelCurrentTime(BuildContext context) {
    print("==현재 시간 타이머 삭제");
    final dataStorage = Provider.of<DataStorage>(context, listen: false);
    dataStorage.currentTimer?.cancel();
  }

  // 데이터 주기를 변경 했는 지 안 했는지 check
  bool? getCheckCycle(BuildContext context) {
    final dataStorage = Provider.of<DataStorage>(context, listen: false);
    return dataStorage.checkCycle;
  }

  // 데이터 주기를 변경 후 true로 변경
  void updateCycle(BuildContext context, bool value) {
    final dataStorage = Provider.of<DataStorage>(context, listen: false);
    dataStorage.checkCycle = value;
  }
}
