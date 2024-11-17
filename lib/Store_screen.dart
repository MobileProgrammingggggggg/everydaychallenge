import 'package:flutter/material.dart';
import 'CustomBottomNavigationBar.dart';

class StoreScreen extends StatefulWidget {
  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int points = 130; // 초기 포인트 설정

  // 구매한 아이템들을 저장할 맵
  Map<String, int> purchasedItems = {};

  // 아이템 구매 함수
  void _buyItem(String itemName, int itemCost, IconData itemIcon) {
    setState(() {
      points -= itemCost; // 포인트 차감
      if (purchasedItems.containsKey(itemName)) {
        purchasedItems[itemName] = purchasedItems[itemName]! + 1; // 아이템 갯수 증가
      } else {
        purchasedItems[itemName] = 1;
      }
    });
  }

  // 구매한 아이템들을 아이콘과 갯수로 표시하는 함수
  Widget _buildPurchasedItems() {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: purchasedItems.entries.map((entry) {
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
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: Colors.amber),
              SizedBox(width: 4),
              Text(
                '${entry.value}',
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // 구매 다이얼로그 표시 함수
  void _showPurchaseDialog(BuildContext context, String itemName, int itemCost, IconData itemIcon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Container(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              itemName,
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          content: Text(
            "구매하시겠습니까?",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: TextButton(
                onPressed: () {
                  if (points >= itemCost) {
                    _buyItem(itemName, itemCost, itemIcon);
                    Navigator.of(context).pop();
                    _showSuccessDialog(context, itemName);
                  } else {
                    Navigator.of(context).pop();
                    _showErrorDialog(context); // 포인트 부족 처리
                  }
                },
                child: Text("확인", style: TextStyle(color: Colors.white)),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.lightBlue[200]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("취소", style: TextStyle(color: Colors.grey)),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.grey[300]),
                ),
              ),
            ),
          ],
          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        );
      },
    );
  }

  // 아이템 구매 성공 다이얼로그
  void _showSuccessDialog(BuildContext context, String itemName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Container(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              "아이템 구매 성공",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 40),
              SizedBox(height: 10),
              Text(
                "$itemName 구매 성공!",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("확인", style: TextStyle(color: Colors.white)),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.lightBlue[200]),
              ),
            ),
          ],
          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
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
      ),
      body: Stack(
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  _showPointDialog(context);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 16.0),
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
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
                      onTap: () {
                        _showPurchaseDialog(context, "룰렛 재추첨권", 30, Icons.refresh);
                      },
                    ),
                    ShopItem(
                      icon: Icons.flash_on,
                      title: "챌린지 스킵권",
                      points: 100,
                      description: "하루 한 번 챌린지를 스킵할 수 있습니다.",
                      onTap: () {
                        _showPurchaseDialog(context, "챌린지 스킵권", 100, Icons.flash_on);
                      },
                    ),
                    ShopItem(
                      icon: Icons.access_time,
                      title: "하루 연장권",
                      points: 50,
                      description: "챌린지 기간을 하루 연장할 수 있습니다.",
                      onTap: () {
                        _showPurchaseDialog(context, "하루 연장권", 50, Icons.access_time);
                      },
                    ),
                    ShopItem(
                      icon: Icons.double_arrow,
                      title: "포인트 2배권",
                      points: 50,
                      description: "포인트 적립을 2배로 해줍니다.",
                      onTap: () {
                        _showPurchaseDialog(context, "포인트 2배권", 50, Icons.double_arrow);
                      },
                    ),
                    ShopItem(
                      icon: Icons.delete_forever,
                      title: "기록 삭제권",
                      points: 30,
                      description: "하루의 기록을 삭제할 수 있습니다.",
                      onTap: () {
                        _showPurchaseDialog(context, "기록 삭제권", 30, Icons.delete_forever);
                      },
                    ),
                    ShopItem(
                      icon: Icons.auto_fix_high,
                      title: "난이도 선택권",
                      points: 20,
                      description: "챌린지의 난이도를 선택할 수 있습니다.",
                      onTap: () {
                        _showPurchaseDialog(context, "난이도 선택권", 20, Icons.auto_fix_high);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildPurchasedItems(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  void _showPointDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Container(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              "현재 포인트",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          content: Text(
            "현재 포인트는 $points P 입니다.",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("확인"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.lightBlue[200]),
              ),
            ),
          ],
          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        );
      },
    );
  }
}

// 포인트 부족 시 다이얼로그
void _showErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            "포인트 부족",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        content: Text(
          "포인트가 부족합니다.",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("확인", style: TextStyle(color: Colors.white)),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red[200]),
            ),
          ),
        ],
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      );
    },
  );
}

// 상점 상품 항목 위젯
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
              Icon(icon, color: Colors.amber, size: 30),
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

//메롱