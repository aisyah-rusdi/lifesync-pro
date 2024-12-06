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
        _toDoList = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            "id": doc.id,
            "taskName": data['taskName'] ?? 'Unnamed Task',
            "date": data['date'],
            "time": data['time'],
            "completed": data['completed'] ?? false,
          };
        }).toList();
      });
    }
  }

  Future<void> _addTask(String taskName, String date, String time) async {
    if (_currentUser != null && taskName.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('todos')
          .add({
        'taskName': taskName,
        'date': date,
        'time': time,
        'completed': false,
      });
      _fetchToDoList();
    }
  }

  Future<void> _editTask(
      String taskId, String taskName, String date, String time) async {
    if (_currentUser != null) {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('todos')
          .doc(taskId)
          .update({
        'taskName': taskName,
        'date': date,
        'time': time,
      });
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
    final dateController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                hintText: "Enter task name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                hintText: "Enter date (YYYY-MM-DD)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: timeController,
              decoration: InputDecoration(
                hintText: "Enter time (HH:MM)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _addTask(taskController.text.trim(), dateController.text.trim(),
                  timeController.text.trim());
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

  void _showEditTaskDialog(String taskId, String currentTaskName,
      String? currentDate, String? currentTime) {
    final taskController = TextEditingController(text: currentTaskName);
    final dateController = TextEditingController(text: currentDate ?? "");
    final timeController = TextEditingController(text: currentTime ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                hintText: "Enter task name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                hintText: "Enter date (YYYY-MM-DD)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: timeController,
              decoration: InputDecoration(
                hintText: "Enter time (HH:MM)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _editTask(taskId, taskController.text.trim(),
                  dateController.text.trim(), timeController.text.trim());
              Navigator.of(context).pop();
            },
            child: Text("Save"),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'To-Do List',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _showAddTaskDialog,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 700,
                    child: ListView.builder(
                      itemCount: _toDoList.length,
                      itemBuilder: (context, index) {
                        final task = _toDoList[index];
                        return TodoBox(
                          taskName: task['taskName'],
                          taskCompleted: task['completed'],
                          onChanged: (value) => _toggleTaskCompletion(
                              task['id'], task['completed']),
                          deleteFunction: (context) => _deleteTask(task['id']),
                          editFunction: (context) => _showEditTaskDialog(
                            task['id'],
                            task['taskName'],
                            task['date'],
                            task['time'],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
