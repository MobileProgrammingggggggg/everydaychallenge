import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/Ranking_screen.dart';
import 'package:test_flutter/Store_screen.dart';

import 'Main_test.dart';
import 'Calendar_screen.dart';
// import 'Community_Screen.dart';
import 'Community_GetX.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex; // 외부에서 currentIndex를 전달받음

  CustomBottomNavigationBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.only(bottom: 10), // 네비게이션 바 아래쪽에 10픽셀 띄움
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade100, Colors.pink.shade100], // 더 강한 핑크로 수정
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)), // 둥근 모서리
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // 그림자 효과로 플로팅 효과 강조
            blurRadius: 10,
            offset: Offset(0, -5), // 위로 떠있는 효과
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex, // currentIndex 값을 전달받아 설정
        type: BottomNavigationBarType.fixed, // 간격 크기 고정
        selectedItemColor: Colors.white, // 선택된 아이템의 색상
        unselectedItemColor: Colors.black54, // 비선택된 아이템의 색상
        showUnselectedLabels: true, // 비선택 아이템의 라벨을 보여줌
        showSelectedLabels: true, // 선택 아이템의 라벨을 보여줌
        backgroundColor: Colors.transparent, // 배경을 투명하게 설정
        elevation: 0, // 기본 그림자 제거
        iconSize: 24, // 아이콘 크기 설정
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
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "홈",
            backgroundColor: Colors.transparent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "캘린더",
            backgroundColor: Colors.transparent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: "상점",
            backgroundColor: Colors.transparent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: "랭킹",
            backgroundColor: Colors.transparent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "커뮤니티",
            backgroundColor: Colors.transparent,
          ),
        ],
      ),
    );
  }
}
