import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:todo_app/screens/add.dart';
import 'package:http/http.dart' as http;

class ToDoListPage extends StatefulWidget {
  final Map? todo;
  const ToDoListPage({Key? key, this.todo}) : super(key: key);

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  bool isloading = false;
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ToDo List')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          navigatetoaddpage();
        },
        label: const Text("Add"),
      ),
      body: Visibility(
        visible: isloading,
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index] as Map;
              final id = item['_id'] as String;
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(item['title']),
                subtitle: Text(item['description']),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') {
                      navigatetoeditpage(item);
                    } else if (value == 'delete') {
                      deleteById(id);
                    }
                  },
                  icon: const Icon(Icons.menu),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ];
                  },
                ),
              );
            },
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void navigatetoeditpage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item, isEditing: true),
    );
    await Navigator.push(context, route);
    fetchTodo();
  }

  Future<void> navigatetoaddpage() async {
    final route = MaterialPageRoute(
      builder: (context) => const AddTodoPage(),
    );
    await Navigator.push(context, route);
    fetchTodo();
  }

  Future<void> fetchTodo() async {
    setState(() {
      isloading = true;
    });

    const url = 'http://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }

    setState(() {
      isloading = false;
    });
  }

  Future<void> deleteById(String id) async {
    final url = 'http://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      final filteredItems =
          items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filteredItems;
      });
    } else {
      // Handle error case
    }
  }
}
