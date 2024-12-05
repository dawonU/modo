import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final Color _borderColor = Colors.grey[300]!;
  final Color _focusedBorderColor = Colors.grey[400]!;

  String? _errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _clearName() {
    setState(() {
      _nameController.clear();
    });
  }

  void _signUp() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = '비밀번호가 일치하지 않습니다.';
      });
      return;
    } else {
      setState(() {
        _errorMessage = null;
      });
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('환영합니다 :)')),
      );
      // 회원가입 성공 후 입력 필드 초기화
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      // 회원가입 성공 후 로그인 화면으로 돌아가기
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = '비밀번호가 너무 약합니다.';
      } else if (e.code == 'email-already-in-use') {
        message = '해당 이메일로 이미 가입되어 있습니다.';
      } else {
        message = '회원가입에 실패했습니다. 다시 시도해주세요.';
      }
      setState(() {
        _errorMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[50],
      ),
      backgroundColor: Colors.pink[50],
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 60),
                Text(
                  'Hi !',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Arial Rounded MT',
                  ),
                ),
                SizedBox(height: 50),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: '이름',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: _borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _focusedBorderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: '이메일',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: _borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _focusedBorderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: '비밀번호',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: _borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _focusedBorderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    hintText: '비밀번호 확인',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: _borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _focusedBorderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                if (_errorMessage != null)
                  Column(
                    children: [
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.pink,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ElevatedButton(
                  onPressed: _signUp,
                  child: Text('가입하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}