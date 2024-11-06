import 'package:flutter/material.dart';
import 'CustomBottomNavigationBar.dart';
import 'Login_screen.dart';
import 'ChallengeButton.dart';
import 'NotificationScreen.dart'; // NotificationScreen 파일 import


// 메인 화면

void main() {
  // 로그인 화면 실행
  // runApp(Login());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChallengeScreen(),
    );
  }
}

class ChallengeScreen extends StatelessWidget {
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
              SizedBox(height: 20), // 위젯 간의 간격
              CountdownText(),
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

// 커스텀 앱바 위젯
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "매일 매일 챌린지!",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        leading: LogoutIcon(),
        actions: [NotificationIcon()]);
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

// 로그아웃 아이콘 위젯
class LogoutIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // 로그아웃 로직 구현
        logout(context); // context와 함께 로그아웃 함수 호출
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

// 알림 아이콘 위젯
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
              MaterialPageRoute(builder: (context) => NotificationScreen()), // NotificationScreen으로 이동
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

// 그라데이션 배경 위젯
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
          colors: [Colors.pink.shade100, Colors.blue.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}

// 상단 섹션 위젯
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
              Icon(Icons.star, color: Colors.blue),
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
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),
              Text(
                "달성률: 98%",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 카운트다운 텍스트 위젯
class CountdownText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      "7시간 56분 남았습니다.",
      style: TextStyle(
        color: Colors.blue,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

// 캐릭터 이미지 위젯
class CharacterImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://i.ibb.co/LnBF844/image.jpg',
      // 캐릭터 이미지를 assets에 추가하세요
      height: 150,
    );
  }
}

// 챌린지 프롬프트 텍스트 위젯
class ChallengePrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      "오늘의 챌린지는?",
      style: TextStyle(
        color: Colors.blue,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
