// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utilities/db_manager.dart';
import '../../utilities/excel.dart';
import '../../utilities/shared_prefs.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SpalshState();
}

class _SpalshState extends State<Splash> {
  double opacity = 0.0; // 초기 투명도 0
  bool? isGranted;

  @override
  void initState() {
    print("init~~~~~~~~");
    super.initState();
    _requestPermission();
    // logo 애니메이션
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        opacity = 1.0; // 투명도 1 변경
      });
    });
  }

  // 모든 파일에 접근 허용
  Future<void> _requestPermission() async {
    // DB 초기화
    await DBManager.initDB();

    print("request~~~~~~~");

    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;

    // 저장소 권한 확인
    PermissionStatus status = android.version.sdkInt < 33 ? await Permission.storage.status : PermissionStatus.granted;
    if (android.version.sdkInt >= 33) {
      print("----------------");
      await Permission.manageExternalStorage.request();
    } else {
      status = await Permission.storage.request();
    }



    print("status: $status");

    while (!status.isGranted) {
      await showDialog(
        context: context,
        barrierDismissible: false, // 배경 터치로 닫히지 않도록 설정
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('권한 요청'),
            content: Text('앱의 파일 관리 권한을 허용해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 취소 버튼 클릭 시 다이얼로그 닫기
                },
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // 설정 버튼 클릭 시 다이얼로그 닫기
                  print("status ${status}");
                  status = await Permission.storage.request();
                  Future.delayed(Duration(seconds: 1), () {});
                },
                child: Text('설정'),
              ),
            ],
          );
        },
      );

      // 상태가 허용되었는지 확인
      status = await Permission.storage.status;
      if (status.isGranted) {
        print("권한 허용 완료~~~~~~");
        break; // 권한이 허용되면 루프 종료
      }
    }

    // 권한이 허용된 경우 다음 화면으로 이동
    if (status.isGranted) {
      _navigateToNextScreen();
    }

    // isGranted = await SharedPrefsUtils.getIsGranted();
    // while (isGranted == false || isGranted == null) {
    //   await _showNotificationDialog();
    //   await _checkPermission();
    // }
    // await _navigateToNextScreen();
  }

  // 접근 허용
  Future<void> _checkPermission() async {
    PermissionStatus status = await Permission.manageExternalStorage.request();
    if (status == PermissionStatus.granted) {
      SharedPrefsUtils.setIsGranted(true); // 권한 설정했을 때 true로 변경
      isGranted = true;
    } else {
      print("==========isGranted가 false");
    }
  }

  // 파일 접근 권한 요청 : permission이 isDenied일 때 alert창
  Future<void> _showNotificationDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Notification").tr(),
          content: Text("File access is required to use the app.").tr(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Confirmation").tr(),
            ),
          ],
        );
      },
    );
  }

  // home 이동 및 초기 구역명 설정
  Future<void> _navigateToNextScreen() async {
    await SharedPrefsUtils.areaNameExists().then((result) async {
      // 초기 설정 정보 저장 또는 pass
      await SharedPrefsUtils.initialSetting();

      // 구역명 있으면 home screen 이동
      bool areaNameExists = result;

      // /// test 세팅 이동
      // Future.delayed(Duration(seconds: 2), () {
      //   Navigator.pushReplacementNamed(context, '/settings');
      // });
      //
      // return;

      if (areaNameExists) {
        print('구역명 설정 O -> 다음 화면');
        Future.delayed(Duration(seconds: 2), () {
          ExcelUtils.deleteOldFolder(context); // 1년 전 폴더 삭제
          // Navigator.pushReplacementNamed(context, '/home');
          Navigator.pushReplacementNamed(context, '/connect');
          // Navigator.pushReplacementNamed(context, '/settings');
        });
      } else {
        print('구역명 설정 x -> 초기 구역명 설정 화면');
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/initareaname');
          // Navigator.pushReplacementNamed(context, '/settings');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("build~~~~~~~~");
    return Scaffold(
        body: Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AnimatedOpacity(
              opacity: opacity,
              duration: Duration(seconds: 1), // 애니메이션 지속 시간 설정
              child: Image.asset(
                'assets/images/AirQuant_logo.png',
                width: 400,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
