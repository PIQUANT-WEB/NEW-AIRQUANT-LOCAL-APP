import 'package:airquant_monitor_local/models/measurement_data.dart';

import '../models/measurement_date.dart';
import '../utilities/db_manager.dart';

class MeasurementDataRepo {
  /// 측정 데이터 저장 => 생성된 row id 반환
  Future<int?> create(MeasurementData measurementData) async {
    try {
      int id = await DBManager.db!.insert(
        DBManager.measurementDataTable,
        measurementData.toMap(),
      );
      print("sqflite: measurementData 저장 완료 *******************");
      return id;
    } catch (e) {
      // 예외 처리 로직...
      print("Error: measurementData 저장 실패 ******************* \n $e");
      return null; // 실패 시 null
    }
  }

  /// 특정 날짜 데이터 리스트 조회
  Future<List<MeasurementData>?> findByMeasurementDateId(int measurementDateId) async {
    try {
      final List<Map<String, dynamic>> maps = await DBManager.db!.query(
        DBManager.measurementDataTable,
        where: '${DBManager.measurementDateId} = ?',
        whereArgs: [measurementDateId],
      );

      print("sqflite: measurementData 리스트 조회 완료 *******************");

      return List.generate(maps.length, (i) {
        return MeasurementData.fromMap(maps[i]);
      });

    } catch (e) {
      print("Error: measurementData 리스트 조회 실패 ******************* \n $e");
      return null;
    }
  }

  // /// row 일괄 삭제  => 삭제된 row 개수 반환
  // Future<int> deleteByIdIn(List<int> ids) async {
  //   try {
  //     int deletedRows = await DBManager.db!.delete(
  //       DBManager.bloodDataTable,
  //       where: '${DBManager.id} IN (${ids.join(', ')})',
  //     );
  //
  //     print("sqflite: blood data $deletedRows게 삭제 완료 *******************");
  //     return deletedRows;
  //   } catch (e) {
  //     print("Error: blood data 삭제 실패 ******************* \n $e");
  //     return 0;
  //   }
  // }
  //
  // /// row 모두 삭제
  // Future<int> deleteAll() async {
  //   try {
  //     int deletedRows = await DBManager.db!.delete(DBManager.bloodDataTable);
  //
  //     print("sqflite: 모든 blood data $deletedRows개 삭제 완료 *******************");
  //     return deletedRows;
  //   } catch (e) {
  //     print("Error: 모든 blood data 삭제 실패 ******************* \n $e");
  //     return 0;
  //   }
  // }
}
