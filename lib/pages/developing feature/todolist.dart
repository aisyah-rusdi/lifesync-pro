// ignore_for_file: prefer_const_constructors, camel_case_types

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_project/pages/todo_box.dart';

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({Key? key}) : super(key: key);

  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late User? _currentUser;
  List<Map<String, dynamic>> _toDoList = [];

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _fetchToDoList();
  }

  Future<void> _fetchToDoList() async {
    if (_currentUser != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('todos')
          .get();
      setState(() {
        _toDoList = snapshot.docs
            .map((doc) => {
                  "id": doc.id,
                  "taskName": doc.data()['taskName'] ?? 'Unnamed Task',
                  "completed": doc.data()['completed'] ?? false,
                })
            .toList();
      });
    }
  }

  Future<void> _addTask(String taskName) async {
    if (_currentUser != null && taskName.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('todos')
          .add({'taskName': taskName, 'completed': false});
      _fetchToDoList();
    }
  }

  Future<void> _toggleTaskCompletion(String taskId, bool isCompleted) async {
    if (_currentUser != null) {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('todos')
          .doc(taskId)
          .update({'completed': !isCompleted});
      _fetchToDoList();
    }
  }

  Future<void> _deleteTask(String taskId) async {
    if (_currentUser != null) {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('todos')
          .doc(taskId)
          .delete();
      _fetchToDoList();
    }
  }

  void _showAddTaskDialog() {
    final taskController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Task"),
        content: TextField(
          controller: taskController,
          decoration: InputDecoration(
            hintText: "Enter task name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _addTask(taskController.text.trim());
              Navigator.of(context).pop();
            },
            child: Text("Add"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To-Do List"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _toDoList.length,
              itemBuilder: (context, index) {
                final task = _toDoList[index];
                return TodoBox(
                  taskName: task['taskName'],
                  taskCompleted: task['completed'],
                  onChanged: (value) =>
                      _toggleTaskCompletion(task['id'], task['completed']),
                  deleteFunction: (context) => _deleteTask(task['id']),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
