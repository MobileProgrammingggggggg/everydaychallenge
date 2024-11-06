import 'package:flutter/material.dart';
import 'Roulette_test.dart';
import 'Success_screen.dart';
import 'Failure_screen.dart';
import 'ask_again_screen.dart';

class ChallengeButton extends StatefulWidget {
  @override
  _ChallengeButtonState createState() => _ChallengeButtonState();
}

class _ChallengeButtonState extends State<ChallengeButton> {
  int flag = 1; // 룰렛 사용 여부 확인
  // 이 부분을 데이터베이스에서 가져와야 다른 화면에서 다시 불러와도 그 전 정보를 유지함.
  // 화면을 새로 불러올때마다 flag 변수를 1로 설정하기 때문에 챌린지를 다시 뽑아야 하는것.

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
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                // flag 값을 0으로 변경하고 룰렛 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Roulette()), // flag가 1일 때
                );
                setState(() {
                  flag = 2; // 상태 변경
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(92, 103, 227, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    // 성공 버튼 클릭 시 확인 팝업
                    int? result = await showDialog<int>(
                      context: context,
                      builder: (BuildContext context) {
                        return ask_again(message: "정말 성공하셨습니까?");
                      },
                    );

                    // 확인 버튼 클릭 시 성공 화면으로 이동
                    if (result == 1) {
                      setState(() {
                        flag = 3; // 상태 변경
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Succeed()), // 성공 화면으로 이동
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
                    child: Text(
                      "성공",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    // 실패 버튼 클릭 시 확인 팝업
                    int? result = await showDialog<int>(
                      context: context,
                      builder: (BuildContext context) {
                        return ask_again(message: "정말 실패하셨습니까?");
                      },
                    );

                    // 확인 버튼 클릭 시 실패 화면으로 이동
                    if (result == 1) {
                      setState(() {
                        flag = 4; // 상태 변경
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Failed()), // 실패 화면으로 이동
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
                    child: Text(
                      "실패",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            )
          else // flag가 3또는 4일 때 성공 또는 실패 메시지 표시
            Text(
              flag == 3 ? "성공~!" : "실패ㅠ", // 조건에 따라 메시지 변경
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
