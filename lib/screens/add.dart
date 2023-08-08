import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  final bool isEditing;

  const AddTodoPage({Key? key, this.todo, this.isEditing = false})
      : super(key: key);

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      titlecontroller.text = widget.todo?['title'] ?? '';
      descriptioncontroller.text = widget.todo?['description'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit Todo' : 'Add ToDo')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              decoration: const InputDecoration(hintText: 'title'),
              controller: titlecontroller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Description',
              ),
              controller: descriptioncontroller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  submitdata();
                }
              },
              child: Text(widget.isEditing ? 'Edit' : 'Submit'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> submitdata() async {
    final titlefromfeild = titlecontroller.text;
    final descriptionfromfeild = descriptioncontroller.text;
    final postbody = {
      "title": titlefromfeild,
      "description": descriptionfromfeild,
      "is_completed": true
    };

    const url = 'http://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);

    if (widget.isEditing) {
      final editUrl = 'http://api.nstack.in/v1/todos/${widget.todo?['_id']}';
      final editUri = Uri.parse(editUrl);
      final response = await http.put(editUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(postbody));

      if (response.statusCode == 200) {
        showSuccessMessege('Edit success');
        Navigator.pop(context);
      } else {
        showErrorMessege('Edit failed');
      }
    } else {
      final response = await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(postbody));

      if (response.statusCode == 201) {
        titlecontroller.text = '';
        descriptioncontroller.text = '';
        showSuccessMessege('Creation success');
      } else {
        showErrorMessege('Creation failed');
      }
    }
  }

  void showSuccessMessege(String messege) {
    final snackBar = SnackBar(
      content: Text(messege),
      backgroundColor: Colors.white,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessege(String messege) {
    final snackBar = SnackBar(
      content: Text(messege),
      backgroundColor: Colors.redAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
