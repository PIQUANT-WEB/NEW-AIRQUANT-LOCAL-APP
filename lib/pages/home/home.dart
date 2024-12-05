import 'dart:async';
import 'package:airquant_monitor_local/utilities/shared_prefs.dart';
import 'package:airquant_monitor_local/utilities/socket_timer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../storage/data_storage.dart';
import '../../utilities/sensor.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // 소켓 및 타이머 클래스 연결
  SocketTimer socketTimer = SocketTimer();

  // 와이파이 연결
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription; // wifi connection 확인

  late DataStorage dataStorage;

  @override
  void initState() {
    dataStorage = Provider.of<DataStorage>(context, listen: false);

    WidgetsBinding.instance!.addObserver(this);
    super.initState();
    print('init ----');
    _initConnectivity();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    });

    Sensor.getStandardList(context); // 각 공기질 항목 기준 가져오기
    // socketTimer.connectToSocket(context, true); // 소켓으로 디바이스 앱 먼저 연결
    print("@@@@@@@@@@@@@@ connectToSocket true");
    Future.delayed(Duration(seconds: 1), () {
      // socketTimer.connectToSocket(context, false);
      print("@@@@@@@@@@@@@@ connectToSocket false");

      // 타이머가 null 이면 타이머 실행
      if (socketTimer.getInitialTimer(context) == null) {
        socketTimer.connectToDeviceTimer(context); // 10초마다 소켓을 통해 기기로 데이터 전송
      } else {
        print("====getInitialTimer not null");
        if (socketTimer.getCheckCycle(context) == true) {
          print("====getCheckCycle true");
          socketTimer.cancelTimer(context); // 기존 타이머 삭제
          socketTimer.connectToDeviceTimer(context);
          socketTimer.updateExcelIndex(context); // 엑셀 인덱스 현재 시간으로 다시 생성
          socketTimer.updateCycle(context, false); // cycle 변경
        }
      }
      socketTimer.getCurrentTime(context); // 현재 시간 업데이트
    });
  }

  // wifi 연결 함수
  Future<void> _initConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
    } catch (error) {
      print("Error initializing connectivity: $error");
    }
  }

  // wifi 연결 업데이트 함수
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      print("con Stat: $result");
      _connectionStatus = result;
    });
  }

  @override
  void dispose() {
    print("home dispose ---- ");
    dataStorage.timer?.cancel();
    dataStorage.timer = null;
    dataStorage.cardData = [];
    WidgetsBinding.instance!.removeObserver(this);
    // _connectivitySubscription.cancel();
    socketTimer.cancelTimer(context);
    socketTimer.cancelCurrentTime(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataStorage = Provider.of<DataStorage>(context, listen: true);
    Color statusColor = Colors.transparent;
    final data = dataStorage.cardData;

    /// wifi가 연결이 돼있으면 softAP 사용하는걸로 간주
    /// ip, port 고정

    /// wifi 연결이 안되어있으면 이더넷 사용하는걸로 간주
    /// ip, port 입력받기 => 이더넷이면 입력받기 여부 변수 추가해서 UI 변경

    /// 그 다음 공통
    /// soket(ip, port) 연결해서 데이터 받아오기

    if (data!.isEmpty) {
      // 카드 데이터가 없을 때(데이터 불러 오지 못함)
      dataStorage.loading = true;
    } else {
      // 카드 데이터가 있을 때
      Sensor.calculateStatus(dataStorage);
      if (dataStorage.overallState == 'S') {
        statusColor = Color(0xFF7fd0ff);
      } else if (dataStorage.overallState == 'C') {
        statusColor = Color(0xFF69DA96);
      } else {
        statusColor = Color(0xFFE5604D);
      }
      dataStorage.loading = false;
    }

    /// wifi or ethernet flag 추가
    return Scaffold(
      // 1. 기기가 연결 되어 있고, 데이터가 들어 오는 지 체크
      body: !dataStorage.loading
          ?
          // 정상 실행 화면
          Container(
              padding: EdgeInsets.fromLTRB(40, 50, 40, 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 3,
                    child: Container(
                      color: statusColor,
                      child: LeftContainer(),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    flex: 7,
                    child: Container(
                      padding: EdgeInsets.all(15),
                      child: RightContainer(),
                    ),
                  ),
                ],
              ))
          :
          // 로딩 화면
          Center(
              child: SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 15,
                        backgroundColor: Color(0xFFFAFAFA),
                        strokeCap: StrokeCap.round,
                        color: Color(0xFF47D8FF),
                      ),
                      Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Loading data...',
                            style: TextStyle(fontSize: 20),
                          ).tr(),
                          SizedBox(height: 8),
                          Text(
                            'If it takes longer than 10 sec',
                            style: TextStyle(fontSize: 15),
                          ).tr(),
                          Text(
                            'Please check if the device is connected',
                            style: TextStyle(fontSize: 15),
                          ).tr(),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              // Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, '/connect');
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: const BorderSide(color: Colors.blue),
                              ),
                              minimumSize: Size(100, 50),
                              shadowColor: null,
                              elevation: 0,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'back',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                ).tr(),
                              ],
                            ),
                          ),
                        ],
                      )),
                    ],
                  ))),
    );
  }
}

// left container
class LeftContainer extends StatefulWidget {
  const LeftContainer({Key? key}) : super(key: key);

  @override
  State<LeftContainer> createState() => _LeftContainerState();
}

class _LeftContainerState extends State<LeftContainer> {
  @override
  Widget build(BuildContext context) {
    String? statusLogo;
    String? statusValue;

    final dataStorage = Provider.of<DataStorage>(context);
    try {
      if (dataStorage.overallState == 'S') {
        statusLogo = 'assets/images/Good_status.png';
        statusValue = 'GOOD';
      } else if (dataStorage.overallState == 'C') {
        statusLogo = 'assets/images/Normal_status.png';
        statusValue = 'NORMAL';
      } else {
        statusLogo = 'assets/images/Bad_status.png';
        statusValue = 'BAD';
      }
    } catch (error) {
      print("====left Container error : $error");
    }

    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            flex: 2,
            child: Container(
              // color: Colors.deepOrange,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Image.asset('assets/images/KRRI_logo.png', fit: BoxFit.cover),
            ),
          ),
          Flexible(
            flex: 7,
            child: Container(
              // color: Colors.greenAccent,
              padding: EdgeInsets.all(15),
              child: statusLogo != null ? Image.asset(statusLogo!, fit: BoxFit.cover) : Text(''),
            ),
          ),
          Flexible(
            flex: 3,
            child: SizedBox(
              child: SizedBox(
                child: Column(
                  children: [
                    Text(
                      statusValue ?? '',
                      style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(dataStorage.currentDate,
                        style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w700)),
                    SizedBox(
                      height: 5,
                    ),
                    Text(dataStorage.currentTime,
                        style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RightContainer extends StatefulWidget {
  @override
  _RightContainer createState() => _RightContainer();
}

// right container
class _RightContainer extends State<RightContainer> {
  String areaName = "";

  @override
  void initState() {
    super.initState();
    _loadAreaName();
  }

  // home 이동 및 초기 구역명 설정
  Future<void> _loadAreaName() async {
    final String? loadedAreaName = await SharedPrefsUtils.getAreaName();
    setState(() {
      areaName = loadedAreaName ?? ""; // 값이 null이면 빈 문자열로 설정
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataStorage = Provider.of<DataStorage>(context);

    // cards 데이터
    List<CardItems> cards = [];
    for (var items in dataStorage.cardData!) {
      String item = items['item'];
      String value = items['value'].toString();
      String unit = items["unit"];
      String description = items["description"];
      String status = items["status"];
      double ratio = items["ratio"];

      cards
          .add(CardItems(item: item, value: value, unit: unit, description: description, status: status, ratio: ratio));
    }

    return SizedBox(
      child: Column(
        children: [
          Flexible(
            flex: 1,
            child: SizedBox(
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    // width: 420,
                    child: Text(
                      areaName,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        style: TextButton.styleFrom(
                          fixedSize: Size(150, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0), // 버튼의 라운드 값을 설정
                          ),
                          side: BorderSide(color: Colors.blue), // 버튼의 border 색상을 설정
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/connect');
                        },
                        icon: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Icon(Icons.arrow_back, size: 23),
                        ),
                        label: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Text('back', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)).tr(),
                        ),
                      ),
                      SizedBox(width: 10),
                      OutlinedButton.icon(
                        style: TextButton.styleFrom(
                          fixedSize: Size(150, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0), // 버튼의 라운드 값을 설정
                          ),
                          side: BorderSide(color: Colors.blue), // 버튼의 border 색상을 설정
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/settings', arguments: "on");
                        },
                        icon: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Icon(Icons.settings, size: 23),
                        ),
                        label: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Text('Setting', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)).tr(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 11,
            child: SizedBox(
              child: GridView.count(
                crossAxisCount: 3,
                // 1개의 행에 보여질 개수
                childAspectRatio: 3 / 2.97,
                // 가로 세로 비율
                mainAxisSpacing: 15,
                // 수평 padding
                crossAxisSpacing: 15,
                // 수직 padding
                children: cards.map((card) => card as Widget).toList(),
              ),
            ),
          ),
          SizedBox(
            height: 35,
            child: Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              alignment: Alignment.topLeft,
              child: Text('${'Renewal time'.tr()} ${dataStorage.Date}', style: TextStyle(color: Color(0xff919191))),
            ),
          ),
        ],
      ),
    );
  }
}

// card
@immutable
class CardItems extends StatefulWidget {
  String item = '';
  dynamic value;
  String unit = '';
  String description = '';
  String status = '';
  double ratio;

  CardItems({
    super.key,
    required this.item,
    required this.value,
    required this.unit,
    required this.description,
    required this.status,
    required this.ratio,
  });

  @override
  State<CardItems> createState() => _CardItemsState();
}

class _CardItemsState extends State<CardItems> {
  @override
  Widget build(BuildContext context) {
    final dataStorage = Provider.of<DataStorage>(context);
    Color statusColor = Colors.transparent;
    String statusText = '';

    if (widget.status == 'S') {
      statusColor = Color(0xFF7fd0ff);
      statusText = "GOOD".tr();
    } else if (widget.status == 'C') {
      statusColor = Color(0xFF69DA96);
      statusText = "NORMAL".tr();
    } else {
      statusColor = Color(0xFFE5604D);
      statusText = "BAD".tr();
    }

    // cards 데이터
    List<CardItems> cards = [];
    for (var items in dataStorage.cardData!) {
      String item = items['item'];
      String value = items['value'].toString();
      String unit = items["unit"];
      String description = items["description"];
      String status = items["status"];
      double ratio = items["ratio"];

      cards
          .add(CardItems(item: item, value: value, unit: unit, description: description, status: status, ratio: ratio));
    }
    double statusRatio;

    // 퍼센트 설정
    if (widget.status == 'S') {
      statusRatio = (widget.ratio / 25.0) * 100.0;
    } else if (widget.status == 'C') {
      statusRatio = 25 + (widget.ratio / 25.0) * 100.0;
    } else {
      statusRatio = 50 + (widget.ratio / 25.0) * 100.0;
    }

    return Container(
      // width: 100,
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      height: 50,
      decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 5.0,
              spreadRadius: 0.0,
              offset: const Offset(0, 7),
            )
          ]),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 8,
                ),
                Text('${widget.item.tr()} (${widget.unit})',
                    style: TextStyle(fontSize: 19, letterSpacing: -1, fontWeight: FontWeight.w500)),
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: 250,
                  height: 170,
                  child: SfRadialGauge(axes: <RadialAxis>[
                    RadialAxis(
                        minimum: 0,
                        maximum: 100,
                        showLabels: false,
                        showTicks: false,
                        startAngle: 150,
                        endAngle: 30,
                        axisLineStyle: AxisLineStyle(
                          thickness: 0.33,
                          cornerStyle: CornerStyle.bothFlat, //  bothCurve 둥글게
                          color: Color.fromARGB(30, 0, 169, 181),
                          thicknessUnit: GaugeSizeUnit.factor,
                        ),
                        pointers: <GaugePointer>[
                          RangePointer(
                            value: statusRatio,
                            // progressValue
                            width: 0.33,
                            sizeUnit: GaugeSizeUnit.factor,
                            cornerStyle: CornerStyle.bothFlat,
                            color: statusColor,
                          ),
                          MarkerPointer(
                            value: statusRatio, //progressValue
                            markerType: MarkerType.circle,
                            color: Color(0xFF87e8e8),
                            markerWidth: 0.33,
                          )
                        ],
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                              positionFactor: 0.7,
                              angle: 90,
                              widget: Column(children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                      fontSize: 21, color: statusColor, fontWeight: FontWeight.w600, letterSpacing: -1),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  widget.value, //progressValue
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  widget.unit, //progressValue
                                  style: TextStyle(fontSize: 12),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                widget.description != ''
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              color: Colors.greenAccent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            widget.description.tr(),
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      )
                                    : Text('')
                              ]))
                        ]),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
