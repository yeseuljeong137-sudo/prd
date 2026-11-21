import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController num1Controller = TextEditingController();
  final TextEditingController num2Controller = TextEditingController();

  double result = 0;

  void calculate(String operator) {
    double num1 = double.tryParse(num1Controller.text) ?? 0;
    double num2 = double.tryParse(num2Controller.text) ?? 0;

    setState(() {
      if (operator == '+') {
        result = num1 + num2;
      } else if (operator == '-') {
        result = num1 - num2;
      } else if (operator == '×') {
        result = num1 * num2;
      } else if (operator == '÷') {
        if (num2 != 0) {
          result = num1 / num2;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('간단 계산기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 첫 번째 숫자
            TextField(
              controller: num1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '첫 번째 숫자',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // 두 번째 숫자
            TextField(
              controller: num2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '두 번째 숫자',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // 계산 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => calculate('+'),
                  child: const Text('+'),
                ),
                ElevatedButton(
                  onPressed: () => calculate('-'),
                  child: const Text('-'),
                ),
                ElevatedButton(
                  onPressed: () => calculate('×'),
                  child: const Text('×'),
                ),
                ElevatedButton(
                  onPressed: () => calculate('÷'),
                  child: const Text('÷'),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Text(
              '결과 : $result',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}