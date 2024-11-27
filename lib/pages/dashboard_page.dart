// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'todo_box.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
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
                  "dateTime": doc.data().containsKey('dateTime')
                      ? (doc.data()['dateTime'] as Timestamp).toDate()
                      : DateTime.now(),
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
          .add({
        'taskName': taskName,
        'completed': false,
        'dateTime': FieldValue.serverTimestamp(),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade500,
                    offset: Offset(4.0, 4.0),
                    blurRadius: 15.0,
                    spreadRadius: 1.0,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(-4.0, -4.0),
                    blurRadius: 15.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: Column(
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
                          dateTime: task['dateTime'],
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
