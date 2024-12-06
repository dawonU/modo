import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modo/todo.dart';
import 'package:modo/weather.dart';
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
          backgroundColor: Colors.white, // 하단 내비게이션 바 배경색을 흰색으로 설정
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.article_outlined),
              label: "Memo",
              selectedIcon: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.article_outlined, color: Colors.black),
              ),
            ),
            NavigationDestination(
              icon: Icon(Icons.format_list_bulleted_outlined),
              label: "Todo",
              selectedIcon: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.format_list_bulleted_outlined, color: Colors.black),
              ),
            ),
            NavigationDestination(
              icon: Icon(Icons.sunny_snowing),
              label: "Weather",
              selectedIcon: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.sunny_snowing, color: Colors.black),
              ),
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle_outlined),
              label: "MyPage",
              selectedIcon: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.account_circle_outlined, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white, // body 배경색을 흰색으로 설정
        child: Obx(() => controller.screens[controller.selectedIndex.value]),
      ),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    MemoPage(),
    TodoPage(),
    WeatherPage(),
    Mypage(),
  ];
}
