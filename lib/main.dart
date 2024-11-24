import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'Main_test.dart'; // ChallengeScreen 클래스가 포함된 파일 import

// main.dart 파일 (Firebase 초기화 및 최상위 위젯 설정)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AppInitializer());
}

class AppInitializer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('Firebase 초기화 실패: ${snapshot.error}'),
                ),
              ),
            );
          }
          return MyApp();
        }

        // Firebase 초기화가 진행 중인 경우 로딩 화면 표시
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChallengeScreen(), // 최상위 화면으로 ChallengeScreen 설정
    );
  }
}
