import 'package:flutter/material.dart';
import 'CustomBottomNavigationBar.dart';

class StoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("상점")),
      body: Center(child: Text("상점 화면")),
      bottomNavigationBar: CustomBottomNavigationBar()
    );
  }
}