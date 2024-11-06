import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
      ),
      body: ListView(
        children: [
          NotificationCard(
            icon: Icons.bolt,
            title: "Custom Action",
            description: "Action Description",
            time: "Time frame",
            titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            descriptionStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
            timeStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          NotificationCard(
            icon: Icons.assignment,
            title: "Task assigned to you",
            description: "Aye yo, do this ting bruv",
            time: "2 hours ago",
            subtitle: "Dunder Mifflin",
            titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            descriptionStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
            timeStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          NotificationCard(
            icon: Icons.notifications,
            title: "Notification triggered",
            description: "Michael is in the warehouse",
            time: "6 hours ago",
            subtitle: "Dunder Mifflin",
            titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            descriptionStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
            timeStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          // 추가된 알림 카드
          NotificationCard(
            icon: Icons.warning,
            title: "System Alert",
            description: "Low battery",
            time: "30 minutes ago",
            titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            descriptionStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
            timeStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          NotificationCard(
            icon: Icons.update,
            title: "Update Available",
            description: "New software update ready to install",
            time: "1 hour ago",
            titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            descriptionStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
            timeStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          NotificationCard(
            icon: Icons.mail,
            title: "New Message",
            description: "You have received a new message",
            time: "Just now",
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
