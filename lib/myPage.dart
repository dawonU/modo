import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Page',
      theme: ThemeData.light(),
      home: Mypage(),
    );
  }
}

class Mypage extends StatefulWidget {
  @override
  _MypageState createState() => _MypageState();
}

class _MypageState extends State<Mypage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isDarkMode = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    User? user = _auth.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _showEmailDialog() {
    String newEmail = _emailController.text;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return AlertDialog(
          title: Text('이메일 수정'),
          content: TextField(
            onChanged: (text) {
              newEmail = text;
            },
            decoration: InputDecoration(
              hintText: '이메일',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  User? user = _auth.currentUser;
                  if (user != null) {
                    await user.updateEmail(newEmail);
                    setState(() {
                      _emailController.text = newEmail;
                    });
                  }
                  Navigator.of(context).pop();
                } catch (e) {
                  print('이메일 업데이트 실패: $e');
                }
              },
              child: Text('저장'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // 화면 배경 색상
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: 60),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey, // 테두리 색상
                      width: 2, // 테두리 두께
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white, // 배경을 흰색으로 설정
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : AssetImage('assets/default_profile.png') as ImageProvider,
                    child: _image == null
                        ? Icon(Icons.person, size: 50, color: Colors.black) // 아이콘 색상을 검정색으로 설정
                        : null,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _pickImage,
              child: Text(
                '프로필 이미지',
                style: TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8),
            _buildProfileRow('이름', _nameController.text),
            SizedBox(height: 8),
            _buildProfileRow('이메일', _emailController.text),
            SwitchListTile(
              title: Text("다크 모드"),
              value: _isDarkMode,
              onChanged: (value) {
                _toggleDarkMode();
              },
              activeColor: Colors.grey[800], // 활성화된 색상 (토글 색상)
              inactiveTrackColor: Colors.grey[200], // 비활성화된 배경색
              inactiveThumbColor: Colors.white, // 비활성화된 토글 색상
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white, // 둥근 사각형 배경 색상
        borderRadius: BorderRadius.circular(12), // 둥근 모서리
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // 그림자 위치
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 15),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontSize: title == '이메일' ? 16 : 20, // 이메일 글씨 크기 작게 조정
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: () {
              if (title == '이메일') {
                _showEmailDialog();
              } else {
                // 이름 수정 다이얼로그 호출
                showDialog(
                  context: context,
                  builder: (context) {
                    String newValue = value;
                    return AlertDialog(
                      title: Text('수정 $title'),
                      content: TextField(
                        onChanged: (text) {
                          newValue = text;
                        },
                        decoration: InputDecoration(
                          hintText: title,
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (title == '이름') {
                                _nameController.text = newValue;
                              }
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text('저장'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('취소'),
                        ),
                      ],
                    );
                  },
                  barrierColor: Colors.black.withOpacity(0.5),
                );
              }
            },
          ),
        ],
      ),
    );
  }

}

