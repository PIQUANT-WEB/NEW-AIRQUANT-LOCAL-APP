import 'package:airquant_monitor_local/pages/intro/connect_mode.dart';
import 'package:flutter/services.dart'; // 화면 고정
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:airquant_monitor_local/pages/intro/init_area.dart';
import 'package:airquant_monitor_local/pages/intro/splash.dart';
import 'package:airquant_monitor_local/pages/home/home.dart';
import 'package:airquant_monitor_local/pages/settings/settings.dart';
import 'package:airquant_monitor_local/storage/data_storage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wakelock/wakelock.dart'; // 번역

Future<void> main() async {
  // 라이브러리 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  Wakelock.enable();

  runApp(
      EasyLocalization(
        saveLocale: true,
        useOnlyLangCode: true,
        supportedLocales: const [Locale('en'), Locale('ko')],
        path: 'assets/lang',
        fallbackLocale: Locale('en'), // 언어 대체
        child: MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 가로 왼쪽 방향 고정
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    return MultiProvider(
      providers:
      [ChangeNotifierProvider(create : (create) => DataStorage())
      ],
      child: MaterialApp(
        localizationsDelegates: context.localizationDelegates, // 번역
        supportedLocales: context.supportedLocales,
        debugShowCheckedModeBanner: false, // 디버그 배너 삭제
        title: 'airquant_monitor_local',
        theme: ThemeData(
          colorScheme: ColorScheme(brightness: Brightness.light, primary: Colors.blue, onPrimary: Color(
              0xFF49B2CC),
              secondary: Color(0xFF45A1E3), onSecondary: Color(
                  0xFF2579B4),
              error: Color(0xFFE70000), onError: Color(0xFFCB3B3B),
              background: Color(0xFFFFFFFF), onBackground: Color(0xFF989898),
              surface: Color(0xFF006FFF), onSurface: Color(0xFF040507)),
        ),
        // routes 설정
        initialRoute: '/',
        routes: {
          '/': (context) => Splash(),
          '/initareaname': (context) => InitAreaPage(),
          '/home': (context) => HomePage(),
          '/settings': (context) => SettingsPage(),
          '/connect': (context) => ConnectModePage(),
        },
      ),
    );
  }
}
