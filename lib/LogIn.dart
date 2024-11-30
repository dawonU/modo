import 'package:flutter/material.dart';
import 'SignUp.dart'; // SignUpScreen을 가져옵니다.

void main() => runApp(LogIn());

class LogIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // FocusNode를 사용하여 TextField의 포커스를 관리
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  double welcomeTextMargin = 200; // Welcome 텍스트와 입력 필드 간의 간격

  @override
  void initState() {
    super.initState();

    // FocusNode에 리스너 추가
    emailFocusNode.addListener(() {
      setState(() {
        welcomeTextMargin = emailFocusNode.hasFocus ? 100 : 200; // 포커스 시 간격 조정
      });
    });

    passwordFocusNode.addListener(() {
      setState(() {
        welcomeTextMargin = passwordFocusNode.hasFocus ? 100 : 200; // 포커스 시 간격 조정
      });
    });
  }

  void _login() {
    // 로그인 로직 구현
    String email = emailController.text;
    String password = passwordController.text;

    if (email == 'test@example.com' && password == 'password123') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 성공!')),
      );
      // 로그인 성공 후 다음 화면으로 이동
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NextPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이메일 또는 비밀번호가 잘못되었습니다.')),
      );
    }
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen()), // SignUpScreen으로 이동
    );
  }

  @override
  void dispose() {
    // FocusNode 메모리 해제
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[50], // AppBar 배경색을 흰색으로 설정
      ),
      backgroundColor: Colors.pink[50],
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            //borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 10, spreadRadius: 5),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, //중앙배치
              children: [
                SizedBox(height: 60),
                Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Arial Rounded MT',
                  ),
                ),

                SizedBox(height: welcomeTextMargin),

                TextField(
                  controller: emailController,
                  focusNode: emailFocusNode, // FocusNode 추가
                  decoration: InputDecoration(
                    labelText: '이메일',
                    labelStyle: TextStyle(
                      color: Colors.black87, // 기본 라벨 색상
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.white10), // 기본 테두리
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.black87), // 비활성 상태
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.black87), // 포커스된 상태
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: 20),

                TextField(
                  controller: passwordController,
                  focusNode: passwordFocusNode, // FocusNode 추가
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    labelStyle: TextStyle(
                      color: Colors.black87, // 기본 라벨 색상을 진한 회색으로 설정 (null 체크)
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.white10), // 기본 테두리
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.black87), // 비활성 상태
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.black87), // 포커스된 상태
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child: Text('로그인'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: _navigateToSignUp,
                    child: Text(
                      '가입하기',
                      style: TextStyle(
                        color: Colors.pink, // 핑크색 텍스트
                      ),
                    ),
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
