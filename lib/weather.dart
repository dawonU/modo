import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final double latitude = 37.7749; // 위도
  final double longitude = 126.4194; // 경도

  Map<String, dynamic> weatherData = {}; //날씨
  Map<String, dynamic> airQualityData = {}; // 미세먼지


  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeatherData(); //날씨
    fetchAirQualityData(); // 미세먼지
  }

  //날씨
  Future<void> fetchWeatherData() async {
    final url =
        "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,weathercode&daily=temperature_2m_max,temperature_2m_min,weathercode,humidity_2m&timezone=auto";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          weatherData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to fetch weather data: $e");
    }
  }

  //미세먼지
  Future<void> fetchAirQualityData() async {
    final url =
        "https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$latitude&longitude=$longitude&current=pm10,pm2_5,uv_index&hourly=pm10,pm2_5,uv_index,uv_index_clear_sky&timezone=auto&past_days=3&forecast_days=3";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          airQualityData = jsonDecode(response.body);
        });
        print(airQualityData); // API 응답 출력
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to fetch air quality data: $e");
    }
  }


  IconData getWeatherIcon(int weatherCode) {
    if (weatherCode == 0) {
      return Icons.wb_sunny; // 화창
    } else if (weatherCode == 1 || weatherCode == 2 || weatherCode == 3) {
      return Icons.cloud; // 구름 낌
    } else if (weatherCode == 45 || weatherCode == 48) {
      return Icons.foggy; // 안개
    } else if (weatherCode == 51 || weatherCode == 53 || weatherCode == 55) {
      return Icons.grain; // 가벼운 이슬비
    } else if (weatherCode == 61 || weatherCode == 63 || weatherCode == 65) {
      return Icons.umbrella; // 비
    } else if (weatherCode == 71 || weatherCode == 73 || weatherCode == 75) {
      return Icons.ac_unit; // 눈
    } else if (weatherCode == 95) {
      return Icons.bolt; // 폭풍우
    } else {
      return Icons.help_outline; // 알 수 없음
    }
  }

  String formatDate(int index) {
    if (index == 0) {
      return "어제"; // 어제
    } else if (index == 1) {
      return "오늘"; // 오늘
    } else {
      // 이후부터는 요일 표시 (한국어)
      List<String> daysOfWeek = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"];
      return daysOfWeek[index - 2]; // 인덱스에 따라 요일 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(""),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }


    // 날씨 정보 가져오기
    final currentWeatherCode = weatherData["hourly"]["weathercode"][0];
    final currentTemp = weatherData["hourly"]["temperature_2m"][0];
    final dailyForecast = weatherData["daily"];
    final hourlyTemperatures = weatherData["hourly"]["temperature_2m"];

    // 미세먼지 및 자외선 지수 정보 가져오기
    final pm10 = airQualityData["current"]?["pm10"] ?? "N/A"; // null 체크 추가
    final pm2_5 = airQualityData["current"]?["pm2_5"] ?? "N/A"; // null 체크 추가
    final uvIndex = airQualityData["current"]?["uv_index"] ?? "N/A"; // null 체크 추가

    return Scaffold(
      appBar: AppBar(
        title: Padding(
        padding: const EdgeInsets.only(top: 20.0), // 위쪽 공백 설정
    child: Text("Weather"),
    ),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 50, // AppBar 높이 조정
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 오늘의 기온 배경색 설정
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100], // 밝은 회색 배경
                  borderRadius: BorderRadius.circular(12), // 둥근 모서리 설정
                ),
                padding: const EdgeInsets.all(10.0), // 패딩 조정
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      getWeatherIcon(currentWeatherCode),
                      size: 70,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 15),
                    Text(
                      "$currentTemp°C",
                      style: TextStyle(fontSize: 30),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8), // 제목과 날씨 정보 간의 간격 줄이기

              // 시간별 기온 리스트 (가로 스크롤 가능)
              // Text(
              //   //"시간별 기온",
              //   //style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              // ),
              SizedBox(height: 8),
              Container(
                height: 100, // 높이 조정
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, // 가로 스크롤
                  itemCount: hourlyTemperatures.length,
                  itemBuilder: (context, index) {
                    final hour = index; // 시간 인덱스
                    final temperature = hourlyTemperatures[index];

                    // 오전/오후 표시
                    String period = hour < 12 ? "오전" : "오후";
                    int displayHour = hour % 12 == 0 ? 12 : hour % 12; // 12시간 형식

                    // 아이콘 결정
                    IconData weatherIcon;
                    if (hour >= 19 || hour < 7) {
                      // 오후 7시부터 오전 7시까지는 달 아이콘
                      weatherIcon = Icons.nightlight; // 달 아이콘
                    } else {
                      // 그 외 시간은 날씨 아이콘
                      weatherIcon = getWeatherIcon(weatherData["hourly"]["weathercode"][index]);
                    }

                    return Container(
                      width: 100,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // 각 시간별 아이템 배경색
                        borderRadius: BorderRadius.circular(12), // 둥근 모서리
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 시간
                          Text("$period $displayHour 시", style: TextStyle(fontSize: 16)),
                          SizedBox(height: 4), // 시간과 아이콘 간의 간격
                          // 기온에 맞는 아이콘 추가
                          Icon(
                            weatherIcon, // 결정된 아이콘 사용
                            size: 20,
                            color: hour >= 19 || hour < 7 ? Colors.blue[800] : Colors.orange, // 다크 블루 색상
                          ),
                          SizedBox(height: 4), // 아이콘과 기온 간의 간격
                          // 기온
                          Text("$temperature°C", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16), // 간격 조정

              // 날씨 리스트
              // Text(
              //   "7일 예보",
              //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              // ),
              SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true, // ListView의 높이를 자식의 높이에 맞추기
                physics: NeverScrollableScrollPhysics(), // 스크롤 방지
                itemCount: dailyForecast["temperature_2m_max"].length,
                itemBuilder: (context, index) {
                  final maxTemp = dailyForecast["temperature_2m_max"][index];
                  final minTemp = dailyForecast["temperature_2m_min"][index];
                  final weatherCode = dailyForecast["weathercode"][index];

                  // 어제, 오늘, 그리고 요일 표시
                  return ListTile(
                    leading: Icon(
                      getWeatherIcon(weatherCode),
                      size: 40,
                    ),
                    title: Text(
                      formatDate(index),
                      style: TextStyle(fontSize: 18),
                    ),
                    subtitle: Text("최고: $maxTemp°C, 최저: $minTemp°C"),
                  );
                },
              ),

              //미세먼지
              SizedBox(height: 16), // 간격 조정
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 첫 번째 사각형
                  // 첫 번째 사각형 (미세먼지)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "미세먼지",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text("PM10: $pm10 µg/m³"),
                          Text("PM2.5: $pm2_5 µg/m³"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16), // 간격 조정

                  // 두 번째 사각형 (자외선 지수)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "자외선 지수",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text("UV Index: $uvIndex"),
                        ],
                      ),
                    ),
                  ),

                ],
              ),

              SizedBox(height: 16), // 간격 조정
            ],
          ),
        ),
      ),
    );
  }
}
