import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test_flutter/themes/colors.dart';
import 'CustomBottomNavigationBar.dart';

class RankingScreen extends StatefulWidget {
  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  List<QueryDocumentSnapshot> users = [];
  bool isLoading = true; // 로딩 상태

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // 데이터를 처음에 가져옵니다.
  }

  // 데이터를 가져오고 업데이트하는 함수
  // 이유 모르겠고 소스 복붙하다가 갑자기 됨 개꿀
  Future<void> _fetchUsers() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('users').get();
      final usersList = snapshot.docs;

      if (usersList.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // // score 필드가 없는 유저들에 대해 score 0 값 추가
      // List<Future> updateFutures = [];
      // for (var user in usersList) {
      //   if (user.get('score') == null) {
      //     updateFutures.add(
      //       FirebaseFirestore.instance.collection('users').doc(user.id).set(
      //         {
      //           'score': 0, // score 필드가 없으면 0로 설정
      //         },
      //         SetOptions(merge: true), // 기존 데이터를 덮어쓰지 않고 병합
      //       ),
      //     );
      //   }
      // }
      //
      // // 모든 update 작업이 완료되기를 기다린 후 UI 갱신
      // await Future.wait(updateFutures);

      setState(() {
        users = usersList; // 유저 리스트 갱신
        isLoading = false; // 로딩 상태 종료
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("데이터 가져오기 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[100],
        elevation: 0,
        title: Text(
          "랭킹",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 데이터 로딩 중
          : _buildRankingList(), // 데이터 로딩 완료 후 화면 구성
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildRankingList() {
    final sortedUsers = List.from(users)
      ..sort((a, b) {
        final scoreA = a.get('score') != null
            ? int.tryParse(a.get('score').toString()) ?? 0
            : 0;

        final scoreB = b.get('score') != null
            ? int.tryParse(b.get('score').toString()) ?? 0
            : 0;

        return scoreB.compareTo(scoreA); // 내림차순 정렬
      });

    // Widget _buildRankingList() {
    //   // `dDay`와 `score`의 곱을 기준으로 내림차순 정렬
    //   final sortedUsers = List.from(users)
    //     ..sort((a, b) {
    //       final scoreA = a.get('score') != null
    //           ? int.tryParse(a.get('score').toString()) ?? 0
    //           : 0;
    //
    //       final dDayA = a.get('dDay') != null
    //           ? int.tryParse(a.get('dDay').toString()) ?? 0
    //           : 0;
    //
    //       final scoreB = b.get('score') != null
    //           ? int.tryParse(b.get('score').toString()) ?? 0
    //           : 0;
    //
    //       final dDayB = b.get('dDay') != null
    //           ? int.tryParse(b.get('dDay').toString()) ?? 0
    //           : 0;
    //
    //       final rankValueA = scoreA * dDayA;
    //       final rankValueB = scoreB * dDayB;
    //
    //       return rankValueB.compareTo(rankValueA); // 내림차순 정렬
    //     });

    return Column(
      children: [
        Container(
          height: 250, // 높이를 키워서 전체 영역을 확대
          padding: EdgeInsets.symmetric(vertical: 20), // 패딩을 추가하여 위아래로 여유 공간 부여
          child: Column( // Column으로 변경하여 수직 방향으로 정렬
            mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙에 배치
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTopRankItem(
                      sortedUsers.length > 1
                          ? sortedUsers[1].get('score')?.toString() ?? "도전 중"
                          : "도전 중",
                      '2등',
                      sortedUsers.length > 1
                          ? sortedUsers[1].get('id') ?? 'Unknown'
                          : 'user',
                      Color(0xFFC0C0C0)),
                  _buildTopRankItem(
                      sortedUsers.isNotEmpty
                          ? sortedUsers[0].get('score')?.toString() ?? "도전 중"
                          : "도전 중",
                      '1등',
                      sortedUsers.isNotEmpty
                          ? sortedUsers[0].get('id') ?? 'Unknown'
                          : 'user',
                      Color(0xFFFFD700),
                      isCrowned: true), // 1등의 원을 더 크게 설정
                  _buildTopRankItem(
                      sortedUsers.length > 2
                          ? sortedUsers[2].get('score')?.toString() ?? "도전 중"
                          : "도전 중",
                      '3등',
                      sortedUsers.length > 2
                          ? sortedUsers[2].get('id') ?? 'Unknown'
                          : 'user',
                      Color(0xFFCD7F32)),
                ],
              ),
            ],
          ),
        ),


        Divider(
          color: Colors.pink[100],
          thickness: 2,
          indent: 16,
          endIndent: 16,
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: sortedUsers.length - 3 > 0 ? sortedUsers.length - 3 : 0,
            itemBuilder: (context, index) {
              final user = sortedUsers[index + 3]; // 4등부터 시작
              final rank = index + 4; // 순위 계산

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.pink[100], // 회색 배경
                  child: Text(
                    '$rank', // 회색 원 안에 순위만 표시
                    style: TextStyle(
                      color:  Color(0xFF7E7E7E), // 숫자 색상
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(user.get('id') ?? 'Unknown'), // 이름만 표시
                trailing: Text(user.get('score') != null
                    ? user.get('score')?.toString() ?? "도전 중"
                    : "도전 중"), // 스코어를 오른쪽에 배치
              );
            },
          ),
        ),


      ],
    );
  }



  Widget _buildTopRankItem(String score, String rank, String name, Color color,
      {bool isCrowned = false}) {
    // 순위에 따른 크기와 스타일 설정
    double width, height, fontSize, borderWidth;
    Color borderColor;

    switch (rank) {
      case '1등':
        width = 110;
        height = 110;
        fontSize = 22;
        borderWidth = 4;
        borderColor = Colors.amber;
        break;
      case '2등':
        width = 90;
        height = 90;
        fontSize = 20;
        borderWidth = 3;
        borderColor = Colors.grey;
        break;
      case '3등':
        width = 70;
        height = 70;
        fontSize = 18;
        borderWidth = 2;
        borderColor = Colors.brown;
        break;
      default:
        width = 70;
        height = 70;
        fontSize = 16;
        borderWidth = 1.5;
        borderColor = Colors.pink[100]!;
        break;
    }

    return Column(
      children: [
        if (rank == '1등')
          Icon(FontAwesomeIcons.crown, color: Colors.amber, size: 30),
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: BoxShape.circle, // 원 모양
            color: color, // 원의 색상
            border: Border.all(
              color: borderColor, // 테두리 색상
              width: borderWidth, // 테두리 두께
            ),
          ),
          child: Center(
            child: Text(
              name.length > 4 ? '${name.substring(0, 4)}..' : name,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: rank == '1등' ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize - 2, // 이름 텍스트 크기는 약간 더 작게
          ),
        ),
        SizedBox(height: 4),
        Text(
          score, // 점수 또는 "도전 중" 표시
          style: TextStyle(
            color: rank == '1등' ? Colors.amber : Colors.black,
            fontSize: fontSize - 2, // 점수 텍스트 크기 조정
          ),
        ),
      ],
    );
  }


  Widget _buildRankRow(String score, String rank, String name) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade300,
        child: Text(name[0].toUpperCase()),
      ),
      title: Text(name),
      trailing: Text(
        score,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
