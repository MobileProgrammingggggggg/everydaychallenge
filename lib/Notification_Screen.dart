import 'package:flutter/material.dart';

class Notification_Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("알림"),
      ),
      body: ListView(
        children: [
          NotificationCard(
            icon: Icons.emoji_events, // 도전 아이콘
            title: "3일 연속 성공!",
            description: "당신의 열정이 빛나고 있어요!",
            time: "방금 전",
            titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            descriptionStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
            timeStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          NotificationCard(
            icon: Icons.hourglass_bottom, // 마감 아이콘
            title: "챌린지 마감 3시간 전",
            description: "마감까지 3시간 남았습니다! 지금 도전하세요!",
            time: "3시간 전",
            titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            descriptionStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
            timeStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          NotificationCard(
            icon: Icons.flag, // 챌린지 시작 아이콘
            title: "오늘 챌린지 시작!",
            description: "오늘의 챌린지가 시작됐습니다! 도전을 기다리고 있어요!",
            time: "오늘",
            titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            descriptionStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
            timeStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          NotificationCard(
            icon: Icons.shopping_cart, // 상점 아이콘
            title: "상점에 새로운 아이템 입고",
            description: "새로운 아이템이 상점에 도착했습니다! 지금 확인해보세요!",
            time: "1시간 전",
            titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            descriptionStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
            timeStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          NotificationCard(
            icon: Icons.insert_chart, // 주간 요약 아이콘
            title: "주간요약",
            description: "한 주간의 성과를 확인하세요! 멋진 한 주였어요!",
            time: "어제",
            titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            descriptionStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
            timeStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
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
