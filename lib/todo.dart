import 'package:flutter/material.dart';

class TodoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TODO Page")),
      body: Center(child: Text("Welcome to TODO Page!")),
    );
  }
}