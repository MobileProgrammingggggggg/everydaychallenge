import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class Succeed extends StatefulWidget {
  @override
  _SucceedState createState() => _SucceedState();
}

class _SucceedState extends State<Succeed> {
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
                  // 축하 이미지 추가
                  SizedBox(height: 200),
                  Image.asset(
                    'assets/images/error.png', // 이미지 경로
                    height: 150, // 이미지 높이 설정 (조정)
                  ),
                  SizedBox(height: 100),
                  // 성공 버튼 추가
                  SizedBox(
                    width: 300, // 버튼의 가로 길이 설정
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // 이전 화면으로 돌아가기
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(92, 103, 227, 1), // 버튼 배경색 파란색
                        minimumSize: Size(double.infinity, 60), // 버튼 높이 설정
                      ),
                      child: Text(
                        "성공!",
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
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              blastDirection: -pi / 2, // 위쪽으로 폭죽이 터짐
              emissionFrequency: 0.05,
              numberOfParticles: 100,
              maxBlastForce: 50,
              minBlastForce: 10,
              gravity: 0.23,
            ),
          ),
        ],
      ),
    );
  }
}
