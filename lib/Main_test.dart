import 'package:flutter/material.dart';
import 'package:test_flutter/themes/colors.dart';
import 'CustomBottomNavigationBar.dart';
import 'Login_screen.dart';
import 'ChallengeButton.dart';

// 메인 화면

void main() {
  //runApp(Login());
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

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "매일 매일 챌린지!",
          style: TextStyle(color: AppColors.textBlue, fontWeight: FontWeight.bold),
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
      onTap: () {
        // Implement your logout logic here
        logout(context); // Call your logout function with context
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
          onPressed: () {},
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
