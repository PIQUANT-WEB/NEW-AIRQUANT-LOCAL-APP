import 'package:airquant_monitor_local/utilities/key_name.dart';
import 'package:airquant_monitor_local/utilities/shared_prefs.dart';

class InitialData {

  final bool _initialSetting = true;
  final int _cycle = 10;

  final List<String> _displayItems = [
    KeyName.pm100,
    KeyName.pm025,
    KeyName.tvoc,
    KeyName.co2,
    KeyName.humid,
    KeyName.tempe
  ];

  final List<String> _light = ["600", "6000", "500", "", "㎍/㎥", ""];
  final List<String> _humid = ["35", "60", "10", "", "%RH", "표준 40~60%RH"];
  final List<String> _tempe = ["18", "27", "3", "", "°C", ""];
  final List<String> _pm010 = ["", "", "35", "50", "㎍/㎥", "표준 50㎍/㎥ 이하"];
  final List<String> _pm025 = ["", "", "35", "75", "㎍/㎥", "표준 50㎍/㎥ 이하"];
  final List<String> _pm040 = ["", "", "50", "60", "㎍/㎥", "표준 50㎍/㎥ 이하"];
  final List<String> _pm100 = ["", "", "80", "150", "㎍/㎥", "표준 50㎍/㎥ 이하"];
  final List<String> _co = ["", "", "150000", "250000", "ppm", "표준 150000ppm 이하"];
  final List<String> _co2 = ["", "", "1500", "3000", "ppm", "표준 1,000ppm 이하"];
  final List<String> _no2 = ["", "", "1000", "5000", "ppm", "표준 1000㎍/㎥ 이하"];
  final List<String> _so2 = ["", "", "1000", "5000", "ppm", "표준 1,000ppm 이하"];
  final List<String> _tvoc = ["", "", "2000", "3000", "㎍/㎥", "표준 500㎍/㎥ 이하"];
  final List<String> _sound = ["", "", "200", "300", "dB", "표준 200dB 이하"];

  static startInitialSetting() async {
    final InitialData initialData = InitialData();
    final bool? initialSetting = await SharedPrefsUtils.getInitialSetting();

    if (initialSetting == null) {
      // 측정 주기 설정
      await SharedPrefsUtils.setCycle(initialData._cycle);

      // 모니터링 항목 설정
      await SharedPrefsUtils.setDisplayItems(initialData._displayItems);

      // 기준 설정
      await SharedPrefsUtils.setStandard(KeyName.light, initialData._light);
      await SharedPrefsUtils.setStandard(KeyName.humid, initialData._humid);
      await SharedPrefsUtils.setStandard(KeyName.tempe, initialData._tempe);
      await SharedPrefsUtils.setStandard(KeyName.pm010, initialData._pm010);
      await SharedPrefsUtils.setStandard(KeyName.pm025, initialData._pm025);
      await SharedPrefsUtils.setStandard(KeyName.pm040, initialData._pm040);
      await SharedPrefsUtils.setStandard(KeyName.pm100, initialData._pm100);
      await SharedPrefsUtils.setStandard(KeyName.co, initialData._co);
      await SharedPrefsUtils.setStandard(KeyName.co2, initialData._co2);
      await SharedPrefsUtils.setStandard(KeyName.no2, initialData._no2);
      await SharedPrefsUtils.setStandard(KeyName.so2, initialData._so2);
      await SharedPrefsUtils.setStandard(KeyName.tvoc, initialData._tvoc);
      await SharedPrefsUtils.setStandard(KeyName.sound, initialData._sound);

      // 초기 세팅 여부
      await SharedPrefsUtils.setInitialSetting(initialData._initialSetting);
    }
  }
}
