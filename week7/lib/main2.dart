import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const DigitalDetoxApp());
}

class DigitalDetoxApp extends StatelessWidget {
  const DigitalDetoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '디지털 디톡스 타이머',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Pretendard',
      ),
      home: const DetoxHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// 03. 행동 - 메인 홈 및 타이머 작동 화면
class DetoxHomeScreen extends StatefulWidget {
  const DetoxHomeScreen({super.key});

  @override
  State<DetoxHomeScreen> createState() => _DetoxHomeScreenState();
}

class _DetoxHomeScreenState extends State<DetoxHomeScreen> {
  // 상태 관리 변수들
  bool _isLocking = false;       // 현재 디톡스(잠금) 중인지 여부
  int _totalFine = 0;           // 누적 가상 벌금
  int _selectedMinutes = 10;     // 사용자가 설정한 목표 시간 (분)
  
  // 타이머 관련 변수
  Timer? _timer;
  int _remainingSeconds = 0;

  // 03. 행동 - 디톡스 시작 (타이머 작동 및 앱 잠금 시뮬레이션)
  void _startDetox() {
    setState(() {
      _isLocking = true;
      _remainingSeconds = _selectedMinutes * 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        // 타이머 정상 종료 시 (성공)
        _timer?.cancel();
        setState(() {
          _isLocking = false;
        });
        _showResultDialog(true);
      }
    });
  }

  // 03. 행동 - 포기하기 (실패 시 가상 벌금 부과 및 잠금 해제)
  void _giveUpDetox() {
    _timer?.cancel();
    setState(() {
      _isLocking = false;
      _totalFine += 5000; // 실패 시 가상 벌금 5,000원 누적
    });
    _showResultDialog(false);
  }

  // 결과 안내 팝업창
  void _showResultDialog(bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          isSuccess ? '🎉 디톡스 성공!' : '🚨 디톡스 실패...',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSuccess ? Colors.green : Colors.red,
          ),
        ),
        content: Text(
          isSuccess
              ? '설정한 시간 동안 스마트폰을 멀리하는 데 성공했습니다. 뇌 건강이 +1 상승합니다!'
              : '참지 못하고 스마트폰을 사용했습니다.\n가상 벌금 5,000원이 누적됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 초 단위를 '분:초' 형태로 변환해 주는 헬퍼 함수
  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    String minuteStr = m < 10 ? '0$m' : '$m';
    String secondStr = s < 10 ? '0$s' : '$s';
    return '$minuteStr:$secondStr';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('디지털 디톡스 타이머'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 상단 가상 벌금 현황 대시보드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.monetization_on, color: Colors.amber, size: 28),
                      SizedBox(width: 8),
                      Text('현재 누적 벌금', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text(
                    '$_totalFine 원',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ],
              ),
            ),
            const Spacer(),
            
            // 중앙 타이머 / 설정 영역
            _isLocking
                ? Column(
                    children: [
                      const Icon(Icons.phonelink_lock, size: 80, color: Colors.deepPurple),
                      const SizedBox(height: 24),
                      Text(
                        _formatTime(_remainingSeconds),
                        style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                      const SizedBox(height: 8),
                      const Text('스마트폰 화면이 잠겼습니다. 집중하세요!', style: TextStyle(color: Colors.grey)),
                    ],
                  )
                : Column(
                    children: [
                      const Icon(Icons.phone_android, size: 80, color: Colors.grey),
                      const SizedBox(height: 24),
                      const Text('디톡스 목표 시간을 설정하세요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      // 시간 조절 슬라이더 위젯
                      Slider(
                        value: _selectedMinutes.toDouble(),
                        min: 1,
                        max: 60,
                        divisions: 59,
                        activeColor: Colors.deepPurple,
                        label: '$_selectedMinutes 분',
                        onChanged: (value) {
                          setState(() {
                            _selectedMinutes = value.toInt();
                          });
                        },
                      ),
                      Text(
                        '$_selectedMinutes 분 동안 잠금',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                    ],
                  ),
            
            const Spacer(),
            
            // 하단 상태별 제어 버튼 (시작하기 / 포기하기)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLocking ? Colors.red.shade400 : Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLocking ? _giveUpDetox : _startDetox,
                child: Text(
                  _isLocking ? '포기하기 (벌금 5,000원 부과)' : '디톡스 모드 시작',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
