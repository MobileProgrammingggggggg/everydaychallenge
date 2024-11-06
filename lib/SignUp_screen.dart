import 'package:flutter/material.dart';
import 'Error_screen.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(message: message); // ErrorDialog 호출
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        title: Text('회원가입'),
        centerTitle: true, // 제목을 가운데 정렬
        backgroundColor: Colors.white, // 앱바 배경색을 흰색으로 설정
      ),
      backgroundColor: Colors.white, // 앱 전체 배경색을 흰색으로 설정
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2), // 테두리 추가
                  borderRadius: BorderRadius.circular(10), // 테두리 모서리 둥글게
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
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
                      // 커서 색상 설정
                      decoration: InputDecoration(
                        labelText: 'Email을 입력해주세요...',
                        labelStyle:
                            TextStyle(color: Colors.black54, fontSize: 12),
                        // 연한 레이블 색상 설정
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black), // 기본 테두리 색상
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black), // 포커스 시 테두리 색상
                        ),
                        floatingLabelBehavior:
                            FloatingLabelBehavior.never, // 레이블 애니메이션 제거
                      ),
                    ),
                    SizedBox(height: 20),
                    // ID 텍스트 추가
                    Text(
                      'ID',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: _idController,
                      style: TextStyle(color: Colors.black), // 텍스트 색상 설정
                      cursorColor: Colors.black, // 커서 색상 설정
                      decoration: InputDecoration(
                        labelText: 'ID를 입력해주세요...',
                        labelStyle:
                            TextStyle(color: Colors.black54, fontSize: 12),
                        // 연한 레이블 색상 설정
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black), // 기본 테두리 색상
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black), // 포커스 시 테두리 색상
                        ),
                        floatingLabelBehavior:
                            FloatingLabelBehavior.never, // 레이블 애니메이션 제거
                      ),
                    ),
                    SizedBox(height: 20),
                    // Password 텍스트 추가
                    Text(
                      'Password',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      // 커서 색상 설정
                      decoration: InputDecoration(
                        labelText: 'Password를 입력해주세요...',
                        labelStyle:
                            TextStyle(color: Colors.black54, fontSize: 12),
                        // 연한 레이블 색상 설정
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black), // 기본 테두리 색상
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black), // 포커스 시 테두리 색상
                        ),
                        floatingLabelBehavior:
                            FloatingLabelBehavior.never, // 레이블 애니메이션 제거
                      ),
                    ),
                    SizedBox(height: 20),

                    // 로그인 버튼
                    SizedBox(
                      width: double.infinity, // 버튼을 가로로 꽉 차게
                      child: ElevatedButton(
                        onPressed: () {
                          // 회원가입 처리 로직 추가
                          String id = _idController.text;
                          String password = _passwordController.text;
                          String email = _emailController.text;

                          if (email.isEmpty) {
                            _showErrorDialog(context, 'Email을 입력해주세요.');
                          } else if (id.isEmpty) {
                            _showErrorDialog(context, 'ID를 입력해주세요.');
                          } else if (password.isEmpty) {
                            _showErrorDialog(context, 'Password를 입력해주세요.');
                          } else {
                            // 회원가입 처리 로직 추가
                            print('입력한 이메일: $email');
                            print('입력한 아이디: $id');
                            print('입력한 비밀번호: $password');
                          }
                        },
                        child: Text('회원가입'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // 배경색 검은색
                          foregroundColor: Colors.white, // 글자색 흰색
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
