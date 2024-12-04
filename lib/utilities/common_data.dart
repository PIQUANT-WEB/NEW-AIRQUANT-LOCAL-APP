import 'key_name.dart';

class CommonData {
  static final Map<String, List<double>> sensorRange = {
    KeyName.light: [1, 20000],
    KeyName.humid: [0, 100],
    KeyName.tempe: [-40, 125],
    KeyName.pm010: [0, 1000],
    KeyName.pm025: [0, 1000],
    KeyName.pm040: [0, 1000],
    KeyName.pm100: [0, 1000],
    KeyName.co: [0, 1000],
    KeyName.co2: [0, 10000],
    KeyName.no2: [0, 5000],
    KeyName.so2: [0, 20000],
    KeyName.tvoc: [0, 60000],
    KeyName.sound: [30, 120]
  };

  static final List<String> measureItems = [
    KeyName.light,
    KeyName.humid,
    KeyName.tempe,
    KeyName.pm010,
    KeyName.pm025,
    KeyName.pm040,
    KeyName.pm100,
    KeyName.co,
    KeyName.co2,
    KeyName.no2,
    KeyName.so2,
    KeyName.tvoc,
    KeyName.sound
  ];

  static final List<String> exceptionItems = [
    KeyName.light,
    KeyName.humid,
    KeyName.tempe
  ];

  static final Map<String, String> images = {
    KeyName.pm100: 'assets/images/help/finedust.png',
    KeyName.co2: 'assets/images/help/co2.png',
    KeyName.tvoc: 'assets/images/help/voc.png',
    KeyName.co: 'assets/images/help/co.png',
    KeyName.no2: 'assets/images/help/co.png',
    KeyName.so2: 'assets/images/help/co.png',
    KeyName.tempe: 'assets/images/help/tempe.png',
    KeyName.humid: 'assets/images/help/humidity.png',
  };

  // static final Map<String, List<String>> contents = {
  //   KeyName.pm100: [
  //     'Small solid or liquid',
  //     'Various emission sources',
  //     'Decreased lung function'
  //   ],
  //   KeyName.co2: [
  //     'harmless Greenhouse gases',
  //     'High concentration',
  //     'Outdoor average concentration',
  //     'increase in fatigue',
  //   ],
  //   KeyName.tvoc: [
  //     'Liquid or gaseous organic compounds',
  //     'Artificial sources',
  //     'When exposed to the skin',
  //   ],
  //   KeyName.co: [
  //     'Colorless, odorless, tasteless toxic gas',
  //     'Occurs due to incomplete combustion',
  //     'Occurs from industrial processes',
  //     'Even healthy people can get fatigue',
  //   ],
  //   KeyName.no2: [
  //     'Pungent odor, reddish-brown gas',
  //     'Reacts with TVOC',
  //     'Automobiles',
  //     'Destroys plant cells',
  //     'It can develop into bronchitis',
  //   ],
  //   KeyName.so2: [
  //     'Emissions from fossil fuel use',
  //     'Occurs in power plants',
  //     'Causes breathing problems',
  //     'Main causes of acid rain',
  //   ],
  //   KeyName.tempe: [
  //     'Required for indoor temperature control',
  //     'Proper indoor temperature',
  //   ],
  //   KeyName.humid: [
  //     'High humidity',
  //     'Low humidity',
  //   ]
  // };
}
