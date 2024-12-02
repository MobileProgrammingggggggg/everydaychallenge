import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_flutter/themes/colors.dart';
import 'CustomBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'ChallengeButton.dart';

class CalendarScreen extends StatefulWidget {
  static final GlobalKey<_CalendarScreenState> globalKey =
  GlobalKey<_CalendarScreenState>();

  CalendarScreen({Key? key}) : super(key: globalKey);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // 캘린더의 현재 날짜
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  // Firestore 데이터를 저장할 변수
  Set<DateTime> _completedDays = {}; // 성공한 날짜 목록
  Map<DateTime, String> _completedChallenges = {}; // 날짜와 챌린지 이름 매핑

  String uid = FirebaseAuth.instance.currentUser!.uid;

  // 성공한 날짜 및 챌린지 이름을 업데이트하는 메서드
  void _updateCompletedChallenge(DateTime day, String challengeName) {
    // 이미 해당 날짜에 챌린지가 성공한 경우, 중복 추가를 방지
    if (_completedDays.any((completedDay) =>
    completedDay.year == day.year &&
        completedDay.month == day.month &&
        completedDay.day == day.day)) {
      // 이미 존재하는 날짜라면 추가하지 않음
      return;
    }

    setState(() {
      _completedDays.add(day);
      _completedChallenges[day] = challengeName;
    });

    String formattedDate = '${day.year}-${day.month}-${day.day}';

    // Firestore에 업데이트
    FirebaseFirestore.instance.collection('users').doc(uid).set({
      'completedDays': FieldValue.arrayUnion([formattedDate]),  // 완료된 날짜 배열
      'completedChallenges': {
        formattedDate: challengeName,  // 날짜별로 챌린지 이름 저장
      }
    }, SetOptions(merge: true)).then((_) {
      print("Challenge updated successfully");
    }).catchError((e) {
      print("Error updating challenge: $e");
    });

  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();

    _fetchCompletedChallenges(); // Firestore 데이터 초기화
    _listenToChallengeUpdates(); // 실시간 구독

  }

  void _fetchCompletedChallenges() async {
    try {
      // Firestore에서 데이터 읽기
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        // Firestore에서 완료된 날짜 목록과 챌린지 정보를 읽어옴
        List<dynamic> completedDaysList = data['completedDays'] ?? [];
        Map<String, dynamic> completedChallengesMap = data['completedChallenges'] ?? {};

        // 디버깅 출력 추가
        print('completedDaysList: $completedDaysList');
        print('completedChallengesMap: $completedChallengesMap');

        setState(() {
          // Firestore에서 받은 완료된 날짜들을 _completedDays와 _completedChallenges에 추가
          for (String dateStr in completedDaysList) {
            try {
              // 날짜 형식을 2자리로 맞추기 위해 'dateStr' 수정
              List<String> dateParts = dateStr.split('-');
              if (dateParts.length == 3) {
                // 월과 일이 1자리일 경우 2자리로 맞추기
                if (dateParts[1].length == 1) dateParts[1] = '0' + dateParts[1];
                if (dateParts[2].length == 1) dateParts[2] = '0' + dateParts[2];

                String correctedDateStr = '${dateParts[0]}-${dateParts[1]}-${dateParts[2]}';

                // DateTime으로 변환
                DateTime completedDay = DateTime.parse(correctedDateStr);
                _completedDays.add(completedDay);
                _completedChallenges[completedDay] = completedChallengesMap[dateStr] ?? '';
              }
            } catch (e) {
              print('Error parsing date: $dateStr');
            }
          }
        });
      } else {
        print('No data found for the user.');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }


  void _listenToChallengeUpdates() {
    // Firestore의 `users` 컬렉션에서 데이터 읽기
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;
        if (data['challengeFlag'] == 3) {
          // 성공한 날짜를 추가
          DateTime today = DateTime.now();
          String challengeName = data['selectedChallenge'] ?? 'Unknown Challenge';
          _updateCompletedChallenge(today, challengeName);
          setState(() {
            //_completedDays.add(today);
            //_completedChallenges[today] = challengeName;
          });
        }
      }
    });
  }

  // 동그라미 표시를 위한 함수
  bool _isSuccess(DateTime day) {
    // 성공한 날인지 확인 (시간까지 정확하게 비교하지 않도록 DateTime의 연, 월, 일을 비교)
    return _completedDays.any((completedDay) =>
        completedDay.year == day.year &&
        completedDay.month == day.month &&
        completedDay.day == day.day);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[100],
        title: Text(
          '캘린더',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, focusedDay) {
                if (_isSuccess(day)) {
                  return Positioned(
                    top: 6,
                    left: 0,
                    right: 0,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.brightPink.withOpacity(0.5),
                      ),
                      width: 40,
                      height: 40,
                    ),
                  );
                }
                return SizedBox.shrink();
              },
              // 오늘 날짜의 텍스트 색상 변경
              todayBuilder: (context, day, focusedDay) {
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent, // 배경 투명
                  ),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: Colors.black, // 오늘 날짜 텍스트 색상
                    ),
                  ),
                );
              },
              // 선택된 날짜의 텍스트 색상 변경
              selectedBuilder: (context, day, focusedDay) {
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent, // 배경 투명
                  ),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: Colors.black, // 선택된 날짜 텍스트 색상
                    ),
                  ),
                );
              },
            ),
            calendarStyle: CalendarStyle(
              defaultDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              weekendDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.transparent), // 테두리를 투명하게 설정
              ),
              selectedDecoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.transparent), // 선택된 날짜도 투명하게 설정
              ),
              outsideDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
            ),
          ),
          Expanded(
            child: _completedDays.isEmpty
                ? Center(
              child: Text(
                '목록이 비어 있습니다',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _completedDays.length,
              itemBuilder: (context, index) {
                DateTime completedDay = _completedDays.elementAt(index);
                String formattedDate =
                    '${completedDay.year}-${completedDay.month}-${completedDay.day}';
                String challengeName = _completedChallenges[completedDay] ?? '';
                return ListTile(
                  title: Text(formattedDate),
                  subtitle: Text(challengeName),
                  leading: Icon(Icons.check_circle, color: AppColors.aquaBlue),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 1),
    );
  }
}