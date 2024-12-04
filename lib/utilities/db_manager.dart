import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBManager {
  static Database? db;

  static const _dbName = "airquant_local.db";
  static const _dbVersion = 1;

  /// tableName
  static const measurementDateTable = "MEASUREMENT_DATE";
  static const measurementDataTable = "MEASUREMENT_DATA";

  /// columns
  static const id = "ID";
  // measurementDate
  static const measurementDate = "MEASUREMENT_DATE";
  // measurementData
  static const measurementDateId = "MEASUREMENT_DATE_ID";
  static const measurementDatetime = "MEASUREMENT_DATETIME";
  static const pm010 = "PM010";
  static const pm025 = "PM025";
  static const pm040 = "PM040";
  static const pm100 = "PM100";
  static const co2 = "CO2";
  static const tempe = "TEMPE";
  static const humid = "HUMID";
  static const tvoc = "TVOC";
  static const so2 = "SO2";
  static const no2 = "NO2";
  static const co = "CO";
  static const sound = "SOUND";
  static const light = "LIGHT";

  /// DB 초기화
  static Future<void> initDB() async {
    print("DB 초기화 ************************************");
    String path = join(await getDatabasesPath(), _dbName);

    db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        // 측정 날짜 테이블
        await db.execute('''
          CREATE TABLE $measurementDateTable (
            $id INTEGER PRIMARY KEY AUTOINCREMENT,
            $measurementDate TEXT NOT NULL
          );
        ''');

        // 측정 데이터 테이블
        await db.execute('''
          CREATE TABLE $measurementDataTable (
            $id INTEGER PRIMARY KEY AUTOINCREMENT,
            $measurementDateId INTEGER NOT NULL,
            $measurementDatetime TEXT NOT NULL,
            $pm010 REAL NOT NULL,
            $pm025 REAL NOT NULL,
            $pm040 REAL NOT NULL,
            $pm100 REAL NOT NULL,
            $co2 REAL NOT NULL,
            $tempe REAL NOT NULL,
            $humid REAL NOT NULL,
            $tvoc REAL NOT NULL,
            $so2 REAL NOT NULL,
            $no2 REAL NOT NULL,
            $co REAL NOT NULL,
            $sound REAL NOT NULL,
            $light REAL NOT NULL,
            FOREIGN KEY ($measurementDateId) REFERENCES $measurementDateTable($id)
          );
        ''');
      },
    );
  }
}
