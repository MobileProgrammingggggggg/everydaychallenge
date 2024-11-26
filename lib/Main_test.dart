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
// import 'Community_Screen.dart';

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
      home:AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
    return AppBar(
        backgroundColor: Colors.pink[100],
        elevation: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10.0), // 아래 여백 추가
          child: Image.asset(
            'assets/images/image7.png', // 이미지 경로
            height: 260, // 이미지 높이 조정
            fit: BoxFit.contain,
          ),
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

class NotificationIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Notification_Screen()), // NotificationScreen으로 이동
            );
          },
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Text(
              "1",
              style: TextStyle(color: Colors.white, fontSize: 10),
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
                "300 P",
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
                "D + 9",
                style: TextStyle(color: AppColors.textBlue, fontSize: 18),
              ),
              Text(
                "달성률: 98%",
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
  @override
  Widget build(BuildContext context) {
    return Text(
      "7시간 56분 남았습니다.",
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

class ChallengeScreen extends StatefulWidget {
  @override
  _ChallengeScreenState createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  String selectedChallenge = "오늘의 챌린지는? ";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadChallenge();
  }

  // Firestore에서 저장된 챌린지를 로드하는 메서드
  void _loadChallenge() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid;

      try {
        DocumentSnapshot snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .get();

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

  // 챌린지 업데이트 및 Firestore에 저장하는 메서드
  void updateChallenge(String challenge) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid;

      DateTime currentDate = DateTime.now();
      String formattedDate = "${currentDate.year}-${currentDate.month}-${currentDate.day}";

      try {
        await _firestore.collection('users').doc(userId).set(
          {
            'selectedChallenge': "오늘의 챌린지: $challenge",
            'challengeDate': formattedDate,
            'challengeSelected': true, // 챌린지가 선택되었음을 표시
          },
          SetOptions(merge: true),
        );
        print("Challenge updated successfully");

        // 화면 전환 로직 - 챌린지 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChallengeScreen()), // 챌린지 화면으로 이동
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
              HeaderSection(),
              SizedBox(height: 20),
              CountdownText(),
              SizedBox(height: 20),
              CharacterImage(),
              SizedBox(height: 20),
              ChallengePrompt(challengeText: selectedChallenge),
              SizedBox(height: 20),
              ChallengeButton(
                onChallengeSelected: updateChallenge, // 콜백 전달
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}

class ChallengePrompt extends StatelessWidget {
  final String challengeText;

  ChallengePrompt({required this.challengeText});

  @override
  Widget build(BuildContext context) {
    return Text(
      challengeText,
      style: TextStyle(
        color: AppColors.textBlue,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
