import 'package:flutter/material.dart';
import 'Error_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth 패키지 추가
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 추가
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:emailjs/emailjs.dart' as emailjs;

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
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

  /// 이메일JS를 활용한 이메일 전송 함수
  Future<void> _sendEmailWithEmailJS(String email, String userId, String password) async {
    try {

      String message;
      if (password == "") {
        message = '당신의 아이디는 $userId 입니다';
      } else {
        message = '당신의 비밀번호는 $password 입니다';
      }

      var response = await emailjs.send(
        'service_vihaimt', // EmailJS의 Service ID
        'template_vihaimt', // EmailJS의 Template ID
        {
          'to_email': email,
          'to_name': '사용자', // 수신자 이름
          'from_name': '고모프 공용 이메일', // 발신자 이름
          'message': message, // 동적으로 설정된 message 사용
        },
        const emailjs.Options(
          publicKey: 'hEfci6F_djHA8hvjV', // EmailJS Public Key
          privateKey: 'ivIuEvPfFlCNvRzKXMAJx', // (필요시) Private Key
        ),
      );
      print('EmailJS 전송 성공: $response');
      _showErrorDialog(context, '가입된 이메일로 ID가 전송되었습니다.');
    } catch (e) {
      print('EmailJS 전송 실패: $e');
      _showErrorDialog(context, '이메일 전송에 실패했습니다: ${e.toString()}');
    }
  }

  //////////////////////////////////////////////////////////////////////////////

  /// Firestore에서 이메일로 사용자 ID 조회 후 전송
  void _sendEmailWithId(BuildContext context) async {
    String email = _emailController.text;

    if (email.isEmpty) {
      _showErrorDialog(context, 'Email을 입력해주세요.');
      return;
    }

    try {
      // Firestore에서 사용자 정보 가져오기
      var result = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (result.docs.isNotEmpty) {
        String userId = result.docs.first['id'];

        // EmailJS로 메일 보내기
        await _sendEmailWithEmailJS(email, userId, "");
      } else {
        _showErrorDialog(context, '해당 이메일에 대한 사용자가 없습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
      _showErrorDialog(context, '오류 발생: ${e.toString()}');
    }
  }

  /// Firestore에서 ID로 사용자 정보 조회 후 이메일 전송
  void _sendEmailWithPassword(BuildContext context) async {
    String id = _idController.text;

    if (id.isEmpty) {
      _showErrorDialog(context, 'ID를 입력해주세요.');
      return;
    }

    try {
      // Firestore에서 ID로 사용자 정보 가져오기
      var result = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: id)
          .get();

      if (result.docs.isNotEmpty) {
        String email = result.docs.first['email']; // 이메일 가져오기
        String password = result.docs.first['password']; // 이메일 가져오기

        // EmailJS로 메일 보내기
        // await _sendEmailWithEmailJS(email, userID, password);

        // Firebase 내장된 비밀번호 재설정 이메일 보내기
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        _showErrorDialog(context, '비밀번호 재설정 링크를 전송하였습니다!');
      } else {
        _showErrorDialog(context, '해당 ID에 대한 사용자가 없습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
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
                        onPressed: () {
                          _sendEmailWithPassword(context);
                        },
                        child: Text(
                          'Email로 비밀번호 재설정 링크가 전송됩니다.',
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
