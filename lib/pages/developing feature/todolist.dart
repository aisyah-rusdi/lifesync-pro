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

      final now = DateTime.now();
      final todayDate =
          "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

      setState(() {
        _toDoList = snapshot.docs.map((doc) {
          final data = doc.data();
          final isDaily = data['daily'] ?? false;
          final isCompleted = data['completed'] ?? false;

          if (isDaily && isCompleted && data['date'] != todayDate) {
            // Reset daily task to pending for today
            doc.reference.update({
              'completed': false,
              'date': todayDate,
            });
            data['completed'] = false;
            data['date'] = todayDate;
          }

          return {
            "id": doc.id,
            "taskName": data['taskName'] ?? 'Unnamed Task',
            "date": data['date'],
            "time": data['time'],
            "completed": data['completed'] ?? false,
            "daily": data['daily'] ?? false,
          };
        }).toList();
      });
    }
  }

  Future<void> _addTask(
      String taskName, String date, String time, bool isDaily) async {
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
        'daily': isDaily,
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
    DateTime now = DateTime.now(); // Current date and time
    DateTime? selectedDate = DateTime.now(); // Default selected date
    TimeOfDay? selectedTime = TimeOfDay.now(); // Default selected time
    bool isDailyTask = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Rounded dialog corners
          ),
          title: Center(
            child: Text(
              "Add New Task",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
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
                    labelText: "Task Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                  title: Text(
                    "Select Date: ${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: Icon(Icons.calendar_today, color: Colors.blue),
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
                  title: Text(
                    "Select Time: ${selectedTime!.format(context)}",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: Icon(Icons.access_time, color: Colors.blue),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      // Validate time
                      final selectedDateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );

                      if (selectedDateTime.isBefore(now)) {
                        // Show error if selected time is in the past
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("You cannot select a past time."),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        // Valid time
                        setState(() {
                          selectedTime = pickedTime;
                        });
                      }
                    }
                  },
                ),
                ListTile(
                  title: Text(
                    "Set as Daily Task",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: Checkbox(
                    value: isDailyTask,
                    onChanged: (value) {
                      setState(() {
                        isDailyTask = value ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Cancel Button
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            // Add Task Button
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Validation passed
                  if (selectedDate != null && selectedTime != null) {
                    final formattedDate =
                        "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}";
                    final formattedTime =
                        "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";
                    _addTask(taskController.text.trim(), formattedDate,
                        formattedTime, isDailyTask);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTaskDialog(String taskId, String currentTaskName,
      String? currentDate, String? currentTime) {
    final taskController = TextEditingController(text: currentTaskName);
    DateTime now = DateTime.now();

    // Parse the currentDate string in "DD-MM-YYYY" format and ensure it's valid
    DateTime? selectedDate;
    if (currentDate != null) {
      try {
        selectedDate = DateTime(
          int.parse(currentDate.split('-')[2]), // Year
          int.parse(currentDate.split('-')[1]), // Month
          int.parse(currentDate.split('-')[0]), // Day
        );
      } catch (e) {
        selectedDate = now; // Fallback to today if parsing fails
      }
    } else {
      selectedDate = now; // Default to today if currentDate is null
    }

    // Ensure selectedDate is not before now
    if (selectedDate.isBefore(now)) {
      selectedDate = now;
    }

    TimeOfDay? selectedTime = currentTime != null
        ? TimeOfDay(
            hour: int.parse(currentTime.split(":")[0]),
            minute: int.parse(currentTime.split(":")[1]),
          )
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
                maxLength: 20,
                decoration: InputDecoration(
                  hintText: "Enter task name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              // Date Picker
              ListTile(
                title: Text(
                  "Select Date: ${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? now,
                    firstDate: now,
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
                    final selectedDateTime = DateTime(
                      selectedDate!.year,
                      selectedDate!.month,
                      selectedDate!.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                    if (selectedDateTime.isBefore(now)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("You cannot select a past time."),
                        ),
                      );
                    } else {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  }
                },
              ),
            ],
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            // Save Button
            TextButton(
              onPressed: () {
                if (taskController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Task name cannot be empty.")),
                  );
                  return;
                }
                if (selectedDate != null && selectedTime != null) {
                  final formattedDate =
                      "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}";
                  final formattedTime =
                      "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";
                  _editTask(taskId, taskController.text.trim(), formattedDate,
                      formattedTime);
                }
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Parse the custom date format into DateTime
    DateTime _parseDateTime(String date, String time) {
      final dateParts = date.split('-');
      final timeParts = time.split(':');

      // Assuming date format is DD-MM-YYYY and time format is HH:mm
      return DateTime(
        int.parse(dateParts[2]), // Year
        int.parse(dateParts[1]), // Month
        int.parse(dateParts[0]), // Day
        int.parse(timeParts[0]), // Hour
        int.parse(timeParts[1]), // Minute
      );
    }

    // Filter tasks into categories
    final pendingDailyTasks =
        _toDoList.where((task) => !task['completed'] && task['daily']).toList();
    final pendingCustomTasks = _toDoList
        .where((task) => !task['completed'] && !task['daily'])
        .toList();
    final completedTasks =
        _toDoList.where((task) => task['completed']).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
        centerTitle: true,
      ),
      body: _toDoList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle_outline,
                      size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    "No tasks added",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Pending Daily Tasks Section
                if (pendingDailyTasks.isNotEmpty) ...[
                  Text(
                    "Pending Tasks (Daily)",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  SizedBox(height: 10),
                  ...pendingDailyTasks.map((task) {
                    return _buildTaskCard(task);
                  }).toList(),
                ],

                // Pending Custom Tasks Section
                if (pendingCustomTasks.isNotEmpty) ...[
                  SizedBox(height: 20),
                  Text(
                    "Pending Tasks (Custom)",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange),
                  ),
                  SizedBox(height: 10),
                  ...pendingCustomTasks.map((task) {
                    return _buildTaskCard(task);
                  }).toList(),
                ],

                // Completed Tasks Section
                if (completedTasks.isNotEmpty) ...[
                  SizedBox(height: 20),
                  Text(
                    "Completed Tasks",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  SizedBox(height: 10),
                  ...completedTasks.map((task) {
                    return _buildTaskCard(task, completed: true);
                  }).toList(),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, {bool completed = false}) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          task['taskName'],
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text("Date: ${task['date']}, Time: ${task['time']}"),
        leading: completed
            ? null
            : Checkbox(
                value: task['completed'],
                onChanged: (value) =>
                    _toggleTaskCompletion(task['id'], task['completed']),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!completed)
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showEditTaskDialog(
                  task['id'], // taskId
                  task['taskName'], // currentTaskName
                  task['date'], // currentDate
                  task['time'], // currentTime
                ),
              ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTask(task['id']),
            ),
          ],
        ),
      ),
    );
  }
}
