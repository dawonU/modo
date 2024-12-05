import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, dynamic> categories = {};
  Map<DateTime, List<Color>> dateColors = {};
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();

  Map<String, bool> expandedState = {};

  void _addCategory(Color color) {
    if (_categoryController.text.isNotEmpty) {
      setState(() {
        categories[_categoryController.text] = {
          'color': color,
          'tasks': <DateTime, List<Map<String, dynamic>>>{},
        };
        expandedState[_categoryController.text] = true;
        _categoryController.clear();
      });
    }
  }

  void _addTaskToCategory(String category, DateTime date, String task) {
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
    }
  }

  void _showCategoryDialog() {
    Color selectedColor = const Color(0xFFFFFFFF);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                _addCategory(selectedColor);
                Navigator.pop(context);
              },
              child: const Text('추가'),
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
                  _addTaskToCategory(category, _selectedDay!, _taskController.text);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo by Category'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
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
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 16, width: 20,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: _showCategoryDialog,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('카테고리 추가', style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF919191),
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size.fromHeight(30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final categoryName = categories.keys.elementAt(index);
                final categoryColor = categories[categoryName]['color'];
                final tasks = categories[categoryName]['tasks'][_selectedDay] ?? [];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 30,
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(20),

                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: categoryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              categoryName,
                              style: const TextStyle(
                                fontSize:  17,
                                fontWeight: FontWeight.w400,
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
                              icon: const Icon(Icons.add_circle_outline, size: 18),
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
                                size: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
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
