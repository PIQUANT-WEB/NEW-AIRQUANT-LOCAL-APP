import 'package:airquant_monitor_local/models/measurement_data.dart';
import 'package:airquant_monitor_local/models/measurement_date.dart';
import 'package:airquant_monitor_local/utilities/excel.dart';
import 'package:airquant_monitor_local/widgets/alert_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../repositories/measurement_data_repo.dart';
import '../../repositories/measurement_date_repo.dart';
import '../../widgets/calendar_widget.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  MeasurementDateRepo measurementDateRepo = MeasurementDateRepo();
  MeasurementDataRepo measurementDataRepo = MeasurementDataRepo();


  late String selectedDate;

  // 날짜 선택 콜백
  void _onDateSelected(DateTime date) {
    setState(() {
      // 원하는 날짜 포맷으로 변환
      String formattedDate = DateFormat('yyyy/MM/dd').format(date);
      selectedDate = formattedDate;
    });

    print("Selected Date: $selectedDate");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          flex: 2,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
            child: Text('Download', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600)).tr(),
          ),
        ),
        SizedBox(height: 10),
        Flexible(
          flex: 9,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 30, 500, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: CalendarInputWidget(
                      labelText: 'Select date'.tr(),
                      onDateSelected: _onDateSelected,
                    ),
                  ),
                ),
                SizedBox(width: 15),
                OutlinedButton(
                  style: TextButton.styleFrom(
                      fixedSize: Size(150, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0), // 버튼의 라운드 값을 설정
                      ),
                      side: BorderSide(color: Colors.blue)),

                  /// 다운로드 버튼
                  child: Text("Download", style: TextStyle(fontSize: 20)).tr(),
                  onPressed: () async {
                    // 날짜 조회
                    MeasurementDate? measurementDate = await measurementDateRepo.findByMeasurementDate(selectedDate);

                    if (measurementDate == null) {
                      // 예외 처리
                      print("해당 날짜 데이터가 없습니다.");
                      showNoticeDialog(
                          context: context,
                          contents: "해당 날짜 데이터가 없습니다.",
                          color: Colors.redAccent);
                      return;
                    }

                    // 데이터 조회
                    List<MeasurementData>? measurementData =
                        await measurementDataRepo.findByMeasurementDateId(measurementDate.id!);
                    if (measurementData == null) {
                      // 예외 처리
                      print("데이터 조회에 실패했습니다.");
                      showNoticeDialog(
                          context: context,
                          contents: "데이터 조회에 실패했습니다.",
                          color: Colors.redAccent);
                      return;
                    }
                    if (measurementData.isEmpty) {
                      // 예외 처리
                      print("해당 날짜 데이터가 없습니다.");
                      showNoticeDialog(
                          context: context,
                          contents: "해당 날짜 데이터가 없습니다.",
                          color: Colors.redAccent);
                      return;
                    }

                    // csv data 저장
                    await ExcelUtils.downloadCsv(measurementDate.measurementDate, measurementData);
                    print("내보낸 파일은 스마트폰의 '내장메모리 > Download > AIRQUANT_DATA' 폴더에 저장됩니다.\n단, 기기별로 저장 위치가 다를 수 있습니다.");
                    showNoticeDialog(
                        context: context,
                        contents: "내보낸 파일은 스마트폰의 '내장메모리 > Download > AIRQUANT_DATA' 폴더에 저장됩니다.\n단, 기기별로 저장 위치가 다를 수 있습니다.",
                        color: Colors.blue);
                    // List<MeasurementData> testData = [
                    //   MeasurementData(
                    //     measurementDateId: 1,
                    //     measurementDatetime: '2024/12/03 15:33:33',
                    //     pm010: 0.2,
                    //     pm025: 0.2,
                    //     pm040: 0.2,
                    //     pm100: 0.2,
                    //     co2: 0.2,
                    //     tempe: 0.2,
                    //     humid: 0.2,
                    //     tvoc: 0.2,
                    //     so2: 0.2,
                    //     no2: 0.2,
                    //     co: 0.2,
                    //     sound: 0.2,
                    //     light: 0.2,
                    //   ),
                    //   MeasurementData(
                    //     measurementDateId: 1,
                    //     measurementDatetime: '2024/12/03 15:33:33',
                    //     pm010: 0.1,
                    //     pm025: 0.1,
                    //     pm040: 0.1,
                    //     pm100: 0.1,
                    //     co2: 0.1,
                    //     tempe: 0.1,
                    //     humid: 0.1,
                    //     tvoc: 0.1,
                    //     so2: 0.1,
                    //     no2: 0.1,
                    //     co: 0.1,
                    //     sound: 0.1,
                    //     light: 0.1,
                    //   ),
                    // ];
                    // await ExcelUtils.downloadCsv(date, testData);
                    // print("내보낸 파일은 스마트폰의 '내장메모리 > Download > AIRQUANT_DATA' 폴더에 저장됩니다.\n단, 기기별로 저장 위치가 다를 수 있습니다.");
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
