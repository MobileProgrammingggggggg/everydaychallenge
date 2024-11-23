import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Notification_Screen extends StatefulWidget {
  final String userId;

  Notification_Screen({required this.userId}); // 유저 ID를 전달받도록 수정

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

  // 남은 시간 계산 메서드
  String _formatRemainingTime(Timestamp deadline) {
    final DateTime deadlineTime = deadline.toDate();
    final Duration difference = deadlineTime.difference(DateTime.now());

    if (difference.isNegative) {
      return "챌린지 마감 시간이 지났습니다!";
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      return "마감까지 ${hours}시간 ${minutes}분 남았습니다!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("알림"),
        backgroundColor: Colors.pink[100],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .doc(widget.userId)
            .collection('user_notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No notifications available.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final String title = doc['title'] ?? "Untitled Notification";
              final String description = doc['message'] ?? "No details.";
              final Timestamp? timestamp = doc['timestamp'];
              final String time = timestamp != null
                  ? _formatRemainingTime(timestamp) // 남은 시간 계산 호출
                  : "Unknown Time";
              final IconData icon = _getIcon(doc['type'] ?? 'default');

              return NotificationCard(
                icon: icon,
                title: title,
                description: description,
                time: time,
                titleStyle:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                descriptionStyle:
                TextStyle(color: Colors.grey[700], fontSize: 14),
                timeStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearNotifications,
        child: Icon(Icons.clear_all),
        backgroundColor: Colors.pink[100],
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.emoji_events;
      case 'challenge_deadline':
        return Icons.hourglass_bottom;
      case 'challenge_start':
        return Icons.flag;
      case 'new_items':
        return Icons.shopping_cart;
      case 'weekly_summary':
        return Icons.insert_chart;
      default:
        return Icons.notifications;
    }
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
