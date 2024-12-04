import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

void showNoticeDialog({
  required BuildContext context,
  required String contents,
  required Color color,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0), // round 값을 조절
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Notice',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ).tr(),
            SizedBox(
              height: 30,
            ),
            Text(contents).tr(),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color, // 버튼의 배경 색상
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0), // round 값을 조절
              ),
              minimumSize: Size(double.infinity, 40), // 버튼의 최소 크기
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close', style: TextStyle(fontSize: 16, color: Colors.white)).tr(),
          ),
        ],
      );
    },
  );
}
