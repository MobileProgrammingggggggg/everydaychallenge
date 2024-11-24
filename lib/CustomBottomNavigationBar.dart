import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/Ranking_screen.dart';
import 'package:test_flutter/Store_screen.dart';

import 'Main_test.dart';
import 'Calendar_screen.dart';
// import 'Community_Screen.dart';
import 'Community_GetX.dart';
import 'Store_screen.dart';

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
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChallengeScreen()),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CalendarScreen()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StoreScreen()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RankingScreen()),
            );
            break;
          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CommunityScreen()),
            );
            break;
        }
      },
    );
  }
}