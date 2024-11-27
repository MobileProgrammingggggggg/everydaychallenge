import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test_flutter/themes/colors.dart';
import 'CustomBottomNavigationBar.dart';

class RankingScreen extends StatelessWidget {
  get random => null;

  get title => null;

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
      body: Column(
        children: [
          // 탭 버튼
        Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center
        ),
      ),


    // 상위 3명의 랭킹
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTopRankItem(421, '2등', 'user1', AppColors.aquaBlue),
                _buildTopRankItem(409, '1등', 'user2', AppColors.melonOrange, isCrowned: true),
                _buildTopRankItem(362, '3등', 'user3', AppColors.aquaBlue),
              ],
            ),
          ),
          Divider(
          color: Colors.grey.shade300,       // 선의 색상
          thickness: 2,             // 선의 두께
          indent: 16,               // 시작 지점 여백 (왼쪽 여백)
          endIndent: 16,            // 끝 지점 여백 (오른쪽 여백)
          ),
          //  나머지 랭킹 리스트
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: List.generate(10, (index) {
                return _buildRankRow(index + 4, 'user',  0);
              }),
            ),
          ),
        ],
      ),
        bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 3),
    );
  }



  /*Widget _buildTabButton(BuildContext context, String text, bool isSelected, {double width = 100}) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink[200] : Colors.blue[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      )
    );
  }*/

  Widget _buildTopRankItem(int rank, String name, String score, Color color, {bool isCrowned = false}) {
    return Column(
      children: [
        if (isCrowned) Icon(FontAwesomeIcons.crown, color: Colors.amber, size: 24), // 왕관 아이콘
        CircleAvatar(
          radius: 30,
          backgroundColor: color,
          child: Text(
            name,
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(height: 8),
        Text(score, style: TextStyle(color: Colors.black)),
        SizedBox(height: 8),
        Text('$rank', style: TextStyle(color: Colors.black, fontSize: 18)),
      ],
    );
  }

  Widget _buildRankRow(int rank, String name, int score) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade300,
        child: Text(name[0]),  // 첫 글자만 표시
      ),
      title: Text(name), // 이름 전체 표시
      trailing: Text(
        '$score', // 점수 표시
        style: TextStyle(color: Colors.black),
      ),
    );
  }

}
