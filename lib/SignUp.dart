import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // 테두리 색상 변수
  final Color _borderColor = Colors.grey[300]!; // 기본 테두리 색상
  final Color _focusedBorderColor = Colors.grey[400]!; // 포커스된 상태의 테두리 색상

  String? _errorMessage; // 비밀번호 오류 메시지를 위한 변수

  void _clearName() {
    setState(() {
      _nameController.clear();
    });
  }

  void _signUp() {
    // 회원가입 로직 구현
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = '비밀번호가 일치하지 않습니다.'; // 오류 메시지 설정
      });
      return;
    } else {
      setState(() {
        _errorMessage = null; // 오류 메시지 초기화
      });
    }

    // 여기서 회원가입 로직을 처리합니다.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('환영합니다 :)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[50], // AppBar 배경색을 흰색으로 설정
      ),
      backgroundColor: Colors.pink[50],
      body: Center(
        child: Center(
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

                // 이메일 입력 필드
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: '이메일',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: _borderColor), // 기본 테두리 색상
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _focusedBorderColor), // 포커스된 상태의 테두리 색상
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),

                // 비밀번호 입력 필드
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: '비밀번호',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: _borderColor), // 기본 테두리 색상
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _focusedBorderColor), // 포커스된 상태의 테두리 색상
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),

                // 비밀번호 확인 입력 필드
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    hintText: '비밀번호 확인',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: _borderColor), // 기본 테두리 색상
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _focusedBorderColor), // 포커스된 상태의 테두리 색상
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20), // 입력 필드와 오류 메시지 사이의 공간

                // 비밀번호 오류 메시지
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
                      SizedBox(height: 20), // 오류 메시지와 버튼 사이의 공간
                    ],
                  ),

                // 가입하기 버튼
                ElevatedButton(
                  onPressed: _signUp,
                  child: Text('가입하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink, // 버튼 배경색
                    foregroundColor: Colors.white, // 버튼 글씨색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 둥근 모서리
                    ),
                    minimumSize: Size(double.infinity, 40), // 버튼 크기
                  ),
                ),
              ],
            ),
    ),
          ),
        ),
      ),
    );
  }
}
