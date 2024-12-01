import 'dart:math';

import 'package:flutter/material.dart';
import 'CustomBottomNavigationBar.dart';
import 'Ask_again_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Main_test.dart';

void main() {
  runApp(MaterialApp(
    home: StoreScreen(),
  ));
}

class StoreScreen extends StatefulWidget {
  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  int points = 0;
  Map<String, int> purchasedItems = {};

  @override
  void initState() {
    super.initState();
    listenToUserPoints(); // 포인트의 실시간 변경 사항을 반영하기 위해 리스너 설정
  }

// Firestore 실시간 리스너를 사용하여 포인트 데이터 가져오기
  void listenToUserPoints() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          points = snapshot.data()?['points'] ?? 0; // Firestore에서 변경된 포인트 반영
        });
      }
    });
  }

  void _buyItem(String itemName, int itemCost) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'points': FieldValue.increment(-itemCost),
      '$itemName': FieldValue.increment(1),
    });

    setState(() {
      purchasedItems.update(itemName, (value) => value + 1, ifAbsent: () => 1);
    });
  }

  void _showPurchaseDialog(
      BuildContext context, String itemName, int itemCost) {
    showDialog(
      context: context,
      builder: (context) => Ask_again(
        message: "$itemName를 구매하시겠습니까?",
      ),
    ).then((value) {
      //print("다이얼로그 반환 값: $value"); // 반환 값 확인용 로그
      if (value == 1) {
        if (points >= itemCost) {
          _buyItem(itemName, itemCost);
          _showSuccessDialog(context, itemName);
        } else {
          showDialog(
            context: context,
            builder: (context) => Ask_again(
              message: "포인트가 부족합니다.",
            ),
          );
        }
      }
    });
  }

  void _showSuccessDialog(BuildContext context, String itemName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Image.asset(
                'assets/images/good.png',
                height: 100,
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                "$itemName 구매가 완료되었습니다.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color.fromRGBO(92, 103, 227, 1),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, int>> _fetchPurchasedItems() async {
    var result =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    // 초기 아이템 목록
    Map<String, int> items = {
      "룰렛판 바꾸기": 0,
      "챌린지 스킵권": 0,
      "포인트 2배권": 0,
      "포인트 랜덤박스": 0,
    };

    if (result.exists) {
      // Firestore에서 가져온 데이터를 사용하여 아이템 수를 업데이트
      items["룰렛판 바꾸기"] = result.data()?['룰렛 바꾸기'] ?? 0;
      items["챌린지 스킵권"] = result.data()?['챌린지 스킵권'] ?? 0;
      items["포인트 2배권"] = result.data()?['포인트 2배권'] ?? 0;
      items["포인트 랜덤박스"] = result.data()?['포인트 랜덤박스'] ?? 0;
    }

    return items;
  }

  void _showInventoryDialog(BuildContext context) async {
    Map<String, int> items = await _fetchPurchasedItems();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "아이템 보유 현황",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Container(
          width: 300,
          height: 200,
          child: GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 1,
            children: items.entries.map((entry) {
              IconData icon;
              switch (entry.key) {
                case "룰렛판 바꾸기":
                  icon = Icons.refresh;
                  break;
                case "챌린지 스킵권":
                  icon = Icons.flash_on;
                  break;
                case "포인트 2배권":
                  icon = Icons.double_arrow;
                  break;
                case "포인트 랜덤박스":
                  icon = Icons.auto_fix_high;
                  break;
                default:
                  icon = Icons.help_outline;
              }
              return MouseRegion(
                cursor: SystemMouseCursors.click, // 마우스 커서 변경
                child: GestureDetector(
                onTap: () {
                  if(entry.key == '챌린지 스킵권'){
                    _handleSkip(context);
                  }
                  if(entry.key == '포인트 2배권'){
                    _handleDouble(context);
                  }
                  if(entry.key == '포인트 랜덤박스'){
                    _handleRandom(context);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 30, color: Colors.amber),
                    SizedBox(height: 4),
                    Text(entry.key, style: TextStyle(fontSize: 14)),
                    Text('${entry.value}개', style: TextStyle(fontSize: 12)),
                  ],
                ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color.fromRGBO(92, 103, 227, 1),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '확인',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  void _handleSkip(BuildContext context) {
    // 다이얼로그 띄우기
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("챌린지 스킵권"),
          content: Text("오늘의 챌린지를 스킵할까요?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                _skipLogic();
                Navigator.pop(context);
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }

  void _skipLogic() async {
    try {
      // Firestore의 'users' 컬렉션에서 해당 uid를 가진 문서를 읽어옵니다.
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get(); // .get()을 사용하여 문서를 한 번만 읽어옵니다.

      if (snapshot.exists) {
        // 데이터가 존재하면 'challengeFlag' 값을 확인합니다.
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // challengeFlag 값 가져오기
        int skipTicket = data['챌린지 스킵권'];
        int challengeFlag = data['challengeFlag'];
        String selectedChallenge = data['selectedChallenge'];


        if (challengeFlag == 1 || challengeFlag == 2) {
          if(skipTicket>0){
            skipTicket --;
            challengeFlag = 3;
            selectedChallenge = "오늘의 챌린지는 스킵되었습니다.";
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChallengeScreen()),
            );

            // Firestore 문서 업데이트
            await FirebaseFirestore.instance.collection('users').doc(uid).update({
              '챌린지 스킵권' : skipTicket,
              'challengeFlag': challengeFlag, // challengeFlag 값을 3으로 설정
              'selectedChallenge': selectedChallenge, // selectedChallenge 값을 변경
            });

            // 변경된 데이터를 로컬에서 사용하기 위해 setState() 호출
            setState(() {
              // 상태 업데이트 코드 (예: UI에 반영)
            });
          }
          else {
            _errorAlert("아이템을 보유하고 있지 않습니다.");
          }
        }
      }
    } catch (e) {
      print("Error getting user data: $e");
    }
  }

  void _handleDouble(BuildContext context) {
    // 다이얼로그 띄우기
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("포인트 2배권"),
          content: Text("오늘의 챌린지포인트를 2배 획득합니다."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                _doubleLogic();
                Navigator.pop(context);
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }

  void _doubleLogic() async {
    try {
      // Firestore의 'users' 컬렉션에서 해당 uid를 가진 문서를 읽어옵니다.
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get(); // .get()을 사용하여 문서를 한 번만 읽어옵니다.

      if (snapshot.exists) {
        // 데이터가 존재하면 'challengeFlag' 값을 확인합니다.
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // challengeFlag 값 가져오기
        int doubleTicket = data['포인트 2배권'];
        int challengeFlag = data['challengeFlag'];
        int points = data['points'];


        if (challengeFlag == 3) {
          if(doubleTicket>0){
            doubleTicket --;
            points +=10;
            _noticeAlert("오늘의 챌린지 포인트가 2배로 적립되었습니다.");

            // Firestore 문서 업데이트
            await FirebaseFirestore.instance.collection('users').doc(uid).update({
              '포인트 2배권' : doubleTicket,
              'points' : points,
            });

            // 변경된 데이터를 로컬에서 사용하기 위해 setState() 호출
            setState(() {
              // 상태 업데이트 코드 (예: UI에 반영)
            });
          }
          else {
            _errorAlert("아이템을 보유하고 있지 않습니다.");
          }
        }
        else {
          _errorAlert("오늘의 챌린지를 먼저 완료해주세요.");
        }
      }
    } catch (e) {
      print("Error getting user data: $e");
    }
  }

  void _handleRandom(BuildContext context) {
    // 다이얼로그 띄우기
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("포인트 랜덤박스"),
          content: Text("10p ~ 100p 사이의 랜덤 포인트를 획득합니다."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                _RandomLogic();
                Navigator.pop(context);
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }

  void _RandomLogic() async {
    try {
      // Firestore의 'users' 컬렉션에서 해당 uid를 가진 문서를 읽어옵니다.
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get(); // .get()을 사용하여 문서를 한 번만 읽어옵니다.

      if (snapshot.exists) {
        // 데이터가 존재하면 'challengeFlag' 값을 확인합니다.
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // challengeFlag 값 가져오기
        int RandomTicket = data['포인트 랜덤박스'];
        int points = data['points'];


        if (points > 0) {
          if(RandomTicket>0){
            RandomTicket --;
            Random random = Random();
            int result = random.nextInt(91);
            points +=result;

            _noticeAlert("축하합니다! " + result.toString() + "p를 획득하였습니다!");

            // Firestore 문서 업데이트
            await FirebaseFirestore.instance.collection('users').doc(uid).update({
              '포인트 랜덤박스' : RandomTicket,
              'points' : points,
            });

            // 변경된 데이터를 로컬에서 사용하기 위해 setState() 호출
            setState(() {
              // 상태 업데이트 코드 (예: UI에 반영)
            });
          }
          else {
            _errorAlert("아이템을 보유하고 있지 않습니다.");
          }
        }
      }
    } catch (e) {
      print("Error getting user data: $e");
    }
  }

  void _errorAlert(String msg){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("오류"),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }

  void _noticeAlert(String msg){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,  // 내용 크기를 최소화
            children: [
              Image.asset('assets/images/good.png', height: 100),
              SizedBox(height: 10),  // 간격을 추가
              Text(msg),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // 다이얼로그를 닫음
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[100],
        elevation: 0,
        title: Text(
          "상점",
          style: TextStyle(
            color: Colors.purple,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.inventory),
            onPressed: () => _showInventoryDialog(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.pink[200],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wallet_giftcard, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        "$points P",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16.0),
                  children: [
                    ShopItem(
                      icon: Icons.refresh,
                      title: "룰렛판 바꾸기",
                      points: 30,
                      description: "룰렛판을 변경할 수 있습니다.",
                      onTap: () => _showPurchaseDialog(context, "룰렛판 바꾸기", 30),
                    ),
                    ShopItem(
                      icon: Icons.flash_on,
                      title: "챌린지 스킵권",
                      points: 100,
                      description: "오늘의 챌린지를 스킵할 수 있습니다.",
                      onTap: () => _showPurchaseDialog(context, "챌린지 스킵권", 100),
                    ),
                    ShopItem(
                      icon: Icons.double_arrow,
                      title: "포인트 2배권",
                      points: 50,
                      description: "오늘의 챌린지포인트를 2배 획득합니다.",
                      onTap: () => _showPurchaseDialog(context, "포인트 2배권", 50),
                    ),
                    ShopItem(
                      icon: Icons.auto_fix_high,
                      title: "포인트 랜덤박스",
                      points: 50,
                      description: "10p ~ 100p 사이의 포인트를 획득합니다.",
                      onTap: () => _showPurchaseDialog(context, "포인트 랜덤박스", 50),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 2),
    );
  }
}

class ShopItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int points;
  final String description;
  final VoidCallback onTap;

  ShopItem({
    required this.icon,
    required this.title,
    required this.points,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 30, color: Colors.amber),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 5),
                    Text(description,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              Text("$points P",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
