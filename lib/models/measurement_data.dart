import '../utilities/db_manager.dart';

class MeasurementData {
  int? id;
  final int measurementDateId;
  final String measurementDatetime;
  final double pm010;
  final double pm025;
  final double pm040;
  final double pm100;
  final double co2;
  final double tempe;
  final double humid;
  final double tvoc;
  final double so2;
  final double no2;
  final double co;
  final double sound;
  final double light;

  MeasurementData({
    this.id,
    required this.measurementDateId,
    required this.measurementDatetime,
    required this.pm010,
    required this.pm025,
    required this.pm040,
    required this.pm100,
    required this.co2,
    required this.tempe,
    required this.humid,
    required this.tvoc,
    required this.so2,
    required this.no2,
    required this.co,
    required this.sound,
    required this.light,
  });

  Map<String, dynamic> toMap() {
    return {
      DBManager.id: id,
      DBManager.measurementDateId: measurementDateId,
      DBManager.measurementDatetime: measurementDatetime,
      DBManager.pm010: pm010,
      DBManager.pm025: pm025,
      DBManager.pm040: pm040,
      DBManager.pm100: pm100,
      DBManager.co2: co2,
      DBManager.tempe: tempe,
      DBManager.humid: humid,
      DBManager.tvoc: tvoc,
      DBManager.so2: so2,
      DBManager.no2: no2,
      DBManager.co: co,
      DBManager.sound: sound,
      DBManager.light: light,
    };
  }

  factory MeasurementData.fromMap(Map<String, dynamic> map) {
    return MeasurementData(
      id: map[DBManager.id],
      measurementDateId: map[DBManager.measurementDateId],
      measurementDatetime: map[DBManager.measurementDatetime],
      pm010: map[DBManager.pm010],
      pm025: map[DBManager.pm025],
      pm040: map[DBManager.pm040],
      pm100: map[DBManager.pm100],
      co2: map[DBManager.co2],
      tempe: map[DBManager.tempe],
      humid: map[DBManager.humid],
      tvoc: map[DBManager.tvoc],
      so2: map[DBManager.so2],
      no2: map[DBManager.no2],
      co: map[DBManager.co],
      sound: map[DBManager.sound],
      light: map[DBManager.light],
    );
  }

  @override
  String toString() {
    return '''
      MeasurementData {
        id: $id, 
        measurementDateId: $measurementDateId, 
        measurementDatetime: $measurementDatetime, 
        measurementDatetime: $measurementDatetime, 
        pm010: $pm010, 
        pm025: $pm025, 
        pm040: $pm040, 
        pm100: $pm100, 
        co2: $co2, 
        tempe: $tempe, 
        humid: $humid, 
        tvoc: $tvoc, 
        so2: $so2, 
        no2: $no2, 
        co: $co, 
        sound: $sound, 
        light: $light, 
      }
    ''';
  }
}
