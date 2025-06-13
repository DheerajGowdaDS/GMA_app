import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  Future<void> addUser(String name, String email) async {
    const url =
        'http://10.0.2.2:5000/api/add-user'; // Use your local IP if on real phone

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'email': email}),
    );

    if (response.statusCode == 201) {
      print('✅ User added: ${response.body}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User added successfully!')));
    } else {
      print('❌ Failed to add user: ${response.body}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add user')));
    }
  }

  void submitData() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isNotEmpty && email.isNotEmpty) {
      addUser(name, email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: submitData, child: Text('Submit')),
          ],
        ),
      ),
    );
  }
}
