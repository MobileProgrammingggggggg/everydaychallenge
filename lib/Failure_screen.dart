import 'package:flutter/material.dart';

class fail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("실패")),
      body: Center(child: Text("실패 화면")),
    );
  }
}