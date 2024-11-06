import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class Failed extends StatefulWidget {
  @override
  _FailedState createState() => _FailedState();
}

class _FailedState extends State<Failed> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
    ConfettiController(duration: const Duration(seconds: 1))..play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 실패 이미지 추가
                  SizedBox(height: 200),
                  Image.asset(
                    'assets/images/error.png', // 이미지 경로 (실패를 나타내는 이미지로 변경)
                    height: 150, // 이미지 높이 설정 (조정)
                  ),
                  SizedBox(height: 20), // 간격 조정
                  Text(
                    "실패했습니다!", // 실패 메시지 추가
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red, // 실패를 강조하기 위한 빨간색
                    ),
                  ),
                  SizedBox(height: 100),
                  // 다시 시도 버튼 추가
                  SizedBox(
                    width: 300, // 버튼의 가로 길이 설정
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // 이전 화면으로 돌아가기
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(227, 92, 92, 1), // 버튼 배경색 빨간색
                        minimumSize: Size(double.infinity, 60), // 버튼 높이 설정
                      ),
                      child: Text(
                        "다음엔 할 수 있어ㅠ",
                        style: TextStyle(
                          color: Colors.white, // 버튼 글자색 흰색
                          fontSize: 24, // 글자 크기 설정
                          fontWeight: FontWeight.bold, // 글자 굵기 설정
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
