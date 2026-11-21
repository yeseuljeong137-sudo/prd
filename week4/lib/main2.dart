import 'package:flutter/material.dart';

void main() {
  // 1. MaterialApp: 앱의 시작
  runApp(const MyTreeApp());
}

class MyTreeApp extends StatelessWidget {
  const MyTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '위젯 트리 구조 예시',
      debugShowCheckedModeBanner: false,
      home: MyTreeScreen(),
    );
  }
}

class MyTreeScreen extends StatelessWidget {
  const MyTreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 묶어서 보여줄 예시 데이터 리스트
    final List<String> items = [
      '플러터 위젯 트리 공부하기',
      'MaterialApp으로 앱 시작 설정',
      'Scaffold로 화면 기본 틀 짜기',
      'ListView로 스크롤 본문 만들기',
      'Card로 관련 정보 묶어주기',
      'Text로 실제 글자 화면에 그리기',
    ];

    // 2. Scaffold: 한 화면의 틀
    return Scaffold(
      appBar: AppBar(
        title: const Text('위젯 트리 실습 (main2)'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      // 3. ListView: 스크롤 본문
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          // 4. Card: 관련 정보 묶음
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              // 5. Text: 실제 글자 (동적 변수가 들어가므로 const를 붙이지 않습니다)
              child: Text(
                items[index],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

