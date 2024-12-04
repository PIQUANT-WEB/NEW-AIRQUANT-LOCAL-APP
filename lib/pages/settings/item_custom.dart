import 'package:airquant_monitor_local/widgets/alert_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../utilities/common_data.dart';
import '../../utilities/shared_prefs.dart';

List<String> displayItems = [];
List<String> measureItems = CommonData.measureItems;

class ItemCustomPage extends StatefulWidget {
  const ItemCustomPage({super.key});

  @override
  State<ItemCustomPage> createState() => _ItemCustomPageState();
}

class _ItemCustomPageState extends State<ItemCustomPage> {
  /// _loadData(): 모니터링 항목 리스트를 가져오는 함수
  Future<void> _loadData() async {
    displayItems = (await SharedPrefsUtils.getDisplayItems())!;
  }

  @override
  Widget build(BuildContext context) {
    /// 1. _loadData()가 종료되면 모니터링 항목 커스텀 Widget을 보여준다.
    return FutureBuilder(
        future: _loadData(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            /// 로딩 화면
            return CircularProgressIndicator();
          } else {
            /// 모니터링 항목 커스텀 UI
            return ItemCustomWidget();
          }
        });
  }
}

class ItemCustomWidget extends StatefulWidget {
  const ItemCustomWidget({super.key});

  @override
  State<ItemCustomWidget> createState() => _ItemCustomWidgetState();
}


class _ItemCustomWidgetState extends State<ItemCustomWidget> {



  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          flex: 2,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Monitoring Item',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w600))
                        .tr(),
                    SizedBox(width: 15),

                    /// 도움말
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white, // 배경색을 흰색으로 설정
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0), // round 값을 조절
                              ),
                              title: Text('HELP', style: TextStyle(fontSize: 25),).tr(),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        showHelp('assets/images/help/finedust.png',
                                            'PM025'.tr(), [
                                              'Dust smaller than 2.5 ㎛'.tr(),
                                              'WHO-designated class 1 carcinogen'.tr(),
                                              'Ministry of Environment 50 ㎍/㎥ or less'.tr(),
                                            ]),
                                        SizedBox(
                                          width: 20,
                                        ),

                                        showHelp('assets/images/help/finedust.png',
                                            'PM100'.tr(), [
                                              'Dust smaller than 10 ㎛'.tr(),
                                              'WHO-designated class 1 carcinogen'.tr(),
                                              'Ministry of Environment 100 ㎍/㎥ or less'.tr(),
                                            ]),
                                        // SizedBox(
                                        //   width: 20,
                                        // ),
                                        // showHelp('assets/images/help/co2.png', 'CO2'.tr(), [
                                        //   'Representative greenhouse gases'.tr(),
                                        //   'Increase fatigue and decrease cognitive functions'.tr(),
                                        //   'Ministry of Environment 1,000 ppm or less'.tr(),
                                        // ]),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: [
                                        showHelp('assets/images/help/voc.png', 'TVOC'.tr(), [
                                          'Liquid or gaseous organic compounds'.tr(),
                                          'Exacerbation of existing allergic diseases'.tr(),
                                          'Ministry of Environment 500 ㎍/㎥ or less'.tr(),
                                        ]),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        showHelp('assets/images/help/co2.png', 'CO2'.tr(), [
                                          'Representative greenhouse gases'.tr(),
                                          'Increase fatigue and decrease cognitive functions'.tr(),
                                          'Ministry of Environment 1,000 ppm or less'.tr(),
                                        ]),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: [
                                        showHelp('assets/images/help/co.png', 'NO2'.tr(), [
                                          'A reddish-brown, toxic gas with a pungent, strong odor'.tr(),
                                          'Increase irritation of eyes'.tr(),
                                          'Ministry of Environment 0.1 ppm or less'.tr(),
                                        ]),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        showHelp('assets/images/help/co.png',
                                            'CO'.tr(), [
                                              'Colorless, odorless, tasteless toxic gas'
                                                  .tr(),
                                              'Decrease brain function'.tr(),
                                              'Ministry of Environment 10 ppm or less'
                                                  .tr(),
                                            ]),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: [
                                        showHelp(
                                            'assets/images/help/tempe.png', 'TEMPE'.tr(), [
                                          'Required for indoor temperature control'.tr(),
                                          'Proper indoor temperature'.tr(),
                                        ]),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        showHelp('assets/images/help/humidity.png',
                                            'HUMID'.tr(), [
                                              'High humidity'.tr(),
                                              'Low humidity'.tr(),
                                            ]),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        showHelp('assets/images/help/co.png', 'SO2'.tr(), [
                                          'A colorless, irritating, strong-smelling fluid gas'.tr(),
                                          'Increase irritation of eyes'.tr(),
                                          'Ministry of Environment 0.15 ppm or less'.tr(),
                                        ]),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Close', style: TextStyle(fontSize: 22),).tr(),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Icon(Icons.info_outline,
                          color: Color(0xFFBEBEBE), size: 28),
                    ),
                  ],
                ),
                OutlinedButton(
                  style: TextButton.styleFrom(
                      fixedSize: Size(100, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0), // 버튼의 라운드 값을 설정
                      ),
                      side: BorderSide(color: Colors.blue)
                  ),

                  /// 저장 버튼: 선택된 항목이 6개일 때만 저장함.
                  child: Text("Saved", style: TextStyle(fontSize: 20)).tr(),
                  onPressed: () {
                    if (displayItems.length == 6) {
                      SharedPrefsUtils.setDisplayItems(displayItems);
                      showNoticeDialog(
                          context: context,
                          contents: 'Successfully Saved',
                          color: Colors.blue);
                    } else {
                      showNoticeDialog(
                          context: context,
                          contents: 'Please Select the 6 items',
                          color: Colors.redAccent);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Flexible(
          flex: 10,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            // height: 500,
            child: GridView.builder(
              itemCount: measureItems.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                // 1행에 보여줄 갯수
                crossAxisCount: 3,
                childAspectRatio: 3 / 3,
                mainAxisExtent: 70, // 버튼 높이
                mainAxisSpacing: 20, // 높이 여백
                crossAxisSpacing: 15,
              ),
              itemBuilder: (context, index) {
                String item = measureItems[index];
                bool isItemInDisplayItems = displayItems.contains(item);

                /// 항목 버튼
                return Stack(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: isItemInDisplayItems
                              ? Color(0xFF3A98EF)
                              : Colors.white,
                          fixedSize: Size(270, 60)),
                      onPressed: () {
                        setState(() {
                          /// display 항목에 포함된 경우 선택 해제
                          if (isItemInDisplayItems) {
                            displayItems.remove(item);
                            /// 선택
                          } else {
                            if (displayItems.length < 6) {
                              displayItems.add(item);
                            } else {
                              showNoticeDialog(
                                  context: context,
                                  contents: 'Please Select the 6 items',
                                  color: Colors.redAccent);
                            }
                          }
                        });
                      },
                      child: Text(
                        item.tr(),
                        style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold,
                          color: isItemInDisplayItems
                              ? Colors.white
                              : Color(0xFF3A98EF),
                        ),
                      ),
                    ),

                    /// display 순서: list index 활용
                    Positioned(
                      left: 10,
                      top: 15,
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isItemInDisplayItems
                                  ? Color(0xFF004C94)
                                  : Colors.transparent),
                          child: Align(
                            alignment: Alignment.center,
                            child: isItemInDisplayItems
                                ? Text(
                              '${displayItems.indexOf(item) + 1}',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white),
                              textAlign: TextAlign.center,
                              // textDirection: TextDirection.ltr,
                            )
                                : Text(''),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        )
      ],
    );
  }

  static Container showHelp(String img, String item, List<String> contents) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 500,
                    height: 40,
                    // color: Colors.redAccent,
                    child: Row(
                      children: [
                        Image.asset(img),
                        SizedBox(
                          width: 10,
                        ),
                        Text(item, style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 500,
                    height: 115,
                    // color: Colors.blue,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: contents
                          .map((content) =>
                          Text(content, style: TextStyle(fontSize: 15)))
                          .toList(),
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
