import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'Main_test.dart'; // ChallengeScreen이 정의된 파일을 임포트합니다.
import 'Login_screen.dart'; // 로그인 화면 위젯 추가

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // dotenv 초기화
  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    print("Failed to load .env file: $e");
  }

  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 숨기기
      home: AuthWrapper(), // 인증 상태에 따라 화면 분기
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Firebase 인증 상태 스트림
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()), // 로딩 중
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          // 로그인된 사용자라면 userId를 ChallengeScreen에 전달
          return ChallengeScreen(userId: snapshot.data!.uid);
        }
        return LoginScreen(); // 로그인되지 않은 상태면 로그인 화면으로
      },
    );
  }
}
