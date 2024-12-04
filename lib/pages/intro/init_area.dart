import 'package:airquant_monitor_local/utilities/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class InitAreaPage extends StatefulWidget {
  const InitAreaPage({super.key});

  @override
  State<InitAreaPage> createState() => _InitAreaPageState();
}

class _InitAreaPageState extends State<InitAreaPage> {
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String areaName = '';
    List<String> areaNames = [];

    return Scaffold(
        body: SafeArea(
          child: Form(
            key: formKey,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(30),
                width: 500,
                height: 270,
                // color: Colors.orange,
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
                child: Column(
                  children: [
                    Text('Area name Setting',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black))
                        .tr(),
                    SizedBox(height: 10),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.always,
                      onSaved: (value) {
                        setState(() {
                          areaName = value as String;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty ||
                            RegExp(r'[\\/:*?"<>|]').hasMatch(value)) {
                          return "Please enter the right area name".tr();
                        }
                        return null;
                      },
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'ex) K-water office'.tr()),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // 버튼의 배경 색상
                          minimumSize: Size(double.infinity, 50), // 버튼의 최소 크기
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0), // 원하는 radius 값
                          ),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            // 구역 설정
                            areaNames.add(areaName);
                            await SharedPrefsUtils.setAreaName(areaName);
                            await SharedPrefsUtils.setAreaNames(areaNames);
                            // Navigator.pushReplacementNamed(context, '/home');
                            Navigator.pushReplacementNamed(context, '/connect');
                          }
                        },
                        child: Text(
                          'Enter',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ).tr())
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}