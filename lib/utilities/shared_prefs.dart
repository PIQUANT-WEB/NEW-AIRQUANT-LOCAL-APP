import 'package:airquant_monitor_local/utilities/key_name.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtils {
  static SharedPreferences? _prefs;

  // default values
  final bool _initialSetting = true;
  final int _cycle = 10;

  final List<String> _displayItems = [
    KeyName.pm025,
    KeyName.pm100,
    KeyName.co2,
    KeyName.tvoc,
    KeyName.humid,
    KeyName.tempe
  ];

  final List<String> _light = ["600", "6000", "500", "", "㎍/㎥", ""];
  final List<String> _humid = ["35", "60", "10", "", "%RH", "The Standard 40~60%RH"];
  final List<String> _tempe = ["18", "27", "3", "", "°C", ""];
  final List<String> _pm010 = ["", "", "35", "50", "㎍/㎥", "The Standard 50㎍/㎥ or less"];
  final List<String> _pm025 = ["", "", "35", "75", "㎍/㎥", "The Standard 50㎍/㎥ or less"];
  final List<String> _pm040 = ["", "", "50", "60", "㎍/㎥", "The Standard 50㎍/㎥ or less"];
  final List<String> _pm100 = ["", "", "80", "150", "㎍/㎥", "The Standard 50㎍/㎥ or less"];
  final List<String> _co = ["", "", "150000", "250000", "ppm", "The Standard 150000ppm or less"];
  final List<String> _co2 = ["", "", "1500", "3000", "ppm", "The Standard 1,000ppm or less"];
  final List<String> _no2 = ["", "", "1000", "5000", "ppm", "The Standard 1000㎍/㎥ or less"];
  final List<String> _so2 = ["", "", "1000", "5000", "ppm", "The Standard 1,000ppm or less"];
  final List<String> _tvoc = ["", "", "2000", "3000", "㎍/㎥", "The Standard 500㎍/㎥ or less"];
  final List<String> _sound = ["", "", "200", "300", "dB", "The Standard 200dB or less"];

  static Future<SharedPreferences> getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static getInitialSetting() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getBool(KeyName.initialSetting);
  }

  static setCycle(int cycle) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt(KeyName.cycle, cycle);
  }

  static setDisplayItems(List<String> displayItems) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setStringList(KeyName.displayItems, displayItems);
  }

  static setInitialSetting(bool initialSetting) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(KeyName.initialSetting, initialSetting);
  }

  static setAreaName(String areaName) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(KeyName.areaName, areaName);
  }

  static setAreaNames(List<String> areaNames) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setStringList(KeyName.areaNames, areaNames);
  }

  static setStandard(String item, List<String> standard) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setStringList(item, standard);
  }

  static setIsGranted(bool isGranted) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(KeyName.isGranted, isGranted);
  }

  static Future<bool> areaNameExists() async {
    _prefs ??= await SharedPreferences.getInstance();
    return await getAreaName() != null;
  }

  static Future<String?> getAreaName() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString(KeyName.areaName);
  }

  static Future<List<String>?> getAreaNames() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getStringList(KeyName.areaNames);
  }

  static Future<int?> getCycle() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getInt(KeyName.cycle);
  }

  static Future<List<String>?> getDisplayItems() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getStringList(KeyName.displayItems);
  }

  static Future<List<String>?> getStandards(String item) async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getStringList(item);
  }

  static Future<bool?> getIsGranted() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getBool(KeyName.isGranted);
  }

  static removeAreaInfo() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.remove(KeyName.areaName);
    await _prefs?.remove(KeyName.areaNames);
  }

  static initialSetting() async {
    final SharedPrefsUtils initialData = SharedPrefsUtils();
    final bool? initialSetting = await SharedPrefsUtils.getInitialSetting();

    if (initialSetting == null) {
      // 측정 주기 설정
      await setCycle(initialData._cycle);

      // 모니터링 항목 설정
      await setDisplayItems(initialData._displayItems);

      // 기준 설정
      await setStandard(KeyName.light, initialData._light);
      await setStandard(KeyName.humid, initialData._humid);
      await setStandard(KeyName.tempe, initialData._tempe);
      await setStandard(KeyName.pm010, initialData._pm010);
      await setStandard(KeyName.pm025, initialData._pm025);
      await setStandard(KeyName.pm040, initialData._pm040);
      await setStandard(KeyName.pm100, initialData._pm100);
      await setStandard(KeyName.co, initialData._co);
      await setStandard(KeyName.co2, initialData._co2);
      await setStandard(KeyName.no2, initialData._no2);
      await setStandard(KeyName.so2, initialData._so2);
      await setStandard(KeyName.tvoc, initialData._tvoc);
      await setStandard(KeyName.sound, initialData._sound);

      // 초기 세팅 여부
      await SharedPrefsUtils.setInitialSetting(initialData._initialSetting);

      print("초기 세팅 완료.");
    }
  }
}