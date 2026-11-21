import 'package:flutter/material.dart';

void main() {
  runApp(const MyProfileApp());
}

class MyProfileApp extends StatelessWidget {
  const MyProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '프로필 머리말 실습',
      debugShowCheckedModeBanner: false,
      home: MyProfileScreen(),
    );
  }
}

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 머리말 조립 (main3)'),
        backgroundColor: const Color.fromARGB(255, 10, 241, 48),
        foregroundColor: const Color.fromARGB(255, 211, 76, 76),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 이미지에 제시된 프로필 머리말 조립 시작
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),

                // 1. Row: 사진과 소개를 가로로 배치
                child: Row(
                  children: [
                    // 2. CircleAvatar: 왼쪽 프로필 이미지
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Color.fromARGB(255, 255, 9, 161),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Color.fromARGB(255, 182, 221, 8),
                      ),
                    ),

                    // 3. SizedBox: 이미지와 글 사이 간격
                    const SizedBox(width: 16),

                    // 4. Expanded: 남은 폭을 소개 글에 전부 할당
                    Expanded(
                      // 5. Column: 이름과 전공을 세로로 배치
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '홍길동',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '컴퓨터공학 전공 / 플러터 개발자',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 조립 끝
          ],
        ),
      ),
    );
  }
}

