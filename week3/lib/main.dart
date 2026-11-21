import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '핑크 스타일 계산기',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFFF0F5),
      ),
      home: Scaffold(
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 650),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F5),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const CalculatorScreen(),
          ),
        ),
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';

  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (RegExp(r'^[0-9.]$').hasMatch(buttonText)) {
        _handleNumber(buttonText);
      } else if (buttonText == '+' ||
          buttonText == '-' ||
          buttonText == '×' ||
          buttonText == '÷') {
        _handleOperator(buttonText);
      } else if (buttonText == '=') {
        _handleCalculate();
      } else if (buttonText == 'C') {
        _clearAll();
      } else if (buttonText == 'CE') {
        _clearEntry();
      } else if (buttonText == '⌫') {
        _backspace();
      } else {
        _handleAdvancedOperator(buttonText);
      }
    });
  }

  void _handleNumber(String numText) {
    if (_shouldResetDisplay) {
      _display = numText == '.' ? '0.' : numText;
      _shouldResetDisplay = false;
    } else {
      if (numText == '.') {
        if (!_display.contains('.')) {
          _display += '.';
        }
      } else {
        _display = (_display == '0') ? numText : _display + numText;
      }
    }
  }

  void _handleOperator(String nextOperator) {
    double currentVal = double.tryParse(_display) ?? 0;

    if (_operator != null && !_shouldResetDisplay) {
      _firstOperand = _calculate(_firstOperand!, currentVal, _operator!);
      _display = _formatResult(_firstOperand!);
    } else {
      _firstOperand = currentVal;
    }

    _operator = nextOperator;
    _expression = '${_formatResult(_firstOperand!)} $_operator';
    _shouldResetDisplay = true;
  }

  void _handleCalculate() {
    if (_operator == null || _firstOperand == null) return;

    double secondOperand = double.tryParse(_display) ?? 0;
    double finalResult = _calculate(_firstOperand!, secondOperand, _operator!);

    _expression =
        '${_formatResult(_firstOperand!)} $_operator ${_formatResult(secondOperand)} =';
    _display = _formatResult(finalResult);

    _firstOperand = null;
    _operator = null;
    _shouldResetDisplay = true;
  }

  double _calculate(double first, double second, String op) {
    switch (op) {
      case '+':
        return first + second;
      case '-':
        return first - second;
      case '×':
        return first * second;
      case '÷':
        return second != 0 ? first / second : 0;
      default:
        return second;
    }
  }

  void _handleAdvancedOperator(String op) {
    double val = double.tryParse(_display) ?? 0;
    switch (op) {
      case 'x²':
        _expression = 'sqr($_display)';
        _display = _formatResult(val * val);
        break;
      case '1/x':
        _expression = '1/($_display)';
        _display = _formatResult(val != 0 ? 1 / val : 0);
        break;
      case '+/-':
        _display = _formatResult(val * -1);
        break;
      case '%':
        _display = _formatResult(val / 100);
        break;
      default:
        break;
    }
    _shouldResetDisplay = true;
  }

  String _formatResult(double value) {
    if (value.isNaN || value.isInfinite) {
      return '0';
    }
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  void _clearAll() {
    _display = '0';
    _expression = '';
    _firstOperand = null;
    _operator = null;
    _shouldResetDisplay = false;
  }

  void _clearEntry() {
    _display = '0';
  }

  void _backspace() {
    if (_shouldResetDisplay) return;
    if (_display.length > 1) {
      _display = _display.substring(0, _display.length - 1);
    } else {
      _display = '0';
    }
  }

  Widget _buildButton(
    String text, {
    required Color bgColor,
    required Color textColor,
    bool isBold = false,
  }) {
    return Container(
      margin: const EdgeInsets.all(3),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => _onButtonPressed(text),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 20, top: 20),
          alignment: Alignment.topLeft,
          child: const Text(
            '핑크 표준 계산기',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _expression,
                  style: TextStyle(fontSize: 16, color: Colors.pink.shade300),
                ),
                const SizedBox(height: 8),
                Text(
                  _display,
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 430,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 1.35,
              children: [
                _buildButton(
                  '%',
                  bgColor: const Color(0xFFFFE4E1),
                  textColor: Colors.pink.shade700,
                ),
                _buildButton(
                  'CE',
                  bgColor: const Color(0xFFFFE4E1),
                  textColor: Colors.pink.shade700,
                ),
                _buildButton(
                  'C',
                  bgColor: const Color(0xFFFFE4E1),
                  textColor: Colors.pink.shade700,
                ),
                _buildButton(
                  '⌫',
                  bgColor: const Color(0xFFFFE4E1),
                  textColor: Colors.pink.shade700,
                ),

                _buildButton(
                  '1/x',
                  bgColor: const Color(0xFFFFE4E1),
                  textColor: Colors.pink.shade700,
                ),
                _buildButton(
                  'x²',
                  bgColor: const Color(0xFFFFE4E1),
                  textColor: Colors.pink.shade700,
                ),
                _buildButton(
                  '+/-',
                  bgColor: const Color(0xFFFFE4E1),
                  textColor: Colors.pink.shade700,
                ), // 루트 버튼 대신 안정적인 버튼 배치
                _buildButton(
                  '÷',
                  bgColor: const Color(0xFFFFD1DC),
                  textColor: Colors.pink.shade900,
                  isBold: true,
                ),

                _buildButton(
                  '7',
                  bgColor: const Color(0xFFFFF0F5),
                  textColor: Colors.black87,
                  isBold: true,
                ),
                _buildButton(
                  '8',
                  bgColor: const Color(0xFFFFF0F5),
                  textColor: Colors.black87,
                  isBold: true,
                ),
                _buildButton(
                  '9',
                  bgColor: const Color(0xFFFFF0F5),
                  textColor: Colors.black87,
                  isBold: true,
                ),
                _buildButton(
                  '×',
                  bgColor: const Color(0xFFFFD1DC),
                  textColor: Colors.pink.shade900,
                  isBold: true,
                ),

                _buildButton(
                  '4',
                  bgColor: const Color(0xFFFFF0F5),
                  textColor: Colors.black87,
                  isBold: true,
                ),
                _buildButton(
                  '5',
                  bgColor: const Color(0xFFFFF0F5),
                  textColor: Colors.black87,
                  isBold: true,
                ),
                _buildButton(
                  '6',
                  bgColor: const Color(0xFFFFF0F5),
                  textColor: Colors.black87,
                  isBold: true,
                ),
                _buildButton(
                  '-',
                  bgColor: const Color(0xFFFFD1DC),
                  textColor: Colors.pink.shade900,
                  isBold: true,
                ),

                _buildButton(
                  '1',
                  bgColor: const Color(0xFFFFF0F5),
                  textColor: Colors.black87,
                  isBold: true,
                ),
                _buildButton(
                  '2',
                  bgColor: const Color(0xFFFFF0F5),
                  textColor: Colors.black87,
                  isBold: true,
                ),
                _buildButton(
                  '3',
                  bgColor: const Color(0xFFFFF0F5),
                  textColor: Colors.black87,
                  isBold: true,
                ),
                _buildButton(
                  '+',
                  bgColor: const Color(0xFFFFD1DC),
                  textColor: Colors.pink.shade900,
                  isBold: true,
                ),

                _buildButton(
                  '(',
                  bgColor: const Color(0xFFFFF0F5),
                  textColor: Colors.black87,
                ), // 레이아웃을 맞추기 위한 여분 버튼들
                _buildButton(
                  '0',
                  bgColor: const Color(0xFFFFF0F5),
                  textColor: Colors.black87,
                  isBold: true,
                ),
                _buildButton(
                  '.',
                  bgColor: const Color(0xFFFFF0F5),
                  textColor: Colors.black87,
                  isBold: true,
                ),
                _buildButton(
                  '=',
                  bgColor: Colors.pinkAccent,
                  textColor: Colors.white,
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
