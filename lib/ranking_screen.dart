import 'package:flutter/material.dart';
import 'CustomBottomNavigationBar.dart';

class RankingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("랭킹")),
      body: Center(child: Text("랭킹 화면")),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
