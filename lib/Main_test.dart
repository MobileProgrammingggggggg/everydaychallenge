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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 메인 화면
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // 웹에서 FirebaseOptions을 가져옵니다.
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 버튼 가리기
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Firebase 인증 상태 스트림
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()), // 로딩 중
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          // 로그인된 사용자의 userId를 ChallengeScreen에 전달
          return ChallengeScreen(userId: snapshot.data!.uid); // 반드시 userId 전달
        }
        return LoginScreen(); // 로그인되지 않은 상태면 로그인 화면으로 이동
      },
    );
  }
}

class ChallengeScreen extends StatefulWidget {
  final String userId;

  ChallengeScreen({required this.userId});

  @override
  _ChallengeScreenState createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentSnapshot<Map<String, dynamic>>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      // 전달받은 userId를 사용하여 사용자 데이터 로드
      DocumentSnapshot<Map<String, dynamic>> data = await _firestore.collection('users').doc(widget.userId).get();
      setState(() {
        userData = data;
      });
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      // 데이터를 불러오는 중일 때 로딩 화면 표시
      return Scaffold(
        appBar: CustomAppBar(),
        body: Center(child: CircularProgressIndicator()), // 로딩 인디케이터
      );
    } else {
      // 데이터가 로드되었을 때 UI 표시
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(),
        body: GradientBackground(
          child: SingleChildScrollView(
            child: Column(
              children: [
                HeaderSection(userData: userData!),
                SizedBox(height: 20), // 위젯 간의 간격
                CountdownText(userData: userData!),
                SizedBox(height: 20), // 위젯 간의 간격
                CharacterImage(),
                SizedBox(height: 20), // 위젯 간의 간격
                ChallengePrompt(),
                SizedBox(height: 20), // 위젯 간의 간격
                ChallengeButton(),
                SizedBox(height: 100), // 하단 여백
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(),
      );
    }
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo.png', // 이미지 경로
          height: 70, // 이미지 높이 설정
          width: 200,
        ),
        leading: LogoutIcon(),
        actions: [NotificationIcon()]);
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
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
          FirebaseAuth.instance.signOut(); // Firebase 로그아웃
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()), // 로그인 화면으로 이동
          );
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
}

class NotificationIcon extends StatefulWidget {
  @override
  _NotificationIconState createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  int notificationCount = 3; // 초기 알림 갯수 설정

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // 아이콘이 겹쳐 보이도록 클리핑 비활성화
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.black),
          onPressed: () async {
            User? currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Notification_Screen(userId: currentUser.uid), // userId 전달
                ),
              );
              setState(() {
                notificationCount = 0; // 알림 갯수 초기화
              });
            } else {
              print("User is not logged in.");
            }
          },
        ),
        if (notificationCount > 0)
          Positioned(
            right: 4, // 아이콘의 오른쪽 상단으로 이동
            top: 4,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: Colors.red,
              child: Text(
                '$notificationCount',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;

  GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // 가로를 무한대로 설정
      height: double.infinity, // 세로를 무한대로 설정
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.mainPink, AppColors.mainBlue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}

class HeaderSection extends StatelessWidget {
  final DocumentSnapshot<Map<String, dynamic>> userData;

  HeaderSection({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: AppColors.textBlue),
              SizedBox(width: 5),
              Text(
                "${userData.data()?['points'] ?? '300'} P", // Firestore에서 포인트 가져오기
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                "D + ${userData.data()?['days'] ?? 9}", // Firestore에서 D+일 수 가져오기
                style: TextStyle(color: AppColors.textBlue, fontSize: 18),
              ),
              Text(
                "달성률: ${userData.data()?['achievementRate'] ?? 98}%",
                style: TextStyle(color: AppColors.textBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CountdownText extends StatelessWidget {
  final DocumentSnapshot<Map<String, dynamic>> userData;

  CountdownText({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Text(
      "${userData.data()?['remainingTime'] ?? '7시간 56분'} 남았습니다.", // Firestore에서 남은 시간 가져오기
      style: TextStyle(
        color: AppColors.textBlue,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class CharacterImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/character.png',
      // Ensure you add the character image in assets
      height: 150,
    );
  }
}

class ChallengePrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      "오늘의 챌린지는?",
      style: TextStyle(
        color: AppColors.textBlue,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
