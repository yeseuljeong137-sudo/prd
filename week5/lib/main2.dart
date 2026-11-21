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
      title: '나의 할 일',
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xfff4f7f6)),
      home: const TodoScreen(),
    );
  }
}

// ==========================================
// Part A [Data & Interface]
// ==========================================
class TodoItem {
  final String id;
  final String title;
  bool isCompleted;

  TodoItem({required this.id, required this.title, this.isCompleted = false});
}

abstract class TodoRepository {
  Future<List<TodoItem>> fetchTodos();
  Future<void> saveTodo(TodoItem todo);
  Future<void> toggleTodoStatus(String id);
}

class InMemoryTodoRepository implements TodoRepository {
  final List<TodoItem> _cache = [
    TodoItem(id: '1', title: '5주차 강의 복습'),
    TodoItem(id: '2', title: '상태 흐름도 작성'),
  ];

  @override
  Future<List<TodoItem>> fetchTodos() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_cache);
  }

  @override
  Future<void> saveTodo(TodoItem todo) async {
    _cache.add(todo);
  }

  @override
  Future<void> toggleTodoStatus(String id) async {
    final index = _cache.indexWhere((item) => item.id == id);
    if (index != -1) {
      _cache[index].isCompleted = !_cache[index].isCompleted;
    }
  }
}

// ==========================================
// Part B [Business Logic]
// ==========================================
class TodoController extends ChangeNotifier {
  final TodoRepository _repository;
  List<TodoItem> _todos = [];
  bool _isLoading = false;

  TodoController(this._repository);

  List<TodoItem> get todos => _todos;
  bool get isLoading => _isLoading;
  int get remainingCount => _todos.where((item) => !item.isCompleted).length;

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();
    _todos = await _repository.fetchTodos();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTodo(String title) async {
    if (title.trim().isEmpty) return;
    final newTodo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
    await _repository.saveTodo(newTodo);
    await loadTodos();
  }

  Future<void> toggleTodo(String id) async {
    await _repository.toggleTodoStatus(id);
    await loadTodos();
  }
}

// ==========================================
// Part C [UI Components & Screen]
// ==========================================
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: const Color(0xfff7fafc),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffe2e8f0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffe2e8f0)),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff0d2b45),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  late final TodoController _controller;
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = TodoController(InMemoryTodoRepository());
    _controller.loadTodos();
    _controller.addListener(_onControllerSettled);
  }

  void _onControllerSettled() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerSettled);
    _inputController.dispose();
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
                '나의 할 일',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0d2b45),
                ),
              ),
              const SizedBox(height: 4),
              const Divider(color: Color(0xffe0e0e0), thickness: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    '남은 할 일 ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${_controller.remainingCount}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff00a86b),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _inputController,
                      hintText: '새로운 할 일 입력',
                    ),
                  ),
                  const SizedBox(width: 8),
                  CustomButton(
                    label: '추가',
                    onPressed: () {
                      _controller.addTodo(_inputController.text);
                      _inputController.clear();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _controller.todos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _controller.todos[index];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: item.isCompleted
                                ? const Color(0xffeef7f2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xffe2e8f0)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.isCompleted
                                    ? Icons.check_circle_outline
                                    : Icons.circle_outlined,
                                color: item.isCompleted
                                    ? const Color(0xff00a86b)
                                    : const Color(0xffa0aec0),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff2d3748),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _controller.toggleTodo(item.id),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.isCompleted
                                        ? const Color(0xffd1fae5)
                                        : const Color(0xfff7fafc),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: item.isCompleted
                                          ? const Color(0xffa7f3d0)
                                          : const Color(0xffe2e8f0),
                                    ),
                                  ),
                                  child: Text(
                                    item.isCompleted ? '취소' : '완료',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: item.isCompleted
                                          ? const Color(0xff065f46)
                                          : const Color(0xff718096),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

