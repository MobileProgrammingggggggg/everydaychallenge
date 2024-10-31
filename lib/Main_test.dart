import 'package:flutter/material.dart';

void main() {
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
      appBar: CustomAppBar(),
      body: GradientBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HeaderSection(),
            CountdownText(),
            CharacterImage(),
            ChallengePrompt(),
            ChallengeButton(),
          ],
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
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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
    // Implement your logout logic here
    print("User logged out.");
    // You might want to navigate to the login page or clear user data
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

class CharacterImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://i.ibb.co/LnBF844/image.jpg', // Ensure you add the character image in assets
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
        color: Colors.blue,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class ChallengeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              child: Text(
                "챌린지 뽑기",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          SizedBox(height: 20), // 버튼 아래에 간격 추가
        ],
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // 간격 크기 고정
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "캘린더"),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: "상점"),
        BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: "랭킹"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "커뮤니티"),
      ],
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true, // 비선택 아이템의 라벨을 보여줌
      showSelectedLabels: true, // 선택 아이템의 라벨을 보여줌
    );
  }
}

//ChallengeScreen: 화면 전체 구조를 정의하고, 필요한 위젯을 불러옵니다.
//CustomAppBar: 앱의 상단 바를 담당하는 컴포넌트입니다. NotificationIcon 컴포넌트로 알림 아이콘을 분리했습니다.
//GradientBackground: 배경 그라데이션을 담당하는 컴포넌트로, 다른 컴포넌트에서 재사용할 수 있습니다.
//HeaderSection: 화면 상단에 포인트와 달성률을 표시하는 섹션입니다.
//CountdownText: 남은 시간을 표시하는 컴포넌트입니다.
//CharacterImage: 캐릭터 이미지를 표시하는 컴포넌트입니다.
//ChallengePrompt: "오늘의 챌린지는?" 텍스트를 표시합니다.
//ChallengeButton: 챌린지 버튼을 위한 컴포넌트입니다.
//CustomBottomNavigationBar: 하단 네비게이션 바를 담당하는 컴포넌트입니다.
