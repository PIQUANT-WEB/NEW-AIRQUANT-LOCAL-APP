import 'package:airquant_monitor_local/storage/data_storage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ConnectModePage extends StatefulWidget {
  const ConnectModePage({super.key});

  @override
  State<ConnectModePage> createState() => _ConnectModePageState();
}

class _ConnectModePageState extends State<ConnectModePage> {
  final TextEditingController _ipAddressController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  bool isValidIpAddress(String ipAddress) {
    // 루프백 주소인 경우 거부
    if (ipAddress == '255.255.255.255') {
      return false;
    }

    // IP 주소를 점으로 분리
    List<String> parts = ipAddress.split('.');

    // IP 주소는 4개의 부분으로 구성되어야 함
    if (parts.length != 4) {
      return false;
    }

    // 각 부분이 0부터 255 사이의 숫자여야 함
    for (var part in parts) {
      try {
        int value = int.parse(part);
        if (value < 0 || value > 255) {
          return false;
        }
      } catch (e) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(150, 20, 150, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  height: 100,
                  child: Image.asset('assets/images/AirQuant_logo.png')),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 이미지
                        Positioned(
                          top: 50,
                          child: Opacity(
                            opacity: 0.4,
                            child: SizedBox(
                              width: 200,
                              height: 200,
                              child: Image.asset('assets/images/softap_img.png'),
                            ),
                          ),
                        ),
                        /// softAP 버튼
                        ElevatedButton(
                          onPressed: () {
                            DataStorage dataStorage = Provider.of<DataStorage>(
                                context,
                                listen: false);
                            dataStorage.setIp('192.168.4.1');
                            dataStorage.setPort(80);
                            print('ip 주소, port 설정 완료');

                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/home');
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            backgroundColor: Colors.transparent,
                            padding: const EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: const BorderSide(color: Colors.blue),
                            ),
                            minimumSize: Size(double.infinity, 350),
                            shadowColor: null,
                            elevation: 0,
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Soft AP connection',
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w700),
                              ).tr(),
                              Text('A mode that connects directly to the device.',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFF7C7C8D)))
                                  .tr(),
                            ],
                          ),
                        ),


                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Stack(
                    alignment: Alignment.center,
                      children: [
                        // 이미지
                        Positioned(
                          top: 50,
                          child: Opacity(
                            opacity: 0.4,
                            child: SizedBox(
                              width: 200,
                              height: 200,
                              child: Image.asset('assets/images/network_img.png'),
                            ),
                          ),
                        ),
                        /// 네트워크 버튼
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  title: SizedBox(
                                    height: 40,
                                    child: Text('Network Settings',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700),
                                            textAlign: TextAlign.center)
                                        .tr(),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: _ipAddressController,
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9.]')),
                                          ],
                                          textInputAction: TextInputAction.next,
                                          // 다음 입력창으로 이동
                                          onEditingComplete: () =>
                                              FocusScope.of(context).nextFocus(),
                                          // 다음 입력창으로 이동
                                          decoration: InputDecoration(
                                            hintText: 'IP Address',
                                            suffixStyle:
                                                const TextStyle(color: Colors.grey),
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        TextField(
                                          controller: _portController,
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: false), // 소수점 입력 불가
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9]')), // 숫자만 입력 가능
                                          ],
                                          decoration: InputDecoration(
                                            hintText: 'PORT NUMBER',
                                            suffixStyle:
                                                const TextStyle(color: Colors.grey),
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: SizedBox(
                                                width: double.infinity,
                                                height: 50,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    // 현재 페이지를 종료
                                                    Navigator.pop(context);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      elevation: 0,
                                                      foregroundColor: Colors.blue,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                5),
                                                        side: const BorderSide(
                                                            color: Colors.blue),
                                                      )),
                                                  child: Text(
                                                    'cancel',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.blue),
                                                  ).tr(),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                            Expanded(
                                              child: SizedBox(
                                                width: double.infinity,
                                                height: 50,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    String ipAddress =
                                                        _ipAddressController.text;
                                                    String port =
                                                        _portController.text;

                                                    if (!isValidIpAddress(
                                                        ipAddress)) {
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Invalid IP address',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color:
                                                                    Colors.white),
                                                          ).tr(),
                                                          duration:
                                                              Duration(seconds: 2),
                                                          padding:
                                                              EdgeInsets.all(15),
                                                        ),
                                                      );
                                                      return;
                                                    }

                                                    if (port.isEmpty) {
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Please enter PORT',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color:
                                                                    Colors.white),
                                                          ).tr(),
                                                          duration:
                                                              Duration(seconds: 2),
                                                          padding:
                                                              EdgeInsets.all(15),
                                                        ),
                                                      );
                                                      return;
                                                    }

                                                    DataStorage dataStorage =
                                                        Provider.of<DataStorage>(
                                                            context,
                                                            listen: false);
                                                    dataStorage.setIp(ipAddress);
                                                    dataStorage
                                                        .setPort(int.parse(port));
                                                    print('ip 주소, port 설정 완료');

                                                    Navigator.pop(context);
                                                    Navigator.pushNamed(
                                                        context, '/home');
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      elevation: 0,
                                                      foregroundColor: Colors.white,
                                                      backgroundColor: Colors.blue,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  5))),
                                                  child: Text(
                                                    'Check',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.white),
                                                  ).tr(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            backgroundColor: Colors.transparent,
                            padding: const EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: const BorderSide(color: Colors.blue),
                            ),
                            minimumSize: Size(double.infinity, 350),
                            shadowColor: null,
                            elevation: 0,
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Network Connection (WIFI/ETH)',
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w700),
                              ).tr(),
                              Text(
                                'Mode that connects over the network',
                                style: TextStyle(
                                    fontSize: 15, color: Color(0xFF7C7C8D)),
                              ).tr(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ipAddressController.dispose();
    _portController.dispose();
    super.dispose();
  }
}
