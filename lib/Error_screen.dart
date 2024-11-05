import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String message;

  ErrorDialog({required this.message}); // 생성자에서 문자열을 받음

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('오류'),
      content: Text(message), // 전달받은 메시지를 표시
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 팝업 닫기
          },
          child: Text('확인'),
        ),
      ],
    );
  }
}
