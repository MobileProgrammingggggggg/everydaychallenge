import 'package:flutter/material.dart';
import 'CustomBottomNavigationBar.dart';

class CommunityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("커뮤니티")),
      body: Center(child: Text("커뮤니티 화면")),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}