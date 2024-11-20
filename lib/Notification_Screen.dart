import 'package:flutter/material.dart';
import 'Notification_Screen.dart';  // 올바르게 Notification_Screen 파일을 임포트합니다.

class Notification_Screen extends StatefulWidget {
  @override
  _Notification_ScreenState createState() => _Notification_ScreenState();
}

class _Notification_ScreenState extends State<Notification_Screen> {
  int notificationCount = 5; // 초기 알림 갯수 설정

  void _clearNotifications() {
    setState(() {
      notificationCount = 0; // 알림 페이지에 들어가면 알림 갯수를 0으로 설정
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("알림"),
        backgroundColor: Colors.pink[100],
      ),
      body: ListView(
        children: [
          NotificationCard(
            icon: Icons.emoji_events,
            title: "3일 연속 성공!",
            description: "당신의 열정이 빛나고 있어요!",
            time: "방금 전",
            titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            descriptionStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
            timeStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          NotificationCard(
            icon: Icons.hourglass_bottom,
            title: "챌린지 마감 3시간 전",
            description: "마감까지 3시간 남았습니다! 지금 도전하세요!",
            time: "3시간 전",
            titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            descriptionStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
            timeStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          NotificationCard(
            icon: Icons.flag,
            title: "오늘 챌린지 시작!",
            description: "오늘의 챌린지가 시작됐습니다! 도전을 기다리고 있어요!",
            time: "오늘",
            titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            descriptionStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
            timeStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          NotificationCard(
            icon: Icons.shopping_cart,
            title: "상점에 새로운 아이템 입고",
            description: "새로운 아이템이 상점에 도착했습니다! 지금 확인해보세요!",
            time: "1시간 전",
            titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            descriptionStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
            timeStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          NotificationCard(
            icon: Icons.insert_chart,
            title: "주간요약",
            description: "한 주간의 성과를 확인하세요! 멋진 한 주였어요!",
            time: "어제",
            titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            descriptionStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
            timeStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearNotifications, // 알림 갯수 초기화 메서드 연결
        child: Icon(Icons.clear_all),
        backgroundColor: Colors.pink[100],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String time;
  final String? subtitle;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final TextStyle timeStyle;

  NotificationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    this.subtitle,
    required this.titleStyle,
    required this.descriptionStyle,
    required this.timeStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(color: Colors.grey),
              ),
            Row(
              children: [
                Icon(icon, color: Colors.amber, size: 24),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: titleStyle),
                    Text(description, style: descriptionStyle),
                    SizedBox(height: 5),
                    Text(time, style: timeStyle),
                  ],
                ),
              ],
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
    return Stack(
      alignment: Alignment.topRight,
      children: [
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Notification_Screen()), // 올바르게 Notification_Screen 클래스를 참조합니다.
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
