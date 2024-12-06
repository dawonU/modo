import 'package:flutter/material.dart';

class MemoPage extends StatefulWidget {
  @override
  _MemoPageState createState() => _MemoPageState();
}

class _MemoPageState extends State<MemoPage> {
  final List<Map<String, dynamic>> memos = []; // 메모 리스트
  final TextEditingController memoController = TextEditingController();
  String searchKeyword = ''; // 검색 키워드

  void _addMemo() {
    if (memoController.text.isNotEmpty) {
      setState(() {
        memos.add({
          'content': memoController.text,
          'pinned': false, // 상단 고정 여부
        });
        memoController.clear();
      });
    }
  }

  void _deleteMemo(int index) {
    setState(() {
      memos.removeAt(index);
    });
  }

  void _editMemo(int index, String newContent) {
    setState(() {
      memos[index]['content'] = newContent;
    });
  }

  void _togglePin(int index) {
    setState(() {
      memos[index]['pinned'] = !memos[index]['pinned'];
    });
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
