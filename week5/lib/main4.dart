import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vibe 배달 결제',
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xfff4f7f6)),
      home: const PaymentScreen(),
    );
  }
}

// ==========================================================================
// 1. DATA & INTERFACE LAYER (DIP, ISP, LSP, OCP 준수)
// ==========================================================================

/// 결제 요청 시 필요한 순수 데이터 모델 (SRP)
class PaymentRequest {
  final String orderId;
  final int originalAmount;
  final int discountAmount;

  PaymentRequest({
    required this.orderId,
    required this.originalAmount,
    this.discountAmount = 0,
  });

  // 쿠폰 할인 등이 적용된 최종 결제 금액 계산 로직을 캡슐화
  int get finalAmount => originalAmount - discountAmount;
}

/// 결제 결과를 담는 모델 (SRP)
class PaymentResult {
  final bool isSuccess;
  final String message;
  final String transactionId;

  PaymentResult({
    required this.isSuccess,
    required this.message,
    required this.transactionId,
  });
}

/// [DIP 핵심 인터페이스] 모든 결제 수단은 이 규격을 따른다.
/// 새로운 결제 수단이 추가되어도 이 인터페이스만 상속받으면 기존 비즈니스 로직은 안전함 (OCP)
abstract class PaymentProcessor {
  String get providerName;
  Future<PaymentResult> processPayment(PaymentRequest request);
}

/// 카카오페이 결제 구현체 (LSP: 부모의 계약을 완벽히 이행)
class KakaoPayProcessor implements PaymentProcessor {
  @override
  String get providerName => '카카오페이';

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    await Future.delayed(const Duration(milliseconds: 800)); // 네트워크 가상 지연
    return PaymentResult(
      isSuccess: true,
      message: '카카오페이 안전 결제가 완료되었습니다.',
      transactionId: 'KKP_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

/// 네이버페이 결제 구현체 (LSP)
class NaverPayProcessor implements PaymentProcessor {
  @override
  String get providerName => '네이버페이';

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return PaymentResult(
      isSuccess: true,
      message: '네이버페이 포인트 적립과 함께 결제 완료되었습니다.',
      transactionId: 'NVP_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

// ==========================================================================
// 2. BUSINESS LOGIC LAYER (SRP, OCP 준수)
// ==========================================================================

/// 결제 화면의 상태와 비즈니스 규칙만 전담하는 컨트롤러 (SRP)
class PaymentController extends ChangeNotifier {
  // 사용 가능한 결제 수단 목록 (나중에 토스페이 등이 오면 여기에 플러그인처럼 한 줄 추가)
  final List<PaymentProcessor> availableProcessors = [
    KakaoPayProcessor(),
    NaverPayProcessor(),
  ];

  late PaymentProcessor _selectedProcessor;
  bool _isProcessing = false;
  PaymentResult? _lastResult;

  // 요구사항 피드백: 쿠폰 할인 기능 확장성 선점
  int _appliedCouponDiscount = 0;
  final int _orderAmount = 28500; // 가상 배달 주문 금액

  PaymentController() {
    _selectedProcessor = availableProcessors.first;
  }

  // Getters
  PaymentProcessor get selectedProcessor => _selectedProcessor;
  bool get isProcessing => _isProcessing;
  PaymentResult? get lastResult => _lastResult;
  int get orderAmount => _orderAmount;
  int get couponDiscount => _appliedCouponDiscount;
  int get finalAmount => _orderAmount - _appliedCouponDiscount;

  void selectProcessor(PaymentProcessor processor) {
    _selectedProcessor = processor;
    notifyListeners();
  }

  /// 나중에 구현될 쿠폰 기능을 안전하게 비즈니스 로직에 결합 (OCP 예시)
  void applyCoupon(int discount) {
    _appliedCouponDiscount = discount;
    notifyListeners();
  }

  /// 특정 결제 수단에 결합되지 않는 고수준 결제 요청 오케스트레이션 (DIP)
  Future<void> executePayment() async {
    if (_isProcessing) return;

    _isProcessing = true;
    _lastResult = null;
    notifyListeners();

    final request = PaymentRequest(
      orderId: 'ORDER_${DateTime.now().microsecondsSinceEpoch}',
      originalAmount: _orderAmount,
      discountAmount: _appliedCouponDiscount,
    );

    // 고수준 컨트롤러는 알맹이가 카카오인지 네이버인지 모른 채 규격 인터페이스만 호출
    _lastResult = await _selectedProcessor.processPayment(request);

    _isProcessing = false;
    notifyListeners();
  }
}

// ==========================================================================
// 3. UI PRESENTATION LAYER & REUSABLE COMPONENTS (DRY, SRP 준수)
// ==========================================================================

/// 금액을 포맷팅하여 보여주는 재사용 컴포넌트 (DRY)
class AmountRow extends StatelessWidget {
  final String label;
  final int amount;
  final bool isTotal;

  const AmountRow({
    super.key,
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal
                  ? const Color(0xff0d2b45)
                  : const Color(0xff4a5568),
            ),
          ),
          Text(
            '${amount.toString().replaceAllMapped(RegExp(r'(\d{3})(?=\d)'), (Match m) => '${m[1]},')}원',
            style: TextStyle(
              fontSize: isTotal ? 20 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal
                  ? const Color(0xff00a86b)
                  : const Color(0xff2d3748),
            ),
          ),
        ],
      ),
    );
  }
}

/// 메인 결제 화면
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentController _controller = PaymentController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateUi);
  }

  void _updateUi() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_updateUi);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '주문 결제',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff0d2b45),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xff0d2b45), width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 주문 금액 명세서 영역 (DRY 컴포넌트 재사용)
              const Text(
                '결제 금액 정보',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0d2b45),
                ),
              ),
              const SizedBox(height: 8),
              AmountRow(label: '주문 금액', amount: _controller.orderAmount),
              AmountRow(label: '쿠폰 할인 금액', amount: _controller.couponDiscount),
              const Divider(color: Color(0xffe0e0e0)),
              AmountRow(
                label: '최종 결제 금액',
                amount: _controller.finalAmount,
                isTotal: true,
              ),
              const SizedBox(height: 24),

              // 2. 가상 쿠폰 적용 테스팅 버튼 (OCP 구조 검증용)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '쿠폰 사용 예시:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: _controller.couponDiscount > 0
                        ? () => _controller.applyCoupon(0)
                        : () => _controller.applyCoupon(3000),
                    child: Text(
                      _controller.couponDiscount > 0
                          ? '쿠폰 취소'
                          : '3,000원 쿠폰 적용하기',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const Divider(color: Color(0xffe0e0e0)),
              const SizedBox(height: 12),

              // 3. 결제 수단 셀렉터 영역 (OCP, DIP 효과로 동적 렌더링)
              const Text(
                '결제 수단 선택',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0d2b45),
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: _controller.availableProcessors.map((processor) {
                  final isSelected =
                      _controller.selectedProcessor.providerName ==
                      processor.providerName;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xfff0f7ff)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xffbee3f8)
                            : const Color(0xffe2e8f0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: RadioListTile<String>(
                      title: Text(
                        processor.providerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      value: processor.providerName,
                      groupValue: _controller.selectedProcessor.providerName,
                      onChanged: (_) => _controller.selectProcessor(processor),
                      activeColor: const Color(0xff0d2b45),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // 4. 최종 결제 요청 및 결과 노출 영역
              if (_controller.lastResult != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xffeef7f2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '🎉 ${_controller.lastResult!.message}\n승인번호: ${_controller.lastResult!.transactionId}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff065f46),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _controller.isProcessing
                      ? null
                      : () => _controller.executePayment(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0d2b45),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xffcbd5e0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _controller.isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          '${_controller.selectedProcessor.providerName}로 결제하기',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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

