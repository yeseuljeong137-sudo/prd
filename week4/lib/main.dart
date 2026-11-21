import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '심플 메모 & 할 일',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const TodoMemoScreen(),
    );
  }
}

// 할 일 데이터 모델
class TodoItem {
  String id;
  String content;
  bool isDone;

  TodoItem({required this.id, required this.content, this.isDone = false});
}

class TodoMemoScreen extends StatefulWidget {
  const TodoMemoScreen({super.key});

  @override
  State<TodoMemoScreen> createState() => _TodoMemoScreenState();
}

class _TodoMemoScreenState extends State<TodoMemoScreen> {
  final TextEditingController _todoController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  // 외부 저장소 대신 메모리 상에서 관리되는 데이터 리스트
  final List<TodoItem> _todoList = [];

  // 할 일 추가
  void _addTodo() {
    if (_todoController.text.trim().isEmpty) return;
    setState(() {
      _todoList.add(
        TodoItem(
          id: DateTime.now().toString(),
          content: _todoController.text.trim(),
        ),
      );
      _todoController.clear();
    });
  }

  // 할 일 체크 토글
  void _toggleTodo(int index) {
    setState(() {
      _todoList[index].isDone = !_todoList[index].isDone;
    });
  }

  // 할 일 삭제
  void _deleteTodo(int index) {
    setState(() {
      _todoList.removeAt(index);
    });
  }

  @override
  void dispose() {
    _todoController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '📝 원파일 메모 & 할 일',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.playlist_add_check), text: '할 일 목록'),
              Tab(icon: Icon(Icons.edit_note), text: '자유 메모장'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 1번 탭: 할 일 목록
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _todoController,
                          decoration: const InputDecoration(
                            hintText: '할 일을 입력한 뒤 + 버튼을 누르세요...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (_) => _addTodo(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addTodo,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _todoList.isEmpty
                        ? const Center(child: Text('할 일이 없습니다. 새로 추가해보세요!'))
                        : ListView.builder(
                            itemCount: _todoList.length,
                            itemBuilder: (context, index) {
                              final item = _todoList[index];
                              return Card(
                                elevation: 1,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: item.isDone,
                                    onChanged: (value) => _toggleTodo(index),
                                  ),
                                  title: Text(
                                    item.content,
                                    style: TextStyle(
                                      decoration: item.isDone
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      color: item.isDone
                                          ? Colors.grey
                                          : Colors.black87,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => _deleteTodo(index),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            // 2번 탭: 자유 메모장
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _memoController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: '여기에 자유롭게 메모를 작성하세요.\n(앱을 완전히 종료하면 메모가 초기화됩니다.)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
