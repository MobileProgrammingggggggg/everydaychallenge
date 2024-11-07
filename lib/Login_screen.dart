import 'package:flutter/material.dart';
import 'ForgotPassword_screen.dart';
import 'SignUp_screen.dart';
import 'Error_screen.dart';
import 'Main_test.dart';

void main() {
  runApp(Login());
}

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '로그인 화면',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

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
        title: Text('로그인'),
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
              // 이미지 추가
              Image.asset(
                'assets/images/logo.png', // 이미지 경로
                height: 250, // 이미지 높이 설정
                width: 400,
              ),
              SizedBox(height: 30), // 이미지와 다음 요소 간격
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
                          // 로그인 처리 로직 추가
                          String id = _idController.text;
                          String password = _passwordController.text;

                          if (id.isEmpty) {
                            _showErrorDialog(context, 'ID를 입력해주세요.');
                          } else if (password.isEmpty) {
                            _showErrorDialog(context, 'Password를 입력해주세요.');
                          } else {
                            // 로그인 처리 로직 추가
                            print('입력한 아이디: $id');
                            print('입력한 비밀번호: $password');

                            if (id == "user" && password == "1234") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MyApp()),
                              );
                            }
                            else{
                              _showErrorDialog(context, '유저 정보가 없습니다.');
                            }
                          }
                        },
                        child: Text('로그인'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // 배경색 검은색
                          foregroundColor: Colors.white, // 글자색 흰색
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // "비밀번호를 잊으셨나요?" 및 "회원가입" 텍스트 추가
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // 새로운 화면으로 이동하는 로직
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPasswordScreen()),
                            );
                          },
                          child: Text(
                            '비밀번호를 잊으셨나요?',
                            style: TextStyle(color: Colors.blue, fontSize: 14),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // 회원가입 화면으로 이동하는 로직
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpScreen()),
                            );
                          },
                          child: Text(
                            '회원가입',
                            style: TextStyle(color: Colors.blue, fontSize: 14),
                          ),
                        ),
                      ],
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
