import 'package:flutter/material.dart';
import 'CustomBottomNavigationBar.dart';
import 'Ask_again_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      points -= itemCost;
      purchasedItems.update(itemName, (value) => value + 1, ifAbsent: () => 1);
    });
  }


  void _showPurchaseDialog(BuildContext context, String itemName, int itemCost) {
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
    var result = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    // 초기 아이템 목록
    Map<String, int> items = {
      "기록 삭제권": 0,
      "난이도 선택권": 0,
      "룰렛 재추첨권": 0,
      "챌린지 스킵권": 0,
      "포인트 2배권": 0,
      "하루 연장권": 0,
    };

    if (result.exists) {
      // Firestore에서 가져온 데이터를 사용하여 아이템 수를 업데이트
      items["기록 삭제권"] = result.data()?['기록 삭제권'] ?? 0;
      items["난이도 선택권"] = result.data()?['난이도 선택권'] ?? 0;
      items["룰렛 재추첨권"] = result.data()?['룰렛 재추첨권'] ?? 0;
      items["챌린지 스킵권"] = result.data()?['챌린지 스킵권'] ?? 0;
      items["포인트 2배권"] = result.data()?['포인트 2배권'] ?? 0;
      items["하루 연장권"] = result.data()?['하루 연장권'] ?? 0;
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
                case "룰렛 재추첨권":
                  icon = Icons.refresh;
                  break;
                case "챌린지 스킵권":
                  icon = Icons.flash_on;
                  break;
                case "하루 연장권":
                  icon = Icons.access_time;
                  break;
                case "포인트 2배권":
                  icon = Icons.double_arrow;
                  break;
                case "기록 삭제권":
                  icon = Icons.delete_forever;
                  break;
                case "난이도 선택권":
                  icon = Icons.auto_fix_high;
                  break;
                default:
                  icon = Icons.help_outline;
              }
              return GestureDetector(
                onTap: () {
                  print("${entry.key} 클릭됨");
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
                padding: EdgeInsets.symmetric( horizontal: 32, vertical: 16),
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
                      title: "룰렛 재추첨권",
                      points: 30,
                      description: "한 번 더 룰렛을 돌릴 수 있습니다.",
                      onTap: () => _showPurchaseDialog(context, "룰렛 재추첨권", 30),
                    ),
                    ShopItem(
                      icon: Icons.flash_on,
                      title: "챌린지 스킵권",
                      points: 100,
                      description: "하루 한 번 챌린지를 스킵할 수 있습니다.",
                      onTap: () => _showPurchaseDialog(context, "챌린지 스킵권", 100),
                    ),
                    ShopItem(
                      icon: Icons.access_time,
                      title: "하루 연장권",
                      points: 50,
                      description: "챌린지 기간을 하루 연장할 수 있습니다.",
                      onTap: () => _showPurchaseDialog(context, "하루 연장권", 50),
                    ),
                    ShopItem(
                      icon: Icons.double_arrow,
                      title: "포인트 2배권",
                      points: 50,
                      description: "포인트 적립을 2배로 해줍니다.",
                      onTap: () => _showPurchaseDialog(context, "포인트 2배권", 50),
                    ),
                    ShopItem(
                      icon: Icons.delete_forever,
                      title: "기록 삭제권",
                      points: 30,
                      description: "하루의 기록을 삭제할 수 있습니다.",
                      onTap: () => _showPurchaseDialog(context, "기록 삭제권", 30),
                    ),
                    ShopItem(
                      icon: Icons.auto_fix_high,
                      title: "난이도 선택권",
                      points: 20,
                      description: "챌린지의 난이도를 선택할 수 있습니다.",
                      onTap: () => _showPurchaseDialog(context, "난이도 선택권", 20),
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
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 5),
                    Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              Text("$points P", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}