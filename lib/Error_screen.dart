import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String message;

  ErrorDialog({required this.message}); // 생성자에서 문자열을 받음

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white, // 팝업 배경 흰색
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.black, width: 3), // 팝업 테두리 검은색
        borderRadius: BorderRadius.circular(20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Image.asset(
              'assets/images/error.png', // 이미지 경로
              height: 100, // 이미지 높이 설정
            ),
          ),
          SizedBox(height: 16), // 이미지와 메시지 사이의 간격
          Center(
            child: Text(
              message,
              textAlign: TextAlign.center, // 메시지 가운데 정렬
              style: TextStyle(
                color: Colors.black, // 글씨 색상 검은색
                fontWeight: FontWeight.bold, // 글씨 두껍게
                fontSize: 16, // 글자 크기 조정
              ),
            ),
          ),
        ],
      ),
      actions: [
        Center(
          child: SizedBox(
            width: double.infinity, // 버튼 가로 크기 최대화
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color.fromRGBO(92, 103, 227, 1), // 버튼 배경 파란색
                foregroundColor: Colors.white, // 버튼 글씨 흰색
                padding: EdgeInsets.symmetric(vertical: 16), // 버튼 세로 패딩 조정
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
              child: Text(
                '확인',
                style: TextStyle(
                  fontSize: 18, // 확인 글자 크기 조정
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}