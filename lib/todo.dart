import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final List<Map<String, dynamic>> _todos = [];
  final TextEditingController _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tz_data.initializeTimeZones();
    _setupNotifications();
  }

  // 알림 초기화
  void _setupNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings);
  }

  // 알람 예약
  void _scheduleNotification(int index, tz.TZDateTime scheduledTime) async {
    final todo = _todos[index];

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'routine_channel_id',
      'Routine Notifications',
      channelDescription: 'Routine notifications channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      0,
      '할 일 알림',
      '${todo['task']}의 시간이 되었습니다!',
      scheduledTime,
      platformDetails,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.wallClockTime,
      androidAllowWhileIdle: true,
    );
  }

  // 할 일 추가
  void _addTask() {
    if (_todoController.text.isNotEmpty) {
      setState(() {
        _todos.add({
          'task': _todoController.text,
          'completed': false,
          'pinned': false,
          'alarmTime': null, // 알람 시간을 추가
        });
        _todoController.clear();
      });
    }
  }

  // 핀 고정 상태 변경
  void _togglePin(int index) {
    setState(() {
      _todos[index]['pinned'] = !_todos[index]['pinned'];
    });
  }

  // 할 일 삭제
  void _removeTask(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  // 할 일 수정
  void _updateTask(int index, String newContent) {
    setState(() {
      _todos[index]['task'] = newContent;
    });
  }

  // 알람 시간 선택
  Future<void> _pickAlarmTime(int index) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      final DateTime currentTime = DateTime.now();
      final DateTime scheduledTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      final tz.TZDateTime tzScheduledTime =
      tz.TZDateTime.from(scheduledTime, tz.local);

      setState(() {
        _todos[index]['alarmTime'] = tzScheduledTime;
      });

      _scheduleNotification(index, tzScheduledTime);
    }
  }

  // 고정된 할 일과 고정되지 않은 할 일을 분리
  List<Map<String, dynamic>> _getPinnedTasks() {
    return _todos.where((todo) => todo['pinned'] == true).toList();
  }

  List<Map<String, dynamic>> _getUnpinnedTasks() {
    return _todos.where((todo) => todo['pinned'] == false).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pinnedTasks = _getPinnedTasks();
    final unpinnedTasks = _getUnpinnedTasks();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // 고정된 할 일 섹션
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    '📌 고정 TodoList',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (pinnedTasks.isNotEmpty)
                  ...pinnedTasks.map((task) {
                    final index = _todos.indexOf(task);
                    return _buildTaskCard(task, index);
                  }).toList()
                else
                  const Center(
                    child: Text(
                      '고정된 Todo List가 없습니다.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),

                // 일반 할 일 섹션
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    '📋 Todo List',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (unpinnedTasks.isNotEmpty)
                  ...unpinnedTasks.map((task) {
                    final index = _todos.indexOf(task);
                    return _buildTaskCard(task, index);
                  }).toList()
                else
                  const Center(
                    child: Text(
                      'Todo List가 없습니다.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                      labelText: '오늘의 Todo List를 입력하세요!',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('+'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(50, 50),
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, int index) {
    return Card(
      color: task['pinned'] ? Colors.yellow[100] : Colors.white,
      child: ListTile(
        title: Text(
          task['task'],
          style: TextStyle(
            decoration:
            task['completed'] ? TextDecoration.lineThrough : null,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            task['completed']
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            color: task['completed'] ? Colors.green : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              task['completed'] = !task['completed'];
            });
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                task['pinned']
                    ? Icons.push_pin
                    : Icons.push_pin_outlined,
                color: task['pinned'] ? Colors.orange : Colors.grey,
              ),
              onPressed: () {
                _togglePin(index);
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _showEditDialog(index, task['task']);
              },
            ),
            IconButton(
              icon: const Icon(Icons.alarm),
              onPressed: () {
                _pickAlarmTime(index);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _removeTask(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 수정 다이얼로그 표시
  void _showEditDialog(int index, String currentContent) {
    final TextEditingController editController =
    TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Todo List 수정'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(labelText: '수정할 Todo List 입력'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateTask(index, editController.text);
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }
}
