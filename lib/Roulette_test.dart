import 'dart:math';
import 'package:flutter/material.dart';
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

  void startSpin() {
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
        showSelectedItemDialog(selectedItemIndex);
      });
    });
  }

  int calculateSelectedItemIndex() {
    // 270도를 기준으로 인덱스 계산 ㅅㅂ!!
    return (((-(_rotation / (pi / 180)) + 270) % 360) ~/ 72) % items.length;
  }

  void showSelectedItemDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("선택된 항목"),
          content: Text(items[index]),
          actions: [
            TextButton(
              child: Text("확인"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("룰렛 스피너")),
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Transform.rotate(
                    angle: _rotation, // 현재 회전 각도
                    child: CustomPaint(
                      size: Size(300, 300),
                      painter: RoulettePainter(items, colors),
                    ),
                  ),
                  // 역삼각형 마커
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
                onPressed: startSpin,
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

      // 각 항목 그리기
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // 항목 텍스트 그리기
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

    // 역삼각형 좌표
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
