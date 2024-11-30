import 'package:flutter/material.dart';
import 'global.dart';

class Notification_Screen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<Notification_Screen> {
  List<NotificationCardData> notifications = [];

  @override
  void initState() {
    super.initState();
    notifications = globalNotifications; // 전역 변수에서 알림 가져오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("알림"),
        backgroundColor: Colors.pink[100],
      ),
      body: notifications.isEmpty
          ? _buildEmptyNotification()
          : ListView(
              children: notifications.map((notification) {
                return NotificationCard(
                  icon: notification.icon,
                  title: notification.title,
                  description: notification.description,
                  titleStyle:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  descriptionStyle:
                      TextStyle(color: Colors.grey[700], fontSize: 14),
                );
              }).toList(),
            ),
      floatingActionButton: TextButton(
        onPressed: () {
          setState(() {
            globalNotifications.clear(); // 알림 초기화
            notifications.clear(); // 현재 표시된 알림도 초기화
          });
        },
        child: Text("알림 전체 지우기", style: TextStyle(color: Colors.white)),
        style: TextButton.styleFrom(
          backgroundColor: Colors.pink[100], // 배경색
        ),
      ),
    );
  }

  Widget _buildEmptyNotification() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 80, color: Colors.grey), // 아이콘 추가
          SizedBox(height: 20), // 간격 추가
          Text(
            "현재 알림이 없습니다.",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10), // 간격 추가
          Text(
            "알림이 생기면 여기에서 확인하세요!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationCardData {
  final IconData icon;
  final String title;
  final String description;

  NotificationCardData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;

  NotificationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.titleStyle,
    required this.descriptionStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.amber, size: 24),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle),
                  Text(description, style: descriptionStyle),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}