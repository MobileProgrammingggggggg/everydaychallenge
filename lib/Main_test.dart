import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_flutter/themes/colors.dart';
import 'CustomBottomNavigationBar.dart';
import 'Login_screen.dart';
import 'ChallengeButton.dart';
import 'Ask_again_screen.dart';
import 'Notification_Screen.dart';

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
              ChallengePrompt(), // ChallengePrompt 클래스 인스턴스 생성
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
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Image.asset(
        'assets/images/logo.png', // 이미지 경로
        height: 70, // 이미지 높이 설정
        width: 200,
      ),
      leading: LogoutIcon(),
      actions: [NotificationIcon()],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class LogoutIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        int? result = await showDialog<int>(
          context: context,
          builder: (BuildContext context) {
            return Ask_again(message: "정말 로그아웃 하시겠습니까?");
          },
        );

        if (result == 1) {
          await FirebaseAuth.instance.signOut();
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

class NotificationIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          );
        }

        int unreadCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Notification_Screen()),
                );
              },
            ),
            if (unreadCount > 0)
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
                    "$unreadCount",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        );
      },
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
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('challenges')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          FirebaseFirestore.instance
              .collection('challenges')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .set({
            'points': 300,
            'dayCount': 1,
            'achievementRate': 0,
            'challengePrompt': '오늘의 챌린지를 시작해보세요!',
            'startTime': Timestamp.now(),
          });
          return buildDefaultHeader();
        }

        var data = snapshot.data!;
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
                    "${data['points']} P",
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
                    "D + ${data['dayCount']}",
                    style: TextStyle(color: AppColors.textBlue, fontSize: 18),
                  ),
                  Text(
                    "달성률: ${data['achievementRate']}%",
                    style: TextStyle(color: AppColors.textBlue),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildDefaultHeader() {
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
                "D + 1",
                style: TextStyle(color: AppColors.textBlue, fontSize: 18),
              ),
              Text(
                "달성률: 0%",
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
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('challenges')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text(
            "시간 정보가 없습니다.",
            style: TextStyle(
              color: AppColors.textBlue,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          );
        }

        var data = snapshot.data!;
        Timestamp startTime = data['startTime'] ?? Timestamp.now();
        DateTime endTime = startTime.toDate().add(Duration(hours: 24));
        Duration timeLeft = endTime.difference(DateTime.now());

        if (timeLeft.isNegative) {
          return Text(
            "시간이 만료되었습니다.",
            style: TextStyle(
              color: Colors.red,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          );
        }

        String hoursLeft = timeLeft.inHours.toString().padLeft(2, '0');
        String minutesLeft = (timeLeft.inMinutes % 60).toString().padLeft(2, '0');

        return Text(
          "$hoursLeft시간 $minutesLeft분 남았습니다.",
          style: TextStyle(
            color: AppColors.textBlue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}

class CharacterImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/character.png', // 이미지 경로
      height: 150,
    );
  }
}

class ChallengePrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('challenges')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text(
            "오늘의 챌린지는 준비 중입니다.",
            style: TextStyle(
              color: AppColors.textBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          );
        }

        var data = snapshot.data!;
        return Text(
          "오늘의 챌린지: ${data['challengePrompt'] ?? '오늘의 챌린지는?'}",
          style: TextStyle(
            color: AppColors.textBlue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
