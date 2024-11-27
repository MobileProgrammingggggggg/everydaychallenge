import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:particle_field/particle_field.dart';
// 추후 particle 폭죽 이벤트 추가 예정

// https://chowonpapa.tistory.com/entry/%EA%B0%81%EB%8F%84%EA%B3%84
// 프로그래밍의 각도계 메커니즘...

void main() {
  runApp(MaterialApp(home: Roulette()));
}

class Roulette extends StatefulWidget {
  @override
  _RouletteState createState() => _RouletteState();
}

class _RouletteState extends State<Roulette>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotation = 0.0;

  final List<String> items = [
    "물 2잔 마시기",
    "10키로 걷기",
    "2키로 뛰기",
    "숨 쉬기",
    "영단어 1개 암기"
  ];
  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  bool _isSpinning = false; // 룰렛 회전 중인지 여부

  void startSpin() {
    if (_isSpinning) return; // 이미 회전 중이면 실행하지 않음
    _isSpinning = true; // 회전 시작 시 비활성화

    // 변수 정의
    const int minSpins = 4;
    const int maxSpins = 8;
    const int spinDuration = 3000; // 애니메이션 지속 시간 (밀리초)
    const double decelerationFactor = 0.2; // 감속 계수
    const int resultDelay = 300; // 결과 메시지 지연 시간 (밀리초)
    final spins =
        Random().nextInt(maxSpins - minSpins + 1) + minSpins; // spins는 변위에서 랜덤
    final totalRotation = spins * 2 * pi;

    // 애니메이션 시작
    _controller.forward(from: 0);
    _controller.addListener(() {
      setState(() {
        // 회전 속도를 줄여 자연스럽게 멈추도록 설정
        double deceleration =
            (maxSpins - _controller.value * (maxSpins - minSpins)) *
                decelerationFactor; // 감속 조정
        _rotation =
            totalRotation * _controller.value * deceleration; // 회전 각도 업데이트
      });
    });

    // 스피닝 종료 후 선택된 항목 표시
    final duration =
        spinDuration * (1 - (1 - _controller.value) * decelerationFactor);
    Future.delayed(Duration(milliseconds: duration.round()), () {
      _controller.stop();
      final selectedItemIndex = calculateSelectedItemIndex();
      // 선택된 항목 표시 메시지 지연
      Future.delayed(Duration(milliseconds: resultDelay), () {
        _isSpinning = false; // 회전 종료 시 활성화
        showSelectedItemDialog(context, selectedItemIndex);
        setState(() {}); // 상태 업데이트
      });
    });
  }

  int calculateSelectedItemIndex() {
    return (((-(_rotation / (pi / 180)) + 270) % 360) ~/ 72) % items.length;
  }

  void showSelectedItemDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.black, width: 3),
          ),
          child: Stack(
            children: [
              // 배경 이미지 (좌측 하단으로 배치)
              Positioned(
                bottom: 3, // 하단에 배치
                left: 0, // 왼쪽에 배치
                child: Image.asset(
                  'assets/images/left_good.png', // 배경 이미지
                  width: 120,
                ),
              ),
              Positioned(
                bottom: 3, // 하단에 배치
                right: 0, // 왼쪽에 배치
                child: Image.asset(
                  'assets/images/right_good.png', // 배경 이미지
                  width: 120,
                ),
              ),
              // 다이얼로그 내용 (문구와 텍스트)
              Container(
                width: 400, // 고정된 가로 크기
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 상단에 추가된 문구 (둥근 배경 포함)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 40),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6C9D1), // 배경 색상
                        borderRadius: BorderRadius.circular(20), // 둥근 모서리
                      ),
                      child: const Text(
                        '오늘의 챌린지!!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.pinkAccent, // 글씨 색상
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24), // 문구와 아이템 텍스트 사이의 간격
                    // 아이템 텍스트
                    Text(
                      '${items[index]}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 24), // 텍스트와 버튼 사이의 간격
                    // 확인 버튼을 중앙에 배치
                    Center(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF5C67E3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        onPressed: () {
                          final selectedChallenge = items[index]; // 선택된 항목 가져오기
                          Navigator.of(context)
                              .pop(selectedChallenge); // 값을 반환하며 팝
                        },
                        child: const Text(
                          '확인',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).then((selectedChallenge) {
      if (selectedChallenge != null) {
        // 다이얼로그가 닫히고 선택된 값을 상위 화면에서 받아옴
        Navigator.of(context).pop(selectedChallenge); // 상위 화면도 닫으며 값 전달
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("챌린지 룰렛 돌리기")),
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Transform.rotate(
                    angle: _rotation,
                    child: CustomPaint(
                      size: Size(300, 300),
                      painter: RoulettePainter(items, colors),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: CustomPaint(
                      size: Size(30, 20),
                      painter: TrianglePainter(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSpinning ? null : startSpin,
                child: Text("Spin"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class RoulettePainter extends CustomPainter {
  final List<String> items;
  final List<Color> colors;

  RoulettePainter(this.items, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    for (int i = 0; i < items.length; i++) {
      paint.color = colors[i];
      final startAngle = (i * 72) * (pi / 180);
      final sweepAngle = (72 * pi / 180);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: items[i],
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final x = center.dx +
          (radius / 2) * cos(startAngle + sweepAngle / 2) -
          textPainter.width / 2;
      final y = center.dy +
          (radius / 2) * sin(startAngle + sweepAngle / 2) -
          textPainter.height / 2;
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.pink;

    final path = Path()
      ..moveTo(size.width / 2, 48)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;

  GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade100, Colors.blue.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
