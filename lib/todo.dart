import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<String, dynamic> categories = {};
  Map<DateTime, List<Color>> dateColors = {};
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();

  Map<String, bool> expandedState = {};
  bool isTwoWeeksView = false; // 2주 보기 상태 변수

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore.collection('users').doc(user.uid).collection('categories').get();
      setState(() {
        categories.clear();
        for (var doc in snapshot.docs) {
          categories[doc.id] = {
            'color': Color(doc['color']),
            'tasks': (doc['tasks'] as Map<String, dynamic>).map((key, value) {
              return MapEntry(DateTime.parse(key), List<Map<String, dynamic>>.from(value));
            }),
          };
          expandedState[doc.id] = true;
        }
      });
    }
  }

  Future<void> _saveCategory(String category, Color color) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('categories').doc(category).set({
        'color': color.value,
        'tasks': categories[category]['tasks'].map((key, value) {
          return MapEntry(key.toIso8601String(), value);
        }),
      });
    }
  }

  Future<void> _addCategory(Color color) async {
    if (_categoryController.text.isNotEmpty) {
      setState(() {
        categories[_categoryController.text] = {
          'color': color,
          'tasks': <DateTime, List<Map<String, dynamic>>>{},
        };
        expandedState[_categoryController.text] = true;
        _categoryController.clear();
      });
      await _saveCategory(_categoryController.text, color);
    }
  }

  Future<void> _addTaskToCategory(String category, DateTime date, String task) async {
    if (task.isNotEmpty) {
      setState(() {
        if (categories[category]['tasks'][date] == null) {
          categories[category]['tasks'][date] = <Map<String, dynamic>>[];
        }
        categories[category]['tasks'][date].add({
          'task': task,
          'completed': false,
        });

        if (dateColors[date] == null) {
          dateColors[date] = [];
        }
        if (!dateColors[date]!.contains(categories[category]['color'])) {
          dateColors[date]!.add(categories[category]['color']);
        }
      });
      await _saveCategory(category, categories[category]['color']);
    }
  }

  void _showCategoryDialog() {
    Color selectedColor = const Color(0xFFFFFFFF);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('카테고리 추가'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: '카테고리 이름'),
                ),
                const SizedBox(height: 16),
                BlockPicker(
                  pickerColor: selectedColor,
                  availableColors: [
                    const Color(0xFFA6AEBF),
                    const Color(0xFFC5D3E8),
                    const Color(0xFFD0E8C5),
                    const Color(0xFFFFF8DE),
                    const Color(0xFFCB9DF0),
                    const Color(0xFFF0C1E1),
                    const Color(0xFFFDDBBB),
                    const Color(0xFFFF8A8A),
                    const Color(0xFF659287),
                    const Color(0xFFB1C29E),
                  ],
                  onColorChanged: (color) {
                    selectedColor = color;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.black, // 배경색을 검정색으로 설정
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _addCategory(selectedColor);
                Navigator.pop(context);
              },
              child: const Text(
                '추가',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddTaskDialog(String category) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('일정 추가'),
          content: TextField(
            controller: _taskController,
            decoration: const InputDecoration(labelText: '일정 이름'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedDay != null) {
                  _addTaskToCategory(category, _selectedDay, _taskController.text);
                  _taskController.clear();
                  Navigator.pop(dialogContext);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('날짜를 선택하세요!')),
                  );
                }
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  void _toggleCalendarView() {
    setState(() {
      isTwoWeeksView = !isTwoWeeksView; // 2주 보기 상태 토글
      if (!isTwoWeeksView) {
        _focusedDay = DateTime.now(); // 월 버튼 클릭 시 현재 날짜로 리셋
        _selectedDay = DateTime.now(); // 현재 날짜 선택
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 85), // 간격 조정
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            calendarFormat: isTwoWeeksView ? CalendarFormat.twoWeeks : CalendarFormat.month, // 2주 또는 월 형식 설정
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay; // 선택된 날짜 업데이트
                _focusedDay = focusedDay; // 포커스된 날짜 업데이트
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (dateColors[date] == null) return null;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: dateColors[date]!.map((color) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                );
              },
              selectedBuilder: (context, date, _) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  width: 40, // 동그라미의 너비
                  height: 50, // 동그라미의 높이
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.8), // 선택된 날짜의 배경색
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(color: Colors.black), // 선택된 날짜의 텍스트 색상
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: _showCategoryDialog,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('카테고리 등록', style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // 버튼 배경 색상
                foregroundColor: Colors.white, //
                elevation: 0,
                minimumSize: const Size(150, 40), // 가로 세로 길이
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // 둥근 모서리
                ),
              ),
            ),
          ),
          const SizedBox(height: 10), // 간격 조정
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final categoryName = categories.keys.elementAt(index);
                final categoryColor = categories[categoryName]['color'];
                final tasks = categories[categoryName]['tasks'][_selectedDay] ?? [];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: categoryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  categoryName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _showAddTaskDialog(categoryName);
                                  },
                                  icon: const Icon(Icons.add_circle_outline, size: 15),
                                  color: Colors.grey,
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      expandedState[categoryName] = !(expandedState[categoryName] ?? true);
                                    });
                                  },
                                  icon: Icon(
                                    expandedState[categoryName] ?? true
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (expandedState[categoryName] ?? true)
                          ...tasks.map<Widget>((task) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: task['completed'],
                                    onChanged: (value) {
                                      setState(() {
                                        task['completed'] = value;
                                      });
                                    },
                                  ),
                                  Text(
                                    task['task'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}