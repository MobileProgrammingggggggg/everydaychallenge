import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'Main_test.dart'; // ChallengeScreen 클래스가 포함된 파일 import

// main.dart 파일 (Firebase 초기화 및 최상위 위젯 설정)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  runApp(AppInitializer());
}

class AppInitializer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeFirebase(),
      builder: (context, snapshot) {
        // Firebase 초기화 완료 여부 확인
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            // Firebase 초기화 중 오류가 발생한 경우
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('Firebase 초기화 실패: ${snapshot.error}'),
                ),
              ),
            );
          }
          // Firebase 초기화가 성공한 경우 MyApp 실행
          return MyApp();
        }
        // 초기화가 진행 중인 경우 로딩 화면 표시
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

  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("Firebase 초기화 성공");
    } catch (e) {
      print("Firebase 초기화 실패: $e");
      rethrow;
    }
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
