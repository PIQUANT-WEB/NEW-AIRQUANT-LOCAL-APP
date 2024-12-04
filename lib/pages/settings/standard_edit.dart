import 'package:airquant_monitor_local/widgets/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utilities/common_data.dart';
import '../../utilities/shared_prefs.dart';
import 'package:easy_localization/easy_localization.dart' as localized;

Map<String, Map<int, String>> itemStandards = <String, Map<int, String>>{};
List<String> measureItems = CommonData.measureItems;
List<String> exceptionItems = CommonData.exceptionItems;

class StandardEditPage extends StatefulWidget {
  const StandardEditPage({super.key});

  @override
  State<StandardEditPage> createState() => _StandardEditPageState();
}

class _StandardEditPageState extends State<StandardEditPage> {
  /// _loadData(): 현재 기준을 불러오는 함수
  Future<void> _loadData() async {
    for (String item in measureItems) {
      /// values == ["35", "60", "10", "", "%RH", "표준 40~60%RH"]
      /// itemStandards["HUMID"] == {0 : "35", 1 : "60", 2 : "10", 3 : "" }
      /// index 0 ~ 3은 SAFE_MIN, SAFE_MAX, CAUTION, WARNING 을 가리킴
      List<String> values = (await SharedPrefsUtils.getStandards(item))!;
      itemStandards[item] = {};
      for (int idx = 0; idx < 4; idx++) {
        itemStandards[item]![idx] = values[idx];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    /// 1. _loadData()가 종료되면 기준을 변경하는 Widget을 보여준다.
    return FutureBuilder(
        future: _loadData(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            /// 로딩 화면
            return CircularProgressIndicator();
          } else {
            /// 기준 변경 UI
            return StandardEditWidget();
          }
        });
  }
}

class StandardEditWidget extends StatefulWidget {
  const StandardEditWidget({super.key});

  @override
  State<StandardEditWidget> createState() => _StandardEditWidgetState();
}

class _StandardEditWidgetState extends State<StandardEditWidget> {
  Future<void> updateItemStandards() async {
    for (MapEntry entry in itemStandards.entries) {
      String item = entry.key;
      Map<int, String> newStandard = entry.value;
      List<String> itemStandard = (await SharedPrefsUtils.getStandards(item))!;

      for (MapEntry innerEntry in newStandard.entries) {
        itemStandard[innerEntry.key] = innerEntry.value;
      }

      await SharedPrefsUtils.setStandard(item, itemStandard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              flex: 2,
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Standard Setting',
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
                                  content: SizedBox(
                                    width: 1000,
                                    height: 600,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                            height: 170,
                                            child: Image.asset('assets/images/help/standard_1.png')),
                                        Text('Safety is 20~30 and caution is ±3').tr(),
                                        SizedBox(height: 5),
                                        Text('±').tr(),
                                        SizedBox(height: 20),
                                        SizedBox(
                                            height: 170,
                                            child: Image.asset('assets/images/help/standard_2.png')),
                                        Text('Caution is 1500 and warning is 3000').tr(),
                                        SizedBox(height: 5),
                                        Text('Values from 1500 mean caution, and values from 3000 mean warning').tr(),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // 다이얼로그 닫기
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

                    /// 저장 버튼
                    OutlinedButton(
                      style: TextButton.styleFrom(
                          fixedSize: Size(100, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0), // 버튼의 라운드 값을 설정
                          ),
                          side: BorderSide(color: Colors.blue)
                      ),
                      child: Text("Saved", style: TextStyle(fontSize: 20)).tr(),
                      onPressed: () async {
                        bool isEditable = true;

                        for (MapEntry entry in itemStandards.entries) {
                          String item = entry.key;
                          Map<int, String> values = entry.value;

                          if (values.values.contains(' ')) {

                            showNoticeDialog(
                                context: context,
                                contents: 'Please enter the value',
                                color: Colors.redAccent);
                            isEditable = false;
                            break;
                          }
                          if (exceptionItems.contains(item)) {
                            int safeMin = int.parse(values[0]!);
                            int safeMax = int.parse(values[1]!);
                            if (safeMin >= safeMax) {
                              showNoticeDialog(
                                  context: context,
                                  contents: 'The safe range is wrong',
                                  color: Colors.redAccent);
                              isEditable = false;
                              break;
                            }
                          } else {
                            int caution = int.parse(values[2]!);
                            int warning = int.parse(values[3]!);
                            if (caution >= warning) {
                              showNoticeDialog(
                                  context: context,
                                  contents: 'less than the scope of caution',
                                  color: Colors.redAccent);
                              isEditable = false;
                              break;
                            }
                          }
                        }

                        /// 예외 처리에 걸리지 않으면 저장
                        if (isEditable) {
                          await updateItemStandards();
                          if (context.mounted) {
                            showNoticeDialog(
                                context: context,
                                contents: 'Successfully Saved',
                                color: Colors.blue);
                          }
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
              flex: 9,
              child: GestureDetector(
                onTap: () {
                  /// 다른 화면 터치시에 키보드 내려감
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    child: StandardDataTable(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 텍스트 width값 유동적으로 변환
double calculateTextWidth(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection?.rtl,       // 텍스트 방향 설정(없으면 안됨)
  )..layout();
  return textPainter.width;
}

class StandardDataTable extends StatefulWidget {
  const StandardDataTable({super.key});
  @override
  State<StandardDataTable> createState() => _StandardDataTableState();
}

class _StandardDataTableState extends State<StandardDataTable> {
  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingRowColor:
      MaterialStateColor.resolveWith((states) => Color(0xffe3e3e3)),
      columns: _getDataColumns(),
      rows: _getDataRows(),
      dataRowMaxHeight: 130,
    );
  }

  /// table columns
  List<DataColumn> _getDataColumns() {
    return [
      DataColumn(label: Text('Item', style: TextStyle(fontSize: 20)).tr()),
      for (String item in measureItems)
        DataColumn(
          label: Align(
            alignment: Alignment.center,
            child: Container(
              alignment: Alignment.centerRight,
              width: calculateTextWidth(item.tr(), TextStyle(fontSize: 20)),  // 70
              // width: 160,  // 70
              child: Text(
                item.tr(),
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
    ];
  }

  /// table rows
  List<DataRow> _getDataRows() {
    return [
      /// 안전 관련 row
      DataRow(cells: [
        DataCell(Text('Safe', style: TextStyle(fontSize: 20)).tr()),
        for (String item in measureItems)
          DataCell(Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _createDataCellElement(
                  item: item,
                  idx: 0,
                  isTextField: exceptionItems.contains(item),
                  isSuffix: true,
                ),
                _createDataCellElement(
                  item: item,
                  idx: 1,
                  isTextField: exceptionItems.contains(item),
                ),
              ],
            ),
          )),
      ]),

      /// 주의 관련 row
      DataRow(cells: [
        DataCell(Align(
          alignment: Alignment.center,
          child: Text(
            'Caution',
            style: TextStyle(fontSize: 20),
          ).tr(),
        )),
        for (String item in measureItems)
          DataCell(Align(
            alignment: Alignment.center,
            child: _createDataCellElement(
              item: item,
              idx: 2,
              isTextField: true,
              isPrefix: exceptionItems.contains(item),
            ),
          )),
      ]),

      /// 위험 관련 row
      DataRow(cells: [
        DataCell(Text('Warning', style: TextStyle(fontSize: 20)).tr()),
        for (String item in measureItems)
          DataCell(
              Align(
                alignment: Alignment.center,
                child: _createDataCellElement(
                  item: item,
                  idx: 3,
                  isTextField: !exceptionItems.contains(item),
                ),
              )),
      ]),
    ];
  }

  /// return Text or TextField
  Widget _createDataCellElement({
    required int idx,
    required String item,
    bool isTextField = false,
    bool isPrefix = false,
    bool isSuffix = false,
  }) {
    TextEditingController controller = TextEditingController(
      text: itemStandards[item]?[idx],
    );

    return SizedBox(
      width: 70,
      child: isTextField
          ? Padding(
        // 아름 페딩 8.0 지움
        padding: const EdgeInsets.all(0),
        child: TextField(
          // keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
          ],
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
          decoration: InputDecoration(
            isCollapsed: true,
            prefix: isPrefix ? Text('±') : null,
            suffix: isSuffix ? Text('~') : null,
          ),
          controller: controller,
          onChanged: (value) {
            value = value.isEmpty ? ' ' : value;
            itemStandards[item]![idx] = value;
          },
        ),
      )
          : Text(
        itemStandards[item]?[idx] ?? '',
        textAlign: TextAlign.center,
      ),
    );
  }
}
