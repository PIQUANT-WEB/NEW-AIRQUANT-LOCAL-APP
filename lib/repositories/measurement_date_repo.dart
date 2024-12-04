import '../models/measurement_date.dart';
import '../utilities/db_manager.dart';

class MeasurementDateRepo {
  /// 측정 날짜 저장 => 생성된 row id 반환
  Future<int?> create(MeasurementDate measurementDate) async {
    try {
      int id = await DBManager.db!.insert(
        DBManager.measurementDateTable,
        measurementDate.toMap(),
      );
      print("sqflite: measurementDate 저장 완료 *******************");
      return id;
    } catch (e) {
      // 예외 처리 로직...
      print("Error: measurementDate 저장 실패 ******************* \n $e");
      return null; // 실패 시 null
    }
  }

  /// measurementDate 조회
  Future<MeasurementDate?> findByMeasurementDate(String measurementDate) async {
    try {
      final List<Map<String, dynamic>> maps = await DBManager.db!.query(
        DBManager.measurementDateTable,
        where: '${DBManager.measurementDate} = ?',
        whereArgs: [measurementDate],
      );

      if (maps.isNotEmpty) {
        print("sqflite: measurementDate 조회 완료 *******************");
        return MeasurementDate.fromMap(maps.first);  // 첫 번째 항목을 반환
      } else {
        return null; // 결과가 없으면 null 반환
      }
    } catch (e) {
      print("Error: measurementDate 조회 실패 ******************* \n $e");
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
