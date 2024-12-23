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
    final _formKey = GlobalKey<FormState>(); // Form key for validation
    final taskController = TextEditingController();
    DateTime? selectedDate = DateTime.now();
    TimeOfDay? selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Add New Task"),
          content: Form(
            key: _formKey, // Attach form key
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Task Name Input
                TextFormField(
                  controller: taskController,
                  maxLength: 20, // Limit to 20 characters
                  decoration: InputDecoration(
                    hintText: "Enter task name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Task name is required";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                // Date Picker
                ListTile(
                  title: RichText(
                    text: TextSpan(
                      text: "Select Date: ",
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: selectedDate != null
                              ? "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}"
                              : "Not Selected",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(), // Today and onward
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                ),
                SizedBox(height: 10),
                // Time Picker
                ListTile(
                  title: RichText(
                    text: TextSpan(
                      text: "Select Time: ",
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: selectedTime != null
                              ? selectedTime!.format(context)
                              : "Not Selected",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  trailing: Icon(Icons.access_time),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            // Add Task Button
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Validation passed
                  if (selectedDate != null && selectedTime != null) {
                    final formattedDate =
                        "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}";
                    final formattedTime =
                        "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";
                    _addTask(taskController.text.trim(), formattedDate,
                        formattedTime);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text("Add"),
            ),
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTaskDialog(String taskId, String currentTaskName,
      String? currentDate, String? currentTime) {
    final taskController = TextEditingController(text: currentTaskName);
    DateTime? selectedDate =
        currentDate != null ? DateTime.parse(currentDate) : DateTime.now();
    TimeOfDay? selectedTime = currentTime != null
        ? TimeOfDay(
            hour: int.parse(currentTime.split(":")[0]),
            minute: int.parse(currentTime.split(":")[1]))
        : TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Edit Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Task Name Input
              TextField(
                controller: taskController,
                maxLength: 20, // Limit to 20 characters
                decoration: InputDecoration(
                  hintText: "Enter task name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              // Date Picker
              ListTile(
                title: Text(
                    "Select Date: ${selectedDate?.toLocal().toString().split(' ')[0]}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(), // Restrict to today and onward
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
              ),
              SizedBox(height: 10),
              // Time Picker
              ListTile(
                title: Text(
                    "Select Time: ${selectedTime?.format(context) ?? 'Not Selected'}"),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedTime = pickedTime;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            // Save Button
            TextButton(
              onPressed: () {
                if (selectedDate != null && selectedTime != null) {
                  final formattedDate =
                      "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
                  final formattedTime =
                      "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";
                  _editTask(taskId, taskController.text.trim(), formattedDate,
                      formattedTime);
                }
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
          ],
        ),
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
