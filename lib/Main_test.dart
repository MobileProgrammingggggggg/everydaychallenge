import 'package:flutter/material.dart';
import 'package:test_flutter/themes/colors.dart';
import 'CustomBottomNavigationBar.dart';
import 'Login_screen.dart';
import 'ChallengeButton.dart';
import 'Ask_again_screen.dart';
import 'Notification_Screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'firebase_initializer.dart';
import 'package:get/get.dart';
import 'global.dart'; // 추가
import 'package:provider/provider.dart';
import 'Community_Provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';
// import 'Community_Provider.dart';

// 메인 화면
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // WorkManager 초기화
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // 매일 자정에 실행될 작업 예약
  Workmanager().registerPeriodicTask(
    "dailyDdayUpdate", // 태스크 ID
    "dailyDdayUpdateTask", // 태스크 이름
    frequency: Duration(hours: 24), // 24시간마다 실행
  );

  runApp(MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await Firebase.initializeApp(); // Firebase 초기화
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        if (data['signupDate'] != null) {
          DateTime signupDate = (data['signupDate'] as Timestamp).toDate();
          DateTime today = DateTime.now();
          DateTime signupDateOnly = DateTime(signupDate.year, signupDate.month, signupDate.day);
          DateTime todayOnly = DateTime(today.year, today.month, today.day);

          int daysSinceSignup = todayOnly.difference(signupDateOnly).inDays;

          // Firestore 업데이트
          await userDoc.update({
            'dDay': daysSinceSignup + 1,
            'lastUpdated': Timestamp.fromDate(todayOnly),
          });

          print('D-day updated to: ${daysSinceSignup + 1}');
        }
      }
    }

    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 버튼 가리기
      home: AuthenticationWrapper(),

    );
  }
}


class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      saveSignupDate(); // 앱 실행 시 사용자가 로그인되어 있다면 가입 날짜 저장
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // 로딩 중일 때 로딩 표시
        }
        if (snapshot.hasData) {
          // 사용자가 로그인되어 있다면 ChallengeScreen으로 이동
          return ChallengeScreen();
        } else {
          // 로그인하지 않은 경우 LoginScreen으로 이동
          return LoginScreen();
        }
      },
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Column의 높이를 최소화
      children: [
        AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(bottom: 3.0), // 아래 여백 추가
            child: Image.asset(
              'assets/images/image7.png', // 이미지 경로
              height: 80, // 이미지 높이 조정
              fit: BoxFit.contain,
            ),
          ),
          leading: LogoutIcon(),
          actions: [NotificationIcon()],
        ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + 1); // 앱바 높이 + 구분선 두께
}

class LogoutIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        // 로그아웃 확인 대화상자 보여주기
        int? result = await showDialog<int>(
          context: context,
          builder: (BuildContext context) {
            return Ask_again(message: "정말 로그아웃 하시겠습니까?");
          },
        );

        // 확인 버튼 클릭 시 로그아웃 실행
        if (result == 1) {
          logout(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.black),
            Text(
              "로그아웃",
              style: TextStyle(color: Colors.black, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  void logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // 로그인 화면으로 이동
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;

  GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // 가로를 화면 크기로 설정
      height: double.infinity, // 세로를 화면 크기로 설정
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink[100]!, // 연한 핑크색
            Colors.blue[100]!, // 연한 블루색
          ],
          begin: Alignment.topLeft, // 그라데이션 시작 위치
          end: Alignment.bottomRight, // 그라데이션 끝 위치
        ),
      ),
      child: child,
    );
  }
}

class NotificationIcon extends StatefulWidget {
  @override
  _NotificationIconState createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  late Timer _notificationTimer;

  @override
  void initState() {
    super.initState();
    // 알림 상태를 주기적으로 업데이트하기 위한 타이머 시작
    _notificationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {}); // 상태를 업데이트하여 UI를 갱신
    });
  }

  @override
  void dispose() {
    _notificationTimer.cancel(); // 타이머 종료
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.blue[700]),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Notification_Screen(), // NotificationScreen으로 이동
              ),
            );
          },
        ),
        // 알림 개수를 표시하는 위젯 추가
        if (globalNotifications.isNotEmpty) // 알림이 있을 때만 표시
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                "${globalNotifications.length}", // 알림 개수 표시
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }
}

class CountdownText extends StatefulWidget {
  @override
  _CountdownTextState createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText> {
  late int _hours;
  late int _minutes;
  late int _seconds;
  late Timer _timer;
  late Timer _notificationTimer; // 알림 확인을 위한 타이머 추가
  bool? doublePoint;
  late Future<bool> doublePointFuture;

  @override
  void initState() {
    super.initState();
    _calculateTimeUntilMidnight(); // 자정까지의 시간 계산
    _startCountdown(); // 카운트다운 타이머 시작
    _startNotificationCheck(); // 알림 확인 타이머 시작
    _fetchDoublePoint();
    doublePointFuture = _fetchDoublePoint();
  }

  void _calculateTimeUntilMidnight() {
    final now = DateTime.now();
    final midnight =
    DateTime(now.year, now.month, now.day + 1); // 자정 (다음 날 00:00)
    final difference = midnight.difference(now);

    setState(() {
      _hours = difference.inHours;
      _minutes = difference.inMinutes % 60;
      _seconds = difference.inSeconds % 60;
    });
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else if (_minutes > 0) {
        setState(() {
          _minutes--;
          _seconds = 59;
        });
      } else if (_hours > 0) {
        setState(() {
          _hours--;
          _minutes = 59;
          _seconds = 59;
        });
      } else {
        _timer.cancel(); // 타이머 종료
      }

      // 남은 시간이 특정 값일 때 flag 확인
      if (_hours == 10 && _minutes == 0 && _seconds == 0 ||
          _hours == 5 && _minutes == 0 && _seconds == 0 ||
          _hours == 2 && _minutes == 0 && _seconds == 0 ||
          _hours == 1 && _minutes == 0 && _seconds == 0) {
        _checkChallengeFlag();
      }
    });
  }

  void _startNotificationCheck() {
    _notificationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {}); // 상태를 업데이트하여 UI를 갱신
    });
  }

  Future<void> _checkChallengeFlag() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    var result =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (result.exists) {
      var data = result.data()?['challengeFlag'];
      if (data != null && data != 3) {
        // 알람 로직 추가
        _sendAlarmNotification();
      }
    }
  }

  void _sendAlarmNotification() {
    String message = "$_hours시간 $_minutes분 $_seconds초 남았습니다. 챌린지가 곧 마감됩니다!";

    // 알림을 전역 리스트에 추가
    globalNotifications.add(NotificationCardData(
      icon: Icons.hourglass_bottom,
      title: "챌린지가 곧 마감됩니다!",
      description: message,
    ));
  }

  Future<bool> _fetchDoublePoint() async {
    try {
      final userUid = FirebaseAuth.instance.currentUser?.uid;
      if (userUid == null) {
        print("사용자 인증이 필요합니다.");
        return false; // 인증되지 않은 경우 false 반환
      }

      // Firestore에서 사용자 데이터 가져오기
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();
        return data?['doublePoint'] ?? false; // Firestore에서 값 가져오기
      } else {
        print("사용자 문서를 찾을 수 없습니다.");
        return false;
      }
    } catch (e) {
      print("오류 발생: $e");
      return false;
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // 카운트다운 타이머 종료
    _notificationTimer.cancel(); // 알림 확인 타이머 종료

    globalNotifications.clear(); // 알림 초기화
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: doublePointFuture,
    builder: (context, snapshot){
        final doublePoint = snapshot.data ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 정렬
      children: [
        // "남은 시간 : " 텍스트 (좌측 정렬)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start, //왼쪽 정렬
          children: [
        Text(
          "남은 시간 : ",
          style: TextStyle(
            fontFamily: "DoHyeon",
            color: Colors.blue, // AppColors.textBlue로 대체 가능
            fontSize: 25,
          ),
        ),
            if (doublePoint == true)
              Row(
                children: [
                  Tooltip(
                    message: "오늘의 챌린지 포인트가 2배로 적립됩니다.", // 툴팁 메시지
                    decoration: BoxDecoration(
                      color: Colors.pink[100], // 툴팁 배경색을 회색으로 설정
                      borderRadius: BorderRadius.circular(8), // 둥근 모서리
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.double_arrow, // 원하는 아이콘
                          color: Colors.orange,
                          size: 20,
                        ),
                        SizedBox(width: 5), // 아이콘과 텍스트 간 간격
                        Text(
                          "포인트 2배",
                          style: TextStyle(
                            fontFamily: "DoHyeon",
                            color: Colors.black, // 텍스트 색상
                            fontSize: 18, // 텍스트 크기
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),


          ],
        ),
        // 시간, 분, 초 부분 (우측 정렬)
        Text(
          "$_hours시간 $_minutes분 $_seconds초",
          style: TextStyle(
            fontFamily: "DoHyeon",
            color: Colors.pink[200]!,
            fontSize: 25,
          ),
        ),
        // 알림 개수 표시 (NotificationIcon 위젯에서 표시)
        // 이 부분은 NotificationIcon에서 처리합니다.
      ],
    );
    },
    );
  }
}


class CharacterImage extends StatefulWidget {
  @override
  _CharacterImageState createState() => _CharacterImageState();
}

class _CharacterImageState extends State<CharacterImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8), // 애니메이션 지속 시간
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 4 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut), // 자연스러운 회전
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.forward(from: 0); // 애니메이션을 처음부터 다시 시작
      }
    });

    _controller.forward(); // 애니메이션 시작
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(_rotationAnimation.value), // 3D 회전
          child: Image.asset(
            'assets/images/character.png', // 이미지 경로
            height: 160,
          ),
        );
      },
    );
  }
}

class QuoteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> getRandomQuote() async {
    try {
      // Firestore에서 'quotes' 컬렉션을 가져와서 랜덤으로 명언을 선택
      var snapshot = await _db.collection('quotes').get();
      var docs = snapshot.docs;
      if (docs.isNotEmpty) {
        var randomIndex =
        Random().nextInt(docs.length); // 0부터 docs.length-1 사이의 랜덤 인덱스 선택
        return docs[randomIndex]['quote']; // 랜덤 인덱스에 해당하는 명언 반환
      }
      return '명언을 불러올 수 없습니다.'; // 데이터가 없으면 기본 문구 반환
    } catch (e) {
      return '명언을 불러오는 중 오류가 발생했습니다.';
    }
  }
}

class QuoteWidget extends StatefulWidget {
  @override
  _QuoteWidgetState createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {
  final QuoteService _quoteService = QuoteService();
  late Future<String> _quoteFuture;

  @override
  void initState() {
    super.initState();
    _quoteFuture = _quoteService.getRandomQuote(); // 명언 가져오기
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _quoteFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 40, // 원하는 가로 크기 설정
              height: 40, // 원하는 세로 크기 설정
              child: CircularProgressIndicator(
                strokeWidth: 10,
                // 로딩바의 두께 조정
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[100]!),
                // 로딩바 색상 변경
                backgroundColor: Colors.grey[200], // 배경 색상 설정
              ),
            ),
          ); // 로딩 중, 작은 크기와 커스터마이징된 로딩바 표시
        }
        if (snapshot.hasError) {
          return Text('오류가 발생했습니다: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('명언을 불러올 수 없습니다.');
        }
        return Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft, // 좌측 정렬
                child: FittedBox(
                  fit: BoxFit.scaleDown, // 텍스트 크기를 컨테이너에 맞게 줄이기
                  alignment: Alignment.centerLeft,
                  child: Text(
                        () {
                      String quote = snapshot.data!;
                      List<String> quoteParts =
                      quote.split('-'); // 하이픈 기준으로 명언과 저자 구분
                      return quoteParts[0]; // 명언 내용
                    }(),
                    style: TextStyle(
                      fontFamily: "Diphylleia",
                      fontSize: 14,
                      // 기본 글자 크기
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 8), // 간격 추가
              Align(
                alignment: Alignment.centerRight, // 우측 정렬
                child: Text(
                      () {
                    String quote = snapshot.data!;
                    List<String> quoteParts = quote.split('-');
                    return quoteParts.length > 1
                        ? '-${quoteParts[1]}'
                        : ''; // 저자 부분
                  }(),
                  style: TextStyle(
                    fontFamily: "Diphylleia",
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ChallengeScreen extends StatefulWidget {
  @override
  _ChallengeScreenState createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  String selectedChallenge = "오늘의 챌린지는? ";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CustomWidth = 0.92; // 커스텀 Media 가로크기

  @override
  void initState() {
    super.initState();
    _loadChallenge();
    dateUpdateChallenge(context);
  }

  // Firestore에서 저장된 챌린지를 로드하는 메서드
  void _loadChallenge() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid;

      try {
        DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(userId).get();

        if (snapshot.exists && snapshot.data() != null) {
          setState(() {
            selectedChallenge = snapshot['selectedChallenge'] ?? "오늘의 챌린지는? ";
          });
        }
      } catch (e) {
        print("Failed to load challenge: $e");
      }
    } else {
      print("No user is currently logged in");
    }
  }

  // 날짜 변경 체크 및 업데이트
  void dateUpdateChallenge(BuildContext context) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid;

      // Firestore에서 사용자 데이터 가져오기
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Firestore에서 가져온 날짜
        String? challengeDate = userData['challengeDate'];

        // 현재 날짜
        DateTime currentDate = DateTime.now();
        String formattedDate =
            "${currentDate.year}-${currentDate.month}-${currentDate.day}";

        if (challengeDate != formattedDate) {
          // 날짜가 변경되었으면 flag를 1로 설정
          await _firestore.collection('users').doc(userId).update({
            'challengeFlag': 1,
            'challengeDate': formattedDate, // 날짜를 업데이트
            'challengeSelected': false,
            'selectedChallenge': "오늘의 챌린지는? ",
          });

          print("Date updated and flag set to 1");
          print(formattedDate);
        }
      }
    }
  }

  // 챌린지 업데이트 및 Firestore에 저장하는 메서드
  void updateChallenge(String challenge) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid;

      DateTime currentDate = DateTime.now();
      String formattedDate =
          "${currentDate.year}-${currentDate.month}-${currentDate.day}";

      try {
        await _firestore.collection('users').doc(userId).set(
          {
            'selectedChallenge': "오늘의 챌린지 : $challenge",
            'challengeDate': formattedDate,
            'challengeSelected': true, // 챌린지가 선택되었음을 표시
          },
          SetOptions(merge: true),
        );
        print("Challenge updated successfully");

        // 화면 전환 로직 - 챌린지 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ChallengeScreen()), // 챌린지 화면으로 이동
        );
      } catch (e) {
        print("Failed to save challenge: $e");
      }
    } else {
      print("No user is currently logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(),
      body: GradientBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 첫 번째 박스: HeaderSection을 감싸는 흰색 박스
              Padding(
                padding:
                const EdgeInsets.only(top: 20, bottom: 5), // 상단과 하단 여백 설정

                child: Container(
                  width: MediaQuery.of(context).size.width *
                      CustomWidth, // 화면 너비의 80%로 설정
                  padding: const EdgeInsets.all(10), // 내용 안에 여백
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // 투명도 0.8 적용
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20), // 위쪽만 둥글게
                      bottom: Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // 그림자 효과
                        blurRadius: 10,
                        offset: Offset(0, 5), // 아래로 살짝 그림자
                      ),
                    ],
                  ),
                  child: HeaderSection(), // HeaderSection을 포함
                ),
              ),
              SizedBox(height: 5),

              // 두 번쨰 박스 : 명언
              Padding(
                padding: const EdgeInsets.only(bottom: 5), // 상단과 하단 여백 설정
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      CustomWidth, // 화면 너비의 80%로 설정
                  padding: const EdgeInsets.all(10), // 내용 안에 여백
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // 투명도 0.8 적용
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10), // 위쪽만 둥글게
                      bottom: Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // 그림자 효과
                        blurRadius: 10,
                        offset: Offset(0, 5), // 아래로 살짝 그림자
                      ),
                    ],
                  ),
                  child: QuoteWidget(), // HeaderSection을 포함
                ),
              ),
              SizedBox(height: 5),

              // 세 번째 박스: 나머지 콘텐츠를 감싸는 박스
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10), // 양옆 여백 설정
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      CustomWidth, // 화면 너비의 80%로 설정
                  padding: const EdgeInsets.all(10), // 내용 안에 여백
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // 투명도 0.8 적용
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10), // 위쪽만 둥글게
                      bottom: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // 그림자 효과
                        blurRadius: 10,
                        offset: Offset(0, 5), // 아래로 살짝 그림자
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CountdownText(),
                      SizedBox(height: 20),
                      CharacterImage(),
                      SizedBox(height: 20),
                      ChallengePrompt(challengeText: selectedChallenge),
                      SizedBox(height: 10),
                      ChallengeButton(
                        onChallengeSelected: updateChallenge, // 콜백 전달
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0),
    );
  }
}

class ChallengePrompt extends StatelessWidget {
  final String challengeText;

  ChallengePrompt({required this.challengeText});

  @override
  Widget build(BuildContext context) {
    // 텍스트를 "오늘의 챌린지:"와 실제 챌린지 부분으로 분리
    List<String> parts = challengeText.split(':');
    String titlePart = parts[0];
    String challengePart = parts.length > 1 ? parts[1] : "";

    return RichText(
      text: TextSpan(
        children: [
          // "오늘의 챌린지:" 부분
          TextSpan(
            text: "$titlePart",
            style: TextStyle(
              color: AppColors.textBlue, // 제목 부분 색상
              fontFamily: 'DoHyeon',
              fontSize: 25,
            ),
          ),
          // 실제 챌린지 부분
          TextSpan(
            text: challengePart.trim(), // 불필요한 공백 제거
            style: TextStyle(
              color: Colors.pink[200]!, // 챌린지 부분 색상
              fontFamily: 'DoHyeon',
              fontSize: 25,
            ),
          ),
        ],
      ),
    );
  }
}

void addSignupDateIfMissing() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userDoc =
    FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      if (data['signupDate'] == null) {
        // signupDate 필드가 없는 경우 추가
        await userDoc.update({
          'signupDate': Timestamp.fromDate(DateTime.now()),
        });
        print('Signup date added for user: ${user.uid}');
      } else {
        print('Signup date already exists for user: ${user.uid}');
      }
    }
  }
}

void signUpUser(String email, String password) async {
  try {
    UserCredential userCredential =
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 회원가입 성공 후 Firestore에 사용자 정보 저장
    final user = userCredential.user;
    if (user != null) {
      final userDoc =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Firestore에 signupDate 설정
      await userDoc.set({
        'signupDate': Timestamp.fromDate(DateTime.now()),
        'dDay': 1,
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
        'points': 0, // 초기 포인트 설정
      });

      print('User signed up with signupDate set.');
    }
  } catch (e) {
    print('Error signing up user: $e');
  }
}

void saveSignupDate() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userDocRef =
    FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();

    if (userDoc.exists && userDoc.data()?['signupDate'] != null) {
      print('Signup date already exists for user: ${user.uid}');
      return; // 이미 가입 날짜가 설정된 경우 함수 종료
    }

    // 가입 날짜를 Authentication의 metadata에서 가져옴
    final signupDate = user.metadata.creationTime;
    if (signupDate != null) {
      await userDocRef.set({
        'signupDate': Timestamp.fromDate(signupDate),
      }, SetOptions(merge: true)); // 기존 데이터에 병합
      print('Signup date added for user: ${user.uid}');
    }
  }
}

void updateDday() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userDoc =
    FirebaseFirestore.instance.collection('users').doc(user.uid);

    final docSnapshot = await userDoc.get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;

      // signupDate가 없으면 Authentication의 creationTime을 가져와서 사용
      DateTime signupDate;
      if (data['signupDate'] == null) {
        signupDate = user.metadata.creationTime!;
        await userDoc.update({
          'signupDate': Timestamp.fromDate(signupDate),
          // Firestore에 signupDate 저장
        });
        print(
            'Signup date set from Authentication metadata for user: ${user.uid}');
      } else {
        signupDate = (data['signupDate'] as Timestamp).toDate();
      }

      // 오늘 날짜를 UTC 기준으로 시간 제외하고 계산
      DateTime today = DateTime.now();
      DateTime signupDateOnly =
      DateTime(signupDate.year, signupDate.month, signupDate.day);
      DateTime todayOnly = DateTime(today.year, today.month, today.day);

      int daysSinceSignup = todayOnly.difference(signupDateOnly).inDays;

      // Firestore 업데이트
      await userDoc.update({
        'dDay': daysSinceSignup + 1,
        'lastUpdated': Timestamp.fromDate(todayOnly),
      });

      print('D-day updated to: ${daysSinceSignup + 1}');
    } else {
      print('Error: User document not found for user ${user.uid}');
    }
  } else {
    print('Error: No user is currently signed in.');
  }
}

class HeaderSection extends StatefulWidget {
  @override
  _HeaderSectionState createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  int points = 0;
  int dDay = 0;
  String UID = "";
  int score = 0;
  int percent = 0;


  late StreamSubscription<DocumentSnapshot> userInfoSubscription;
  Timer? dailyUpdateTimer;

  @override
  void initState() {
    super.initState();
    saveSignupDate(); // 화면이 생성될 때 가입 날짜 저장 (기존 사용자를 위한 처리)
    updateDday(); // 화면이 생성될 때 D-day 업데이트
    listenToUserInfo(); // Firestore 실시간 업데이트 리스너 추가
    scheduleDailyUpdate(); // 자정에 D-day 업데이트
  }

  // Firestore 실시간 리스너를 사용하여 사용자 정보 가져오기
  void listenToUserInfo() {
    userInfoSubscription = FirebaseFirestore.instance.collection('users').doc(uid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          points = snapshot.data()?['points'] ?? 0; // 'points' 필드에서 포인트 값을 가져옴
          dDay = snapshot.data()?['dDay'] ?? 1; // 'dDay' 필드에서 D-day 값을 가져옴
          UID = snapshot.data()?['id'] ?? "Unknown"; // 'id' 필드에서 id 값을 가져옴
          score = snapshot.data()?['score'] ?? 0; // 'score' 필드에서 'score' 값을 가져옴
          percent = (score / dDay * 100).toInt();
        });
      }
    });
  }

  // 자정에 D-day 업데이트를 예약하는 함수
  void scheduleDailyUpdate() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = nextMidnight.difference(now);

    dailyUpdateTimer = Timer(durationUntilMidnight, () {
      updateDday(); // 자정에 D-day 업데이트
      scheduleDailyUpdate(); // 다음 자정 업데이트 예약
    });
  }

  @override
  void dispose() {
    userInfoSubscription.cancel(); // 리스너 해제하여 메모리 누수 방지
    dailyUpdateTimer?.cancel(); // 타이머 해제
    super.dispose();
  }

  // 포인트 추가 함수
  void addPoints(int addedPoints) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'points': FieldValue.increment(addedPoints),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5), // 배경과 아이콘 사이의 간격
                decoration: BoxDecoration(
                  color: Colors.lightBlue, // 배경 색상
                  shape: BoxShape.circle, // 동그란 배경
                ),
                child: Icon(
                  Icons.star,
                  color: Colors.yellowAccent,
                  size: 16, // 아이콘 크기 설정
                ),
              ),
              SizedBox(width: 5),
              Text(
                " $points P", // 데이터베이스에서 가져온 포인트 출력
                style: TextStyle(
                  fontFamily: "DoHyeon",
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$UID님과 함께한 시간 $dDay일째!", // Firestore에서 가져온 D-day 출력
                style: TextStyle(
                  fontFamily: "DoHyeon",
                  color: Colors.pink[200]!,
                  fontSize: 18,
                ),
              ),
              Text(
                "달성률: $percent%",
                style: TextStyle(
                  fontFamily: "DoHyeon",
                  color: AppColors.textBlue,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
