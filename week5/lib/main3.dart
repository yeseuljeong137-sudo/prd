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
      title: '스마트 장바구니',
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xfff4f7f6)),
      home: const CartScreen(),
    );
  }
}

// ==========================================
// Part A [Data & Interface]
// ==========================================
class ProductItem {
  final String id;
  final String name;
  final int price;
  final String iconEmoji;
  int quantity;

  ProductItem({
    required this.id,
    required this.name,
    required this.price,
    required this.iconEmoji,
    this.quantity = 0,
  });
}

abstract class CartRepository {
  Future<List<ProductItem>> fetchProducts();
  Future<void> updateQuantity(String id, int delta);
  Future<void> clearCart();
}

class InMemoryCartRepository implements CartRepository {
  final List<ProductItem> _productsCache = [
    ProductItem(id: 'p1', name: '프리미엄 텀블러', price: 24500, iconEmoji: '🥤'),
    ProductItem(id: 'p2', name: '무선 저소음 마우스', price: 38000, iconEmoji: '🖱️'),
    ProductItem(id: 'p3', name: '기계식 키보드', price: 89000, iconEmoji: '⌨️'),
  ];

  @override
  Future<List<ProductItem>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_productsCache);
  }

  @override
  Future<void> updateQuantity(String id, int delta) async {
    final index = _productsCache.indexWhere((item) => item.id == id);
    if (index != -1) {
      final newQuantity = _productsCache[index].quantity + delta;
      if (newQuantity >= 0) _productsCache[index].quantity = newQuantity;
    }
  }

  @override
  Future<void> clearCart() async {
    for (var item in _productsCache) {
      item.quantity = 0;
    }
  }
}

// ==========================================
// Part B [Business Logic]
// ==========================================
class CartController extends ChangeNotifier {
  final CartRepository _repository;
  List<ProductItem> _items = [];
  bool _isLoading = false;

  CartController(this._repository);

  List<ProductItem> get items => _items;
  bool get isLoading => _isLoading;

  int get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    _items = await _repository.fetchProducts();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> changeQuantity(String id, int delta) async {
    await _repository.updateQuantity(id, delta);
    await loadProducts();
  }

  Future<void> checkout() async {
    await _repository.clearCart();
    await loadProducts();
  }
}

// ==========================================
// Part C [UI Components & Screen]
// ==========================================
class PriceText extends StatelessWidget {
  final int price;
  final double fontSize;
  final Color color;

  const PriceText({
    super.key,
    required this.price,
    this.fontSize = 14,
    this.color = const Color(0xff2d3748),
  });

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer();
    final str = price.toString();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return Text(
      '${buffer.toString()}원',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}

class ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const ActionIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xfff7fafc),
          border: Border.all(color: const Color(0xffe2e8f0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: const Color(0xff4a5568)),
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final CartController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CartController(InMemoryCartRepository());
    _controller.loadProducts();
    _controller.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              const Text(
                '마트 장바구니',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0d2b45),
                ),
              ),
              const SizedBox(height: 4),
              const Divider(color: Color(0xffe0e0e0), thickness: 1),
              const SizedBox(height: 16),

              _controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _controller.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _controller.items[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: item.quantity > 0
                                ? const Color(0xfff0f7ff)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: item.quantity > 0
                                  ? const Color(0xffbee3f8)
                                  : const Color(0xffe2e8f0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                item.iconEmoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2d3748),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    PriceText(
                                      price: item.price,
                                      fontSize: 13,
                                      color: const Color(0xff718096),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  ActionIconButton(
                                    icon: Icons.remove,
                                    onPressed: () =>
                                        _controller.changeQuantity(item.id, -1),
                                  ),
                                  SizedBox(
                                    width: 32,
                                    child: Center(
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ActionIconButton(
                                    icon: Icons.add,
                                    onPressed: () =>
                                        _controller.changeQuantity(item.id, 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xffe0e0e0), thickness: 1),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '총 장바구니 개수: ${_controller.totalQuantity}개',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xff4a5568),
                    ),
                  ),
                  PriceText(
                    price: _controller.totalPrice,
                    fontSize: 20,
                    color: const Color(0xff00a86b),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _controller.totalQuantity == 0
                      ? null
                      : () => _controller.checkout(),
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
                  child: const Text(
                    '주문하기',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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

