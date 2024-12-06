import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MemoPage extends StatefulWidget {
  @override
  _MemoPageState createState() => _MemoPageState();
}

class _MemoPageState extends State<MemoPage> {
  final List<Map<String, dynamic>> memos = []; // 메모 리스트
  final TextEditingController memoController = TextEditingController();
  String searchKeyword = ''; // 검색 키워드

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore.collection('users').doc(user.uid).collection('memos').get();
      setState(() {
        memos.clear();
        for (var doc in snapshot.docs) {
          memos.add({
            'id': doc.id,
            'content': doc['content'],
            'pinned': doc['pinned'],
          });
        }
      });
    }
  }

  Future<void> _addMemo() async {
    if (memoController.text.isNotEmpty) {
      User? user = _auth.currentUser;
      if (user != null) {
        final docRef = await _firestore.collection('users').doc(user.uid).collection('memos').add({
          'content': memoController.text,
          'pinned': false,
        });
        setState(() {
          memos.add({
            'id': docRef.id,
            'content': memoController.text,
            'pinned': false,
          });
          memoController.clear();
        });
      }
    }
  }

  Future<void> _deleteMemo(int index) async {
    User? user = _auth.currentUser;
    if (user != null) {
      final memo = memos[index];
      await _firestore.collection('users').doc(user.uid).collection('memos').doc(memo['id']).delete();
      setState(() {
        memos.removeAt(index);
      });
    }
  }

  Future<void> _editMemo(int index, String newContent) async {
    User? user = _auth.currentUser;
    if (user != null) {
      final memo = memos[index];
      await _firestore.collection('users').doc(user.uid).collection('memos').doc(memo['id']).update({
        'content': newContent,
      });
      setState(() {
        memos[index]['content'] = newContent;
      });
    }
  }

  Future<void> _togglePin(int index) async {
    User? user = _auth.currentUser;
    if (user != null) {
      final memo = memos[index];
      final newPinnedStatus = !memo['pinned'];
      await _firestore.collection('users').doc(user.uid).collection('memos').doc(memo['id']).update({
        'pinned': newPinnedStatus,
      });
      setState(() {
        memos[index]['pinned'] = newPinnedStatus;
      });
    }
  }

  List<Map<String, dynamic>> getFilteredMemos() {
    final filtered = memos
        .where((memo) =>
        memo['content'].toLowerCase().contains(searchKeyword.toLowerCase()))
        .toList();

    filtered.sort((a, b) => (b['pinned'] ? 1 : 0).compareTo(a['pinned'] ? 1 : 0));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredMemos = getFilteredMemos();
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.white, // AppBar 배경색 흰색
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearchDialog();
            },
          )
        ],
      ),
      body: Container(
        color: Colors.white, // 본문 배경색 흰색
        child: Column(
          children: [
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredMemos.length,
                itemBuilder: (context, index) {
                  final memo = filteredMemos[index];
                  return Card(
                    elevation: 4,
                    color: Colors.grey[200], // 메모 배경색을 밝은 회색으로 설정
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(memo['content']),
                      leading: IconButton(
                        icon: Icon(
                          memo['pinned'] ? Icons.push_pin : Icons.push_pin_outlined,
                          color: memo['pinned'] ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => _togglePin(index),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showEditDialog(index, memo['content']);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteMemo(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: memoController,
                      style: const TextStyle(color: Colors.black), // 텍스트 색상 검정
                      decoration: InputDecoration(
                        labelText: '메모를 입력하세요',
                        labelStyle: const TextStyle(color: Colors.black), // 라벨 색상 검정
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black), // 테두리 색상 검정
                        ),
                        focusedBorder: OutlineInputBorder( // 포커스 시 테두리 색상
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black), // 포커스 시 테두리 색상 검정
                        ),
                      ),
                      cursorColor: Colors.black, // 커서 색상 검정
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addMemo,
                    child: const Icon(Icons.add, color: Colors.white), // + 아이콘만 표시
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(50, 50),
                      backgroundColor: Colors.black, // 배경색 검정
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showEditDialog(int index, String currentContent) {
    final TextEditingController editController =
    TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('메모를 수정하세요'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(labelText: '수정하고 싶은 내용 입력'),
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
                _editMemo(index, editController.text);
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  void showSearchDialog() {
    final TextEditingController searchController =
    TextEditingController(text: searchKeyword);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('메모 검색'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(labelText: '검색어 입력'),
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
                setState(() {
                  searchKeyword = searchController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('검색'),
            ),
          ],
        );
      },
    );
  }
}