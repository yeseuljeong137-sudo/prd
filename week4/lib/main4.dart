import 'package:flutter/material.dart';

void main() {
  runApp(const MyNavigationApp());
}

class MyNavigationApp extends StatelessWidget {
  const MyNavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '화면 이동 실습',
      debugShowCheckedModeBanner: false,
      home: FirstScreen(), // 첫 번째 화면으로 시작
    );
  }
}

// 1. 첫 번째 화면 (Navigator.push를 사용해 새 화면 열기)
class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('첫 번째 화면 (main4)'),
        backgroundColor: const Color.fromARGB(255, 255, 7, 7),
        foregroundColor: const Color.fromRGBO(255, 137, 2, 1),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '여기는 첫 번째 화면입니다.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // [요소 1 & 2] Button / onPressed: 사용자의 누르기를 받아 함수 연결
              ElevatedButton(
                onPressed: () {
                  // [요소 3] Navigator.push: 새 화면 열기
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecondScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: const Color.fromARGB(255, 196, 83, 83),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('새 화면 열기 (Navigator.push)'),
              ),
              const SizedBox(height: 20),

              // [요소 1 & 2] InkWell / onTap: 또 다른 누르기 방식 예시
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecondScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 218, 255, 6),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'InkWell로 새 화면 열기 (onTap)',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. 두 번째 화면 (Navigator.pop을 사용해 이전 화면으로 돌아가기)
class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새로 열린 화면'),
        backgroundColor: const Color.fromARGB(255, 43, 16, 117),
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '새로운 화면에 도착했습니다!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // [요소 1 & 2] Button / onPressed: 누르기 감지 후 함수 실행
            ElevatedButton(
              onPressed: () {
                // [요소 4] Navigator.pop: 이전 화면으로 돌아가기
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 252, 9, 142),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('이전 화면으로 돌아가기 (Navigator.pop)'),
            ),
          ],
        ),
      ),
    );
  }
}

