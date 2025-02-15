import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Ask_again_screen.dart';
import 'Error_screen.dart';
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

class _RouletteState extends State<Roulette> with TickerProviderStateMixin {
  late AnimationController _controller;
  double _rotation = 0.0;

  List<String> items = []; // Firebase에서 가져온 항목들
  bool _isLoading = true; // 데이터 로딩 상태 표시
  List<String> savedDocuments = []; // 저장된 문서 번호들

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Color> colors = [
    Color(0xFFFFA7C1), // 약간 더 강한 밝은 핑크 (밝기 올림)
    Color(0xFFF89D7C), // 부드러운 핑크, 오렌지 빛이 섞인 느낌
    Color(0xFFFFB5B5), // 연한 핑크, 더욱 밝고 부드러운 느낌
    Color(0xFFFF9A8D), // 살구 핑크, 톤 다운된 느낌
    Color(0xFFFF7B7B), // 베이지 핑크, 매우 밝고 부드러운 느낌
  ];

  @override
  void initState() {
    super.initState();
    _fetchChangeTickets();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // 애니메이션 컨트롤러 초기화
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300), // 애니메이션 지속 시간
    );

    // 애니메이션 초기화
    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.4).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // 애니메이션 값에 따라 offset 초기화
    _offsetAnimation = Tween<Offset>(
      begin: Offset(0, 0), // 애니메이션 시작 위치
      end: Offset(0, 80), // 애니메이션 끝 위치 (y축으로 이동)
    ).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _fetchChallengeItems(); // 데이터 로드 함수 호출
  }

  bool isUpdating = false;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. 현재 로그인한 유저의 UID를 가져오기
  Future<String?> _getCurrentUserUid() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid; // 로그인한 사용자 UID 반환
  }

  // 2. 랜덤으로 5개의 문서 번호를 뽑아 users 컬렉션에 저장
  Future<void> _saveRandomChallengeDocuments(String userUid,
      [bool isRefresh = false]) async {
    final random = Random();
    final randomDocuments = <String>[];

    try {
      // Firestore에서 challengelist 컬렉션의 문서 이름들 가져오기
      final challengelistSnapshot =
          await _firestore.collection('challengelist').get();

      if (challengelistSnapshot.docs.isEmpty) {
        print("challengelist 컬렉션에 문서가 없습니다.");
        return;
      }

      // 문서들의 ID를 리스트로 저장
      final documentNames =
          challengelistSnapshot.docs.map((doc) => doc.id).toList();

      // 5개의 랜덤 문서 번호 선택
      while (randomDocuments.length < 5) {
        final randomDocument =
            documentNames[random.nextInt(documentNames.length)];
        if (!randomDocuments.contains(randomDocument)) {
          randomDocuments.add(randomDocument);
        }
      }

      // Firestore에서 users 컬렉션에 해당하는 문서 참조
      DocumentReference userDoc = _firestore.collection('users').doc(userUid);

      // 문서 가져오기
      final userSnapshot = await userDoc.get();

      if (userSnapshot.exists) {
        // 기존에 선택된 챌린지 목록이 있고, 새로고침이 아니면 업데이트하지 않음
        if (!isRefresh) {
          final existingChallenges = userSnapshot['selected_challenges'];
          if (existingChallenges != null && existingChallenges.isNotEmpty) {
            // 값이 있으면 업데이트 하지 않음
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text("선택된 챌린지 목록들이 이미 존재합니다."),
            //     backgroundColor: Colors.pink[100]!, // 핑크색 배경
            //   ),
            // );
            return;
          }
        }
      }

      // selected_challenges 필드에 랜덤 문서 번호 추가
      await userDoc.update({
        'selected_challenges': randomDocuments, // 선택된 5개 문서 번호 저장
      });

      setState(() {
        isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('랜덤으로 5개의 문서 번호가 저장되었습니다!'),
          backgroundColor: Colors.pink[100]!, // 핑크색 배경
        ),
      );

      print("선택된 문서들: $randomDocuments");
    } catch (e) {
      setState(() {
        isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('에러가 발생했습니다: $e'),
          backgroundColor: Colors.pink, // 핑크색 배경
        ),
      );
    }
  }

  // 3. users 컬렉션에서 선택된 문서 번호들 가져오기
  Future<void> _fetchSavedChallengeDocuments(String userUid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userUid).get();

      if (userDoc.exists) {
        final documentNames =
            List<String>.from(userDoc['selected_challenges'] ?? []);
        if (documentNames.isNotEmpty) {
          _fetchItemsFromSelectedDocuments(documentNames);
        } else {
          print("선택된 문서가 없습니다.");
        }
      } else {
        print("사용자 문서가 존재하지 않습니다.");
      }
    } catch (e) {
      print("데이터 가져오기 실패: $e");
    }
  }

  // 4. 선택된 5개 문서에서 데이터를 가져오기
  Future<void> _fetchItemsFromSelectedDocuments(
      List<String> documentNames) async {
    final List<String> allItems = [];

    try {
      for (var documentName in documentNames) {
        final snapshot = await _firestore
            .collection('challengelist')
            .doc(documentName) // list1, list2, list3 등
            .get();

        if (snapshot.exists) {
          // 문서에서 직접 항목을 가져오기
          if (snapshot.data() != null) {
            // 문서 내 필드에서 필요한 데이터 가져오기 (예: 'item' 필드)
            var item = snapshot['list']; // 'list' 필드가 있으면
            if (item != null) {
              allItems.add(item); // 항목을 allItems 리스트에 추가
            } else {
              print("항목이 없습니다: $documentName");
            }
          } else {
            print("문서에 데이터가 없습니다: $documentName");
          }
        } else {
          print("문서가 존재하지 않습니다: $documentName");
        }
      }

      setState(() {
        items = allItems; // 모든 항목을 하나의 리스트로 합침
        _isLoading = false;
      });
    } catch (e) {
      print("데이터 가져오기 실패: $e");
    }
  }

  // 5. 처음 화면이 로드될 때 랜덤 5개 문서 번호를 뽑아서 저장하고 데이터를 가져옴
  Future<void> _fetchChallengeItems() async {
    if (isUpdating) return; // 이미 업데이트 중이면 리턴

    final userUid = await _getCurrentUserUid(); // 현재 로그인된 유저의 UID 가져오기
    if (userUid != null) {
      setState(() {
        isUpdating = true; // 업데이트 시작
      });
      await _saveRandomChallengeDocuments(userUid); // 랜덤 5개 문서 번호 저장
      await _fetchSavedChallengeDocuments(userUid); // 저장된 문서 번호들을 기반으로 데이터 가져오기
      setState(() {
        isUpdating = false; // 업데이트 끝
      });
    } else {
      // 유저가 로그인하지 않은 경우 처리
      print("로그인된 유저가 없습니다.");
    }
  }

  int _changeTickets = 0;
  Future<void> _fetchChangeTickets() async {
    try {
      final userUid = await _getCurrentUserUid(); // 현재 로그인된 유저의 UID 가져오기
      if (userUid == null) {
        print("사용자 인증이 필요합니다.");
        return;
      }

      // Firestore에서 사용자 데이터 가져오기
      final userDoc =
      FirebaseFirestore.instance.collection('users').doc(userUid);
      final snapshot = await userDoc.get();

      if (snapshot.exists) {
        final data = snapshot.data();
        final changeTickets = data?['룰렛판 바꾸기'] ?? 0; // 티켓 개수 가져오기

        setState(() {
          _changeTickets = changeTickets; // 상태 업데이트
        });
      } else {
        print("사용자 문서를 찾을 수 없습니다.");
      }
    } catch (e) {
      print("오류 발생: $e");
    }
  }

  // 새로 고침 버튼 클릭 시 호출될 함수
  Future<void> refreshList() async {
    setState(() {
      _isLoading = true; // 로딩 상태로 변경
    });

    try {
      final userUid = await _getCurrentUserUid(); // 현재 로그인된 유저의 UID 가져오기
      if (userUid == null) {
        print("사용자 인증이 필요합니다.");
        return;
      }

      // Firestore에서 사용자 데이터 가져오기
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userUid);
      final snapshot = await userDoc.get();

      if (snapshot.exists) {
        final data = snapshot.data();
        final changeTickets = data?['룰렛판 바꾸기'] ?? 0; // 룰렛판 바꾸기 티켓 확인

        if (changeTickets > 0) {
          // 룰렛판 바꾸기 충분하면 진행
          await userDoc.update({
            '룰렛판 바꾸기': changeTickets - 1, // 룰렛판 바꾸기 차감
          });

          print("룰렛판 바꾸기 1개 소모. 남은 개수: ${changeTickets - 1}");

          // 기존에 저장된 데이터는 무시하고 랜덤으로 새로운 5개 문서 번호를 저장
          await _saveRandomChallengeDocuments(userUid, true);

          // 새로 고침을 위해 새로운 데이터를 가져오기
          await _fetchChallengeItems(); // 데이터를 새로 가져오는 함수 호출
          await _fetchChangeTickets();
        } else {
          print("룰렛판 바꾸기 아이템이 부족합니다!");
          // 챌린지 스킵권이 부족할 때 다이얼로그 띄우기
          showDialog(
            context: context,
            builder: (context) => ErrorDialog(
              message: "룰렛판 바꾸기 아이템이 부족합니다!",
            ),
          );
          setState(() {
            _isLoading = false; // 로딩 끝
          });
        }
      } else {
        print("사용자 문서를 찾을 수 없습니다.");
      }
    } catch (e) {
      print("오류 발생: $e");
    } finally {
      // setState(() {
      //   _isLoading = false; // 로딩 끝
      // });
    }
  }

  bool _isSpinning = false; // 룰렛 회전 중인지 여부
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _offsetAnimation;

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

    // 상단부 확대 애니메이션 시작
    _scaleController.forward(); // 확대 애니메이션

    // 스피닝 종료 후 선택된 항목 표시
    final duration =
        spinDuration * (1 - (1 - _controller.value) * decelerationFactor);
    Future.delayed(Duration(milliseconds: duration.round()), () {
      _controller.stop();
      final selectedItemIndex = calculateSelectedItemIndex();

      // 상단부 축소 애니메이션
      _scaleController.reverse(); // 축소 애니메이션

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
            borderRadius: BorderRadius.circular(5),
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
                        fontSize: 16,
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
      appBar: AppBar(
        title: Text("챌린지 룰렛 돌리기"),
        backgroundColor: Colors.pink[100],
      ),
      body: GradientBackground(
        child: Center(
          child: _isLoading
              ? SizedBox(
                  width: 200, // 원하는 너비
                  height: 200, // 원하는 높이
                  child: CircularProgressIndicator(
                    strokeWidth: 40, // 로딩바의 두께 조정
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.pink[100]!),
                    // 로딩바 색상 변경
                    backgroundColor: Colors.grey[200], // 배경 색상 설정
                  ),
                ) // 로딩 중 표시
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // 룰렛 크기 조정과 위치 이동
                        Transform.scale(
                          scale: _scaleAnimation.value, // 룰렛 크기를 애니메이션에 맞게 조정
                          child: Transform.translate(
                            offset: _offsetAnimation.value,
                            child: Transform.rotate(
                              angle: _rotation,
                              child: CustomPaint(
                                size: Size(360, 360),
                                painter: RoulettePainter(items, colors),
                              ),
                            ),
                          ),
                        ),
                        // 상단 삼각형 아이콘 위치 조정 (Positioned를 직접 사용)
                        Positioned(
                          // top: 20 + _offsetAnimation.value.dy,
                          child: CustomPaint(
                              size: Size(50, 50),
                              painter: TrianglePainter(
                                yPosition: 40, // 삼각형의 y 위치
                                sideLength:
                                    24 + (0.5 * _offsetAnimation.value.dy),
                                // dy 값에 따라 크기 조정, 최소 40부터 시작
                              )),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // 그냥 돌리기
                    ElevatedButton(
                      onPressed: _isSpinning ? null : startSpin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[100], // 버튼 배경색
                        disabledBackgroundColor: Colors.pink[50], // 비활성화 상태 배경색
                        foregroundColor: Colors.white, // 텍스트 색상
                        disabledForegroundColor: Colors.grey, // 비활성화 상태 텍스트 색상
                      ),
                      child: Text(
                        "돌려돌려 돌림판",
                        style: TextStyle(fontSize: 24), // 글씨 크기 설정
                      ),
                    ),
                    SizedBox(height: 10),

                    // 리스트 새로 고침 버튼
                    ElevatedButton(
                      onPressed: (_isLoading || _isSpinning)
                          ? null
                          : () async {
                        final result = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Ask_again(
                              message: "정말 목록을 새로 고칠까요?",
                            );
                          },
                        );

                        if (result == 1) {
                          // 확인 버튼을 눌렀을 때 동작
                          refreshList();
                        }
                        // 취소 버튼을 눌렀으면 아무 동작 안 함
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[200], // 버튼 배경색
                        disabledBackgroundColor: Colors.pink[50], // 비활성화 상태 배경색
                        foregroundColor: Colors.white, // 텍스트 색상
                        disabledForegroundColor: Colors.grey, // 비활성화 상태 텍스트 색상
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white) // 로딩 중일 때 로딩 바 표시
                          : Row(
                        mainAxisSize: MainAxisSize.min, // 콘텐츠 크기만큼만 Row 사용
                        children: [
                          Icon(Icons.refresh, color: Colors.white), // 아이콘 추가
                          SizedBox(width: 8), // 아이콘과 텍스트 사이 간격
                          Text(
                            "룰렛판 바꾸기 사용하기 (보유 수 : " + _changeTickets.toString() + " 개)",
                            style: TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
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

    // 큰 백그라운드 원 추가
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5) // 검정색, 투명도 50%
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius + 10, backgroundPaint); // 기존 원보다 조금 더 큼

    for (int i = 0; i < items.length; i++) {
      // 항목마다 개별적으로 그라데이션을 적용하기 위해 색상 배열을 사용
      final gradient = LinearGradient(
        colors: [
          colors[i],
          colors[(i + 1) % colors.length]
        ], // 다음 색상으로 그라데이션을 만들기
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

      // 각 항목에 대해 그라데이션 적용
      paint.shader = gradient
          .createShader(Rect.fromCircle(center: center, radius: radius));

      final startAngle = (i * 72) * (pi / 180); // 72도씩 간격으로
      final sweepAngle = (72 * pi / 180); // 72도

      // 그라데이션이 적용된 원 그리기
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // 텍스트 줄바꿈 및 렌더링
      final lineHeight = 10.0; // 줄 간격
      final maxWidth = radius / 2; // 텍스트 최대 너비
      final words = items[i].split(' '); // 단어 단위로 나눔
      List<String> lines = [];
      String currentLine = "";

      for (String word in words) {
        final testLine = currentLine.isEmpty ? word : "$currentLine $word";
        final testTextPainter = TextPainter(
          text: TextSpan(
            text: testLine,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          textDirection: TextDirection.ltr,
        );
        testTextPainter.layout(maxWidth: maxWidth);

        if (testTextPainter.width <= maxWidth) {
          currentLine = testLine;
        } else {
          lines.add(currentLine);
          currentLine = word;
        }
      }

      if (currentLine.isNotEmpty) {
        lines.add(currentLine);
      }

      // 각 줄을 그리기
      for (int j = 0; j < lines.length; j++) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: lines[j],
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: maxWidth);

        final x = center.dx +
            (radius / 1.6) * cos(startAngle + sweepAngle / 2) -
            textPainter.width / 2;
        final y = center.dy +
            (radius / 1.6) * sin(startAngle + sweepAngle / 2) -
            (textPainter.height / 2) -
            (lines.length * lineHeight / 2) + // 중앙 정렬
            j * lineHeight;

        textPainter.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class TrianglePainter extends CustomPainter {
  final double yPosition; // 삼각형의 y 위치
  final double sideLength; // 삼각형 한 변의 길이

  // 생성자
  TrianglePainter({
    required this.yPosition,
    required this.sideLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue[100]!;

    final path = Path()
      // 시작 위치 (중앙 위쪽)
      ..moveTo(size.width / 2, yPosition) // 역삼각형의 꼭짓점 1
      // 왼쪽 아래 꼭짓점
      ..lineTo(size.width / 2 - sideLength / 2, yPosition - sideLength)
      // 오른쪽 아래 꼭짓점
      ..lineTo(size.width / 2 + sideLength / 2, yPosition - sideLength)
      // 삼각형 닫기
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // 매번 새로 그릴 필요가 없으면 false
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
