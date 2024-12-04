import 'package:airquant_monitor_local/widgets/alert_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utilities/shared_prefs.dart';
import '../../utilities/socket_timer.dart';

int cycle = 10;

class CycleEditPage extends StatefulWidget {
  const CycleEditPage({super.key});

  @override
  State<CycleEditPage> createState() => _CycleEditPageState();
}

class _CycleEditPageState extends State<CycleEditPage> {
  /// _loadData(): 현재 측정 주기를 가져오는 함수
  Future<void> _loadData() async {
    cycle = (await SharedPrefsUtils.getCycle())!;
  }

  @override
  Widget build(BuildContext context) {
    /// 1. _loadData()가 종료되면 측정 주기를 변경하는 Widget을 보여준다.
    return FutureBuilder(
        future: _loadData(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            /// 로딩 화면
            return CircularProgressIndicator();
          } else {
            /// 측정 주기 변경 UI
            return CycleEditWidget();
          }
        });
  }
}

class CycleEditWidget extends StatefulWidget {
  const CycleEditWidget({super.key});

  @override
  State<CycleEditWidget> createState() => _CycleEditWidgetState();
}

class _CycleEditWidgetState extends State<CycleEditWidget> {
  // 소켓 및 타이머 클래스 연결
  SocketTimer socketTimer = SocketTimer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          flex: 2,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
            child: Text('Data Cycle Setting',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600))
                .tr(),
          ),
        ),
        SizedBox(height: 10),
        Flexible(
          flex: 9,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 30, 500, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 20, 10),

                    /// 측정 주기 입력란
                    child: TextField(
                      style: TextStyle(fontSize: 22),
                      onChanged: (value) {
                        cycle = value.isNotEmpty ? int.parse(value) : 0;
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(suffixText: 'sec'.tr()),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      controller: TextEditingController(text: cycle.toString()),
                    ),
                  ),
                ),
                OutlinedButton(
                  style: TextButton.styleFrom(
                      fixedSize: Size(100, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0), // 버튼의 라운드 값을 설정
                      ),
                      side: BorderSide(color: Colors.blue)
                  ),

                  /// 저장 버튼: 10 ~ 300초 까지 설정
                  child: Text("Saved", style: TextStyle(fontSize: 20)).tr(),
                  onPressed: () {
                    if (cycle < 10 || 300 < cycle) {
                      showNoticeDialog(
                          context: context,
                          contents: 'Allow from 10s to 300s',
                          color: Colors.redAccent);
                    } else {
                      SharedPrefsUtils.setCycle(cycle);
                      socketTimer.updateCycle(context, true);
                      showNoticeDialog(
                          context: context,
                          contents: 'Successfully Saved',
                          color: Colors.blue);
                    }
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
