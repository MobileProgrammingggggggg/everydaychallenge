import 'package:flutter/material.dart';
import 'CustomBottomNavigationBar.dart';

class CalendarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("캘린더")),
      body: Center(child: Text("캘린더 화면")),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
