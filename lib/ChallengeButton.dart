import 'package:flutter/material.dart';
import 'package:test_flutter/themes/colors.dart';
import 'Roulette_test.dart';
import 'Success_screen.dart';
import 'Failure_screen.dart';
import 'Ask_again_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ChallengeButton extends StatefulWidget {
  final Function(String) onChallengeSelected; // 결과를 전달하기 위한 콜백 추가
  ChallengeButton({required this.onChallengeSelected});

  @override
  _ChallengeButtonState createState() => _ChallengeButtonState();
}

class _ChallengeButtonState extends State<ChallengeButton> {
  int flag = 1; // 기본 상태는 1 (챌린지 뽑기)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadFlag(); // Firebase에서 flag 상태 로드
  }

  void addPoints(int addedPoints) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'points': FieldValue.increment(addedPoints),
    });
  }

  // Firebase에서 flag 상태를 로드하는 메서드
  void _loadFlag() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid;

      try {
        DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();

        if (snapshot.exists && snapshot.data() != null) {
          setState(() {
            flag = snapshot['challengeFlag'] ?? 1; // Firebase에서 flag 값을 가져옴
          });
        }
      } catch (e) {
        print("Failed to load flag: $e");
      }
    }
  }

  // Firebase에 flag 상태를 저장하는 메서드
  void _updateFlag(int newFlag) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid;

      try {
        await _firestore.collection('users').doc(userId).set(
          {'challengeFlag': newFlag},
          SetOptions(merge: true),
        );
        print("Flag updated successfully");
      } catch (e) {
        print("Failed to update flag: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (flag == 1) // flag가 1일 때 챌린지 뽑기 버튼 표시
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Roulette()),
                ).then((value) {
                  if (value != null) {
                    // 선택된 값이 있는 경우 처리
                    widget.onChallengeSelected(value); // 콜백 호출로 상위에 결과 전달
                    setState(() {
                      flag = 2; // flag를 2로 설정
                      _updateFlag(flag); // Firebase에 상태 업데이트
                    });
                  } else {
                    // 선택값이 없는 경우 (예: 다이얼로그 닫기)
                    debugPrint("룰렛에서 값이 반환되지 않았습니다.");
                  }
                });
              },
              child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                child: Text(
                  "챌린지 뽑기",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            )
          else if (flag == 2) // flag가 2일 때 성공 및 실패 버튼 표시
            Wrap(
              spacing: 10, // 버튼 간의 간격
              alignment: WrapAlignment.center, // 버튼 중앙 정렬
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brightPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    int? result = await showDialog<int>(
                      context: context,
                      builder: (BuildContext context) {
                        return Ask_again(message: "정말 성공하셨습니까?");
                      },
                    );

                    if (result == 1) {
                      setState(() {
                        flag = 3; // 성공 상태로 변경
                        _updateFlag(flag); // Firebase에 flag 상태 업데이트
                      });

                      // 포인트 10점 추가
                      addPoints(10);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Succeed()), // 성공 화면 이동
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      "성공",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    int? result = await showDialog<int>(
                      context: context,
                      builder: (BuildContext context) {
                        return Ask_again(message: "정말 실패하셨습니까?");
                      },
                    );

                    if (result == 1) {
                      setState(() {
                        flag = 4; // 실패 상태로 변경
                        _updateFlag(flag); // Firebase에 flag 상태 업데이트
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Failed()), // 실패 화면 이동
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      "실패",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            )
          else // flag가 3 또는 4일 때 성공 또는 실패 메시지 표시
            Text(
              flag == 3 ? "성공~!" : "실패ㅠ", // 조건에 따라 메시지 변경
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}