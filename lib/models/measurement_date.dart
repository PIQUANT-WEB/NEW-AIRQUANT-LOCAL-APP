import '../utilities/db_manager.dart';

class MeasurementDate {
  int? id;
  final String measurementDate;

  MeasurementDate({this.id, required this.measurementDate});

  Map<String, dynamic> toMap() {
    return {
      DBManager.id: id,
      DBManager.measurementDate: measurementDate,
    };
  }

  factory MeasurementDate.fromMap(Map<String, dynamic> map) {
    return MeasurementDate(
      id: map[DBManager.id],
      measurementDate: map[DBManager.measurementDate],
    );
  }

  @override
  String toString() {
    return '''
       MeasurementDate {
        id: $id, 
        measurementDate: $measurementDate, 
      }
    ''';
  }
}
