import 'package:test_flutter/themes/colors.dart';
import 'CustomBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // 캘린더의 현재 날짜
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  // 성공한 날짜 목록
  Set<DateTime> _completedDays = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  // 성공한 날을 추가하는 함수
  void _markSuccess(DateTime day) {
    setState(() {
      // 이미 성공한 날이 아니면 추가
      if (!_completedDays.contains(day)) {
        _completedDays.add(day);
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
        title: Text('캘린더',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),),

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
              // 날짜를 중복해서 표시하지 않음
              markerBuilder: (context, day, focusedDay) {
                bool isSuccess = _isSuccess(day);
                return isSuccess
                    ? Positioned(
                  top: 6, // 동그라미를 조금 위로 올리기 위해 `top` 값을 조정
                  left: 0,
                  right: 0,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.brightPink.withOpacity(0.5),
                    ),
                    width: 40, // 동그라미 크기
                    height: 40, // 동그라미 크기
                  ),
                )
                    : SizedBox.shrink(); // 성공한 날짜가 아니면 마커를 표시하지 않음
              },
            ),
            calendarStyle: CalendarStyle(
              // 기본 날짜 셀 스타일 설정
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
                color: Colors.blue.shade100.withOpacity(0.7),
              ),
              selectedDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brightPink.withOpacity(0.5), // 선택된 날짜 색상
              ),
              outsideDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _markSuccess(_selectedDay), // 선택한 날짜를 성공한 날로 마크
            child: Text('성공!'),
          ),
          Expanded(
            child:_completedDays.isEmpty
                ? Center(
              child: Text(
                '목록이 비어 있습니다',  // 비어있을 때 표시할 메시지
                style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
            )
            : ListView.builder(
              itemCount: _completedDays.length,
              itemBuilder: (context, index) {
                DateTime completedDay = _completedDays.elementAt(index);
                String formattedDate = '${completedDay.year}-${completedDay.month}-${completedDay.day}';
                return ListTile(
                  title: Text('$formattedDate'),
                  subtitle: Text('챌린지 내용'),
                  leading: Icon(Icons.check_circle, color: AppColors.aquaBlue),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex:1),
    );

  }
}


