import 'package:flutter/material.dart';
import 'Error_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth 패키지 추가
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 추가

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(message: message); // ErrorDialog 호출
      },
    );
  }

  void _sendEmailWithId(BuildContext context) async {
    String email = _emailController.text;

    if (email.isEmpty) {
      _showErrorDialog(context, 'Email을 입력해주세요.');
      return;
    }

    // Firestore에서 이메일로 사용자 정보를 가져오기
    try {
      var result = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (result.docs.isNotEmpty) {
        String userId = result.docs.first['id']; // 첫 번째 사용자 ID 가져오기
        print('ID가 이메일로 전송됩니다: $userId'); // 어떤 ID가 전송되는지 확인
        print('이메일로 전송되는 이메일: $email'); // 어떤 이메일로 전송되는지 확인
        _showErrorDialog(context, '가입된 이메일로 ID가 전송되었습니다.');
      } else {
        _showErrorDialog(context, '해당 이메일에 대한 사용자가 없습니다.');
      }
    } catch (e) {
      _showErrorDialog(context, '오류 발생: ${e.toString()}');
    }
  }

  void _resetPassword(BuildContext context) async {
    String id = _idController.text;

    if (id.isEmpty) {
      _showErrorDialog(context, 'ID를 입력해주세요.');
      return;
    }

    // Firestore에서 ID로 이메일을 가져오기
    try {
      var result = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: id)
          .get();

      if (result.docs.isNotEmpty) {
        String email = result.docs.first['email']; // 첫 번째 이메일 가져오기
        print('비밀번호 재설정 이메일이 전송됩니다: $email'); // 어떤 이메일로 전송되는지 확인
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        _showErrorDialog(context, '비밀번호 재설정 이메일이 전송되었습니다.');
      } else {
        _showErrorDialog(context, '해당 ID에 대한 사용자가 없습니다.');
      }
    } catch (e) {
      _showErrorDialog(context, '오류 발생: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('아이디 / 비밀번호 찾기'),
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
              // 비밀번호 찾기 제목과 블록
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ID 찾기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        labelText: 'Email을 입력해주세요...',
                        labelStyle: TextStyle(color: Colors.black54, fontSize: 12),
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
                        onPressed: () {
                          _sendEmailWithId(context);
                        },
                        child: Text('Email로 ID가 전송됩니다.'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              // 아이디 찾기 제목과 블록
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '비밀번호 찾기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: _idController,
                      style: TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        labelText: 'ID를 입력해주세요...',
                        labelStyle: TextStyle(color: Colors.black54, fontSize: 12),
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
                        onPressed: () {
                          _resetPassword(context);
                        },
                        child: Text(
                          '가입된 Email로 비밀번호가 전송됩니다.',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
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
