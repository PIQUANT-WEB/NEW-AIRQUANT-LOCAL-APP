import 'dart:io' show Directory, File, FileMode, FileSystemEntity, Platform;
import 'package:airquant_monitor_local/utilities/shared_prefs.dart';
import 'package:csv/csv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:excel/excel.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/measurement_data.dart';
import '../storage/data_storage.dart';
import '../widgets/alert_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

class ExcelUtils {
  static String sheetName = 'Sheet1';
  static String directoryBase = "/storage/emulated/0/Download";

  // 1년 전 폴더 삭제
  static Future<void> deleteOldFolder(BuildContext context) async {
    try {
      String dirName = _formattedMonthDate(DateTime.now().subtract(Duration(days: 365))).substring(0, 6);

      print("====dirName : $dirName");

      if (_formattedMonthDate(DateTime.now()).endsWith("01")) {
        // 월 초 일 때 1년 전 삭제
        print("===error test : ${_formattedMonthDate(DateTime.now()).endsWith("01")}");
        List<FileSystemEntity> folders = Directory(directoryBase).listSync();

        if (folders.isNotEmpty) {
          for (var folder in folders) {
            String lastFolderName = folder.path.split("/").last;
            if (lastFolderName.compareTo(dirName) < 0) {
              if (folder.existsSync()) {
                try {
                  folder.deleteSync(recursive: true);
                  print("===== 폴더 삭제 성공: $lastFolderName");
                  showNoticeDialog(
                      context: context,
                      contents: 'Excel files that were saved more than a year ago have been deleted',
                      color: Colors.blue);
                } catch (error) {
                  print("===== 폴더 삭제 실패 : $error");
                  showNoticeDialog(
                      context: context,
                      contents: 'Failed to delete Excel file that is over 1 year old',
                      color: Colors.redAccent);
                }
              }
            } else {
              print("====삭제할 폴더가 없습니다!");
            }
          }
        }
      } // if condition end
    } catch (error) {
      print("=====deleteOldFolder error : $error");
    }
  }

  // csv 저장
  static Future<void> writeCsv(DataStorage dataStorage, BuildContext context) async {
    print("key len: ${dataStorage.keys.length} \n ${dataStorage.keys}");
    print("value len: ${dataStorage.values.length} \n ${dataStorage.values}");

    try {
      final String? areaName = await SharedPrefsUtils.getAreaName();

      // 1. 현재 날짜 가져와서 포맷팅 파일명(20231101), 디렉토리명(202311)
      String formattedFile = _formattedMonthDate(DateTime.now());
      String formattedDir = formattedFile.substring(0, 6);

      // 3. 폴더 생성 및 내부 저장소에 저장
      String path;
      if (Platform.isAndroid) {
        Directory? appDir = await getExternalStorageDirectory();
        // path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
        path = appDir!.path;
        path = directoryBase;
      } else {
        return;
      }

      const appName = "AIRQUANT";
      Directory appDirectory = Directory('$path/$appName');
      String appDirectoryPath = "";

      // 4. 앱 폴더 생성 및 경로 가져오기
      if (await appDirectory.exists()) {
        appDirectoryPath = appDirectory.path;
        print("존재 O :: $appDirectoryPath");
      } else {
        appDirectory = await appDirectory.create(recursive: true);
        appDirectoryPath = appDirectory.path;
        print("존재 X :: $appDirectoryPath");
      }

      // 5. 날짜 폴더 확인 및 생성
      Directory dateDirectory = Directory('$appDirectoryPath/$formattedDir');

      if (await dateDirectory.exists()) {
        print("날짜 폴더 존재 O :: ${dateDirectory.path}");
      } else {
        await dateDirectory.create(recursive: true);
        print("날짜 폴더 생성 :: ${dateDirectory.path}");
      }

      // file path 설정
      String filePath = "${dateDirectory.path}/${formattedFile}_$areaName.csv";
      print(filePath);

      // 파일이 존재하는지 확인
      final File file = File(filePath);
      bool fileExists = await file.exists();

      print("fileExitst:  $fileExists");

      if (fileExists) {
        // 파일이 존재하면 기존 데이터를 읽고 새로운 데이터를 추가
        List<List<dynamic>> existingData = await _readCsv(filePath);
        // showNoticeDialog(
        //     context: context,
        //     contents: "${existingData[existingData.length - 1]}",
        //     color: Colors.redAccent);
        // existingData.add(dataStorage.values); // 새로운 데이터 추가

        // 데이터를 CSV 형식으로 변환하여 파일에 덮어쓰기
        existingData.add(dataStorage.values);
        String csvData = const ListToCsvConverter().convert(existingData);
        await file.writeAsString(csvData);

        print("추가 완료 --------");
      } else {
        List<List<dynamic>> newData = [
          [
            'Date',
            'PM025',
            'PM100',
            'CO2',
            'TVOC',
            'HUMID',
            'TEMPE',
            'PM040',
            'PM010',
            'SO2',
            'NO2',
            'CO',
            'SOUND',
            'LIGHT'
          ], // 헤더
          dataStorage.values
        ];

        // 파일이 존재하지 않으면 새로운 파일을 생성하고 첫 데이터를 추가
        String csvData = const ListToCsvConverter().convert(newData);
        await file.writeAsString(csvData);
        print("생성 완료 --------");
      }
    } catch (error) {
      print("=====excel 저장 실패 : $error");
      // showNoticeDialog(
      //     context: context,
      //     contents: 'Failed to save Excel',
      //     color: Colors.redAccent);
    }
  }

  // csv 다운로드
  static Future<void> downloadCsv(String measurementDate, List<MeasurementData> measurementData) async {
    try {
      final String? areaName = await SharedPrefsUtils.getAreaName();

      // 1. 현재 날짜 가져와서 포맷팅 파일명(20231101), 디렉토리명(202311)
      String formattedFile = measurementDate.replaceAll("/", "");
      String formattedDir = formattedFile.substring(0, 6);

      // 3. 폴더 생성 및 내부 저장소에 저장
      String path;
      if (Platform.isAndroid) {
        Directory? appDir = await getExternalStorageDirectory();
        // path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
        path = appDir!.path;
        path = directoryBase;
      } else {
        return;
      }

      const appName = "AIRQUANT_DATA";
      Directory appDirectory = Directory('$path/$appName');
      String appDirectoryPath = "";

      // 4. 앱 폴더 생성 및 경로 가져오기
      if (await appDirectory.exists()) {
        appDirectoryPath = appDirectory.path;
        print("존재 O :: $appDirectoryPath");
      } else {
        appDirectory = await appDirectory.create(recursive: true);
        appDirectoryPath = appDirectory.path;
        print("존재 X :: $appDirectoryPath");
      }

      // 5. 날짜 폴더 확인 및 생성
      Directory dateDirectory = Directory('$appDirectoryPath/$formattedDir');

      if (await dateDirectory.exists()) {
        print("날짜 폴더 존재 O :: ${dateDirectory.path}");
      } else {
        await dateDirectory.create(recursive: true);
        print("날짜 폴더 생성 :: ${dateDirectory.path}");
      }

      // file path 설정
      String filePath = "${dateDirectory.path}/${formattedFile}_$areaName.csv";
      print(filePath);

      // csv 저장
      final File file = File(filePath);
      List<List<dynamic>> newData = [
        [
          'Date',
          'PM010',
          'PM025',
          'PM040',
          'PM100',
          'CO2',
          'TEMPE',
          'HUMID',
          'TVOC',
          'SO2',
          'NO2',
          'CO',
          'SOUND',
          'LIGHT'
        ], // 헤더
        for (MeasurementData data in measurementData)
          [
            data.measurementDatetime,
            data.pm010,
            data.pm025,
            data.pm040,
            data.pm100,
            data.co2,
            data.tempe,
            data.humid,
            data.tvoc,
            data.so2,
            data.no2,
            data.co,
            data.sound,
            data.light,
          ],
      ];
      String csvData = const ListToCsvConverter().convert(newData);
      await file.writeAsString(csvData);
    } catch (error) {
      print("=====excel 저장 실패 : $error");
      // showNoticeDialog(
      //     context: context,
      //     contents: 'Failed to save Excel',
      //     color: Colors.redAccent);
    }
  }

  // CSV 파일을 읽어서 List로 반환하는 함수
  static Future<List<List<dynamic>>> _readCsv(String filePath) async {
    File file = File(filePath);
    String csvString = await file.readAsString();
    List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);
    return rows;
  }

  // // 엑셀 데이터 저장
  // static Future<void> createExcelFile(DataStorage dataStorage, BuildContext context) async {
  //   try {
  //     final String? areaName = await SharedPrefsUtils.getAreaName();
  //
  //     // 1. 현재 날짜 가져와서 포맷팅 파일명(20231101), 디렉토리명(202311)
  //     String formattedFile = _formattedMonthDate(DateTime.now());
  //     String formattedDir = formattedFile.substring(0, 6);
  //
  //     // 2. 폴더 생성 및 외부 저장소에 저장
  //     final path = Directory('$directoryBase/$formattedDir');
  //     print("=========path : $path");
  //     String res = "";
  //
  //     // 2-1. 폴더가 없을 때 폴더 생성
  //     if (await path.exists()) {
  //       res = path.path;
  //     } else {
  //       final Directory appDocDirNewFolder = await path.create(recursive: true);
  //       res = appDocDirNewFolder.path;
  //     }
  //
  //     // 3. 파일 생성
  //     final String fileName = "$res/${formattedFile}_$areaName.xlsx";
  //     final File file = File(fileName);
  //     bool fileExists = await file.exists();
  //
  //     // 3-1. 파일 존재 시 파일을 열어서 데이터 추가 혹은 미존재 시 새로운 파일에 데이터 추가
  //     if (fileExists) {
  //       await _appendDataToExistingExcel(file, dataStorage);
  //     } else {
  //       await _createNewExcel(file, dataStorage);
  //     }
  //   } catch (error) {
  //     print("=====excel 저장 실패 : $error");
  //     showNoticeDialog(
  //         context: context,
  //         contents: 'Failed to save Excel',
  //         color: Colors.redAccent);
  //   }
  // }

  // 현재 날짜 포맷팅(20231101)
  static String _formattedMonthDate(DateTime now) {
    return "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
  }

  // 기존 파일이 있고, 데이터만 추가
  static Future<void> _appendDataToExistingExcel(File file, DataStorage dataStorage) async {
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    Sheet sheetObject = excel[sheetName];
    int lastRowIndex = sheetObject?.maxRows ?? 0;

    // 헤더 없을 시 헤더 추가
    if (sheetObject == null || sheetObject.maxRows == 0) {
      _addHeadersToSheet(sheetObject, dataStorage.keys);
    }
    _addDataToSheet(sheetObject, dataStorage.values, lastRowIndex);

    var fileBytes = excel.encode();
    await file.writeAsBytes(fileBytes!);
    print("=====이미 있는 엑셀 파일에 저장 성공");
  }

  // 새로운 파일 생성
  static Future<void> _createNewExcel(File file, DataStorage dataStorage) async {
    Excel excel = Excel.createExcel();
    Sheet sheetObject = excel[sheetName];

    _addHeadersToSheet(sheetObject, dataStorage.keys);
    _addDataToSheet(sheetObject, dataStorage.values, 1);

    await file.writeAsBytes(excel.encode()!);
    excel.save(fileName: file.path);
    print("=====새로운 엑셀 파일 저장 성공");
  }

  // 헤더 추가
  static void _addHeadersToSheet(Sheet sheetObject, List<Object> headers) {
    for (int i = 0; i < headers.length; i++) {
      var cellHeader = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cellHeader.value = headers[i].toString().tr();
    }
  }

  // 데이터 추가
  static void _addDataToSheet(Sheet sheetObject, List<Object> values, int lastRowIndex) {
    for (int i = 0; i < values.length; i++) {
      var cellValue = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: lastRowIndex));
      cellValue.value = values[i].toString();
    }
  }

  // 엑셀 저장 안될 때 Alert창 띄우기
  static void _showAlertDialog(String title, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Notification").tr(),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
