import 'package:flutter/material.dart';
import '../../utilities/shared_prefs.dart';

import 'package:easy_localization/easy_localization.dart';

import '../../widgets/alert_dialog.dart';

String areaName = '';
List<String> areaNames = [];
bool showRecentAreaNames = false;

/// 구역명 변경 페이지
class AreaEditPage extends StatefulWidget {
  const AreaEditPage({super.key});

  @override
  State<AreaEditPage> createState() => _AreaEditPageState();
}

class _AreaEditPageState extends State<AreaEditPage> {
  /// _loadData(): 현재 구역명과 최근 구역명 리스트를 가져오는 함수
  Future<void> _loadData() async {
    areaName = (await SharedPrefsUtils.getAreaName())!;
    areaNames = (await SharedPrefsUtils.getAreaNames())!;
  }

  @override
  Widget build(BuildContext context) {
    /// 1. _loadData()가 종료되면 구역명을 변경하는 Widget을 보여준다.
    return FutureBuilder(
      future: _loadData(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          /// 로딩 화면
          return CircularProgressIndicator();
        } else {
          /// 구역명 변경 UI
          return AreaEditWidget();
        }
      },
    );
  }
}

class AreaEditWidget extends StatefulWidget {
  const AreaEditWidget({super.key});

  @override
  State<AreaEditWidget> createState() => _AreaEditWidgetState();
}

class _AreaEditWidgetState extends State<AreaEditWidget> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          flex: 1,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
            child: Text('Area name Setting',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600))
                .tr(),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Flexible(
          flex: 9,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 30, 500, 0),
            child: Form(
              key: formKey,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 20, 10),

                          /// 구역명 입력란
                          child: TextFormField(
                            style: TextStyle(fontSize: 22),
                            autovalidateMode: AutovalidateMode.always,
                            onSaved: (value) {
                              setState(() {
                                areaName = value!;
                              });
                            },
                            controller: TextEditingController(text: areaName),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty ||
                                  RegExp(r'[\\/:*?"<>|]').hasMatch(value)) {
                                return "Please enter the right area name".tr();
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: areaName,

                              /// 최근 구역명 리스트를 조회하는 아이콘
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showRecentAreaNames = !showRecentAreaNames;
                                  });
                                },
                                icon: Icon(Icons.history , color: Colors.grey),
                              ),
                            ),
                          ),
                        ),

                        /// true면 리스트, false면 빈 widget을 보여줌
                        showRecentAreaNames
                            ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: areaNames.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(areaNames[index]),
                              onTap: () {
                                setState(() {
                                  areaName = areaNames[index];
                                  showRecentAreaNames = false;
                                });
                              },
                            );
                          },
                        )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Column(
                      children: [
                        OutlinedButton(
                          style: TextButton.styleFrom(
                              fixedSize: Size(100, 50), // 버튼의 크기를 고정
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0), // 버튼의 라운드 값을 설정
                              ),
                              side: BorderSide(color: Colors.blue)
                          ),
                          child:
                          Text("Saved", style: TextStyle(fontSize: 20)).tr(),
                          onPressed: () {
                            /// shared_prefs 저장소에 구역명과, 최근 구역명 리스트를 update
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();

                              setState(() {
                                if (!areaNames.contains(areaName)) {
                                  areaNames.add(areaName);
                                }
                                if (areaNames.length > 5) {
                                  areaNames.removeAt(0);
                                }

                                SharedPrefsUtils.setAreaName(areaName);
                                SharedPrefsUtils.setAreaNames(areaNames);
                              });

                              /// 저장 완료 알림
                              showNoticeDialog(
                                  context: context,
                                  contents: 'Successfully Saved',
                                  color: Colors.blue);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
