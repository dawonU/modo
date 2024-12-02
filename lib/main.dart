import 'package:flutter/material.dart';
import 'package:modo/LogIn.dart';
import 'package:modo/memo.dart';
import 'package:modo/todo.dart';
import 'navigation_bar.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoPage(), // 초기 화면을 LogIn으로 설정
      debugShowCheckedModeBanner: false,
    );
  }
}



