import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 추가
import 'Error_screen.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 에러 다이얼로그 표시
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(message: message);
      },
    );
  }

  // 회원가입 함수
  void _signUp(BuildContext context) async {
    String id = _idController.text.trim();
    String password = _passwordController.text.trim();
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorDialog(context, 'Email을 입력해주세요.');
      return;
    }
    if (id.isEmpty) {
      _showErrorDialog(context, 'ID를 입력해주세요.');
      return;
    }
    if (password.isEmpty) {
      _showErrorDialog(context, 'Password를 입력해주세요.');
      return;
    }

    try {
      // Firebase Authentication으로 회원가입
      final credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore에 추가 정보(ID) 저장
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user?.uid)
          .set({
        'id': id,
        'email': email,
        'createdAt': DateTime.now(),
        'password': password,
        'points': 1000, // 테스트용 포인트 1000 지급
        'score' : 0,
        'selected_challenges': [], // 룰렛 항목 저장할 배열
        '기록 삭제권': 0, // 아이템은 기본개수는 0으로 할것이지만
        '난이도 선택권': 0, // 초기화면에서 잘 불러와지는지 확인하기위해 임의의 개수 집어넣었고
        '룰렛 재추첨권': 0, // 아이템을 구매하면 실시간으로 업데이트되어 인벤토리에서 확인 가능함
        '챌린지 스킵권': 1,
        '포인트 2배권': 2,
        '하루 연장권': 3,
      });

      print('회원가입 성공: ${credential.user?.email}');
      _showErrorDialog(context, '회원가입 성공! 로그인 화면으로 이동하세요.');
      Navigator.pop(context); // 로그인 화면으로 이동
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code}'); // 에러 코드 출력
      if (e.code == 'email-already-in-use') {
        _showErrorDialog(context, '이미 등록된 이메일입니다.');
      } else if (e.code == 'weak-password') {
        _showErrorDialog(context, '비밀번호는 최소 6자 이상이어야 합니다.');
      } else if (e.code == 'invalid-email') {
        _showErrorDialog(context, '유효하지 않은 이메일 주소입니다.');
      } else {
        _showErrorDialog(context, '회원가입 실패: ${e.message}');
      }
    } catch (e) {
      _showErrorDialog(context, '알 수 없는 오류가 발생했습니다.');
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('회원가입'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email',
                        style: TextStyle(fontSize: 16, color: Colors.black)),
                    SizedBox(height: 5),
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        labelText: 'Email을 입력해주세요...',
                        labelStyle:
                        TextStyle(color: Colors.black54, fontSize: 12),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('ID',
                        style: TextStyle(fontSize: 16, color: Colors.black)),
                    SizedBox(height: 5),
                    TextField(
                      controller: _idController,
                      style: TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        labelText: 'ID를 입력해주세요...',
                        labelStyle:
                        TextStyle(color: Colors.black54, fontSize: 12),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Password',
                        style: TextStyle(fontSize: 16, color: Colors.black)),
                    SizedBox(height: 5),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        labelText: 'Password를 입력해주세요...',
                        labelStyle:
                        TextStyle(color: Colors.black54, fontSize: 12),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _signUp(context),
                        child: Text('회원가입'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}