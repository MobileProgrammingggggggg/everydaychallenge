import 'package:flutter/material.dart';
import 'CustomBottomNavigationBar.dart';

// 이건 걍 처음부터 잇던 기본 화면임
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("홈")),
      body: Center(child: Text("홈 화면")),
      // bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
