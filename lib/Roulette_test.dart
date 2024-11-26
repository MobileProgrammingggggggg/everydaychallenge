import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: Roulette()));
}

class Roulette extends StatefulWidget {
  @override
  _RouletteState createState() => _RouletteState();
}

class _RouletteState extends State<Roulette> with SingleTickerProviderStateMixin {
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

  bool _isSpinning = false;

  void startSpin() {
    if (_isSpinning || _controller.isAnimating) return; // 중복 방지
    _isSpinning = true;

    const int minSpins = 4;
    const int maxSpins = 8;
    final spins = Random().nextInt(maxSpins - minSpins + 1) + minSpins;
    final totalRotation = spins * 2 * pi;

    _controller.forward(from: 0);
    _controller.addListener(() {
      setState(() {
        _rotation = totalRotation * _controller.value;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _isSpinning = false;

        final selectedIndex = calculateSelectedItemIndex();
        final selectedChallenge = items[selectedIndex];

        Navigator.pop(context, selectedChallenge); // 결과 반환
      }
    });
  }







  int calculateSelectedItemIndex() {
    return (((-(_rotation / (pi / 180)) + 270) % 360) ~/ 72) % items.length;
  }

  void showSelectedItemDialog(BuildContext context, int index) {
    final selectedChallenge = items[index];
    // 선택된 항목을 Navigator.pop으로 반환

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
