import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modo/todo.dart';

import 'memo.dart';
import 'myPage.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      bottomNavigationBar: Obx(
            () => NavigationBar(
          height: 70,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) => controller.selectedIndex.value = index,
          backgroundColor: Colors.white,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.article_outlined),
              label: "Memo",
              selectedIcon: Icon(Icons.article_outlined, color: Colors.black), // 선택된 아이콘 색상 조정
            ),
            NavigationDestination(
              icon: Icon(Icons.format_list_bulleted_outlined),
              label: "Todo",
              selectedIcon: Icon(Icons.format_list_bulleted_outlined, color: Colors.black), // 선택된 아이콘 색상 조정
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle_outlined),
              label: "MyPage",
              selectedIcon: Icon(Icons.account_circle_outlined, color: Colors.black), // 선택된 아이콘 색상 조정
            ),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    MemoPage(), // 순서에 맞게 페이지 정의
    TodoPage(), // 순서 바뀌어 있어서 고쳤음
    Mypage(),
  ];
}
