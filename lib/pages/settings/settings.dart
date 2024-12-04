import 'package:airquant_monitor_local/pages/settings/download.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:airquant_monitor_local/pages/home/home.dart';
import 'package:airquant_monitor_local/pages/settings/cycle_edit.dart';
import 'package:airquant_monitor_local/pages/settings/area_edit.dart';
import 'package:airquant_monitor_local/pages/settings/item_custom.dart';
import 'package:airquant_monitor_local/pages/settings/standard_edit.dart';

import '../../storage/data_storage.dart';

import 'package:easy_localization/easy_localization.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    ItemCustomPage(),
    StandardEditPage(),
    AreaEditPage(),
    CycleEditPage(),
    DownloadPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataStorage = Provider.of<DataStorage>(context, listen: true);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20.0),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Device Setting',
              style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.w600))
              .tr(),
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: WillPopScope(
            onWillPop: _onBackPressed,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                iconSize: 35,
                color: Colors.grey,
                onPressed: () {
                  _onBackPressed();
                },
              ),
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
          color: Color(0xFFFFFFFF),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 250,
                color: Colors.white30,
                // padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      title: const Text('Monitoring Item',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600))
                          .tr(),
                      selected: _selectedIndex == 0,
                      onTap: () {
                        _onItemTapped(0);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      title: const Text('Standard Setting',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600))
                          .tr(),
                      selected: _selectedIndex == 1,
                      onTap: () {
                        _onItemTapped(1);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      title: const Text('Area name Setting',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600))
                          .tr(),
                      selected: _selectedIndex == 2,
                      onTap: () {
                        _onItemTapped(2);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      title: const Text('Data Cycle Setting',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600))
                          .tr(),
                      selected: _selectedIndex == 3,
                      onTap: () {
                        _onItemTapped(3);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      title: const Text('Download',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600))
                          .tr(),
                      selected: _selectedIndex == 4,
                      onTap: () {
                        _onItemTapped(4);
                      },
                    ),
                    SizedBox(
                      height: 175,
                    ),
                    Container(
                        width: 250,
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // 시리얼 넘버, 갱신 시간
                          children: [
                            Text('SN : ${dataStorage.SN}',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey)),
                            SizedBox(
                              height: 10,
                            ),
                            Text('${'Renewal time'.tr()} : ${dataStorage.Date}',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey)),
                          ],
                        ))
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                width: 20,
                height: MediaQuery.of(context).size.height,
              ),
              Expanded(
                  child: Container(
                    child: _widgetOptions[_selectedIndex],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    // 리로딩
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    return true; // true를 반환하면 뒤로가기 허용
  }
}
