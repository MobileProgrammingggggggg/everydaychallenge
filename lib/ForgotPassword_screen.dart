import 'package:flutter/material.dart';
import 'Error_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('아이디 / 비밀번호 찾기'),
        centerTitle: true,
        backgroundColor: Colors.white, // 앱바 배경색을 흰색으로 설정
      ),
      backgroundColor: Colors.white, // 전체 배경색을 흰색으로 설정
      body: Padding(
        padding: const EdgeInsets.all(100.0),
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
              SizedBox(height: 10), // 제목과 블록 사이 간격
              Container(
                padding: const EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2), // 테두리 추가
                  borderRadius: BorderRadius.circular(10), // 테두리 모서리 둥글게
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                  children: [
                    // 이메일 입력 텍스트 추가
                    Text(
                      'Email',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.black), // 텍스트 색상 설정
                      cursorColor: Colors.black, // 커서 색상 설정
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
                    // 비밀번호 찾기 버튼
                    SizedBox(
                      width: double.infinity, // 버튼을 가로로 꽉 차게
                      child: ElevatedButton(
                        onPressed: () {
                          // 비밀번호 찾기 처리 로직 추가
                          String email = _emailController.text;

                          if (email.isEmpty) {
                            _showErrorDialog(context, 'Email을 입력해주세요.');
                          } else {
                            print('입력한 이메일: $email');
                          }

                          print('입력한 이메일: $email');
                          // 실제 비밀번호 찾기 로직을 추가할 수 있습니다.
                        },
                        child: Text('Email로 ID가 전송됩니다.'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // 배경색 검은색
                          foregroundColor: Colors.white, // 글자색 흰색
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30), // 비밀번호 찾기와 아이디 찾기 사이 간격
              // 아이디 찾기 제목과 블록
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '비밀번호 찾기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10), // 제목과 블록 사이 간격
              Container(
                padding: const EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2), // 테두리 추가
                  borderRadius: BorderRadius.circular(10), // 테두리 모서리 둥글게
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                  children: [
                    // 아이디 입력 텍스트 추가
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
                    // 아이디 찾기 버튼
                    SizedBox(
                      width: double.infinity, // 버튼을 가로로 꽉 차게
                      child: ElevatedButton(
                        onPressed: () {
                          // 아이디 찾기 처리 로직 추가
                          String id = _idController.text;

                          if (id.isEmpty) {
                            _showErrorDialog(context, 'ID를 입력해주세요.');
                          } else {
                            print('입력한 아이디: $id');
                          }
                          // 실제 아이디 찾기 로직을 추가할 수 있습니다.
                        },
                        child: Text(
                          '가입된 Email로 비밀번호가 전송됩니다.',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
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
