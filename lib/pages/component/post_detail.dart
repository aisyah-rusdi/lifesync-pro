import 'package:flutter/material.dart';

class PostDetail extends StatefulWidget {
  final String activityName;
  final String category;
  final int numPeople;
  final String date;
  final String time;
  final String location;
  final String userEmail;
  final bool isEditable; // Flag to check if post is editable
  final String postId;
  final Function onDelete; // Callback for deleting the post
  final Function(Map<String, dynamic>) onEdit; // Callback for editing the post
  final List<String> likes;

  PostDetail({
    required this.activityName,
    required this.category,
    required this.numPeople,
    required this.date,
    required this.time,
    required this.location,
    required this.userEmail,
    required this.isEditable,
    required this.postId,
    required this.onDelete,
    required this.onEdit,
    required this.likes,
  });

  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.category; // Initialize selectedCategory with the current category
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Text(
        widget.activityName,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
      ),
      content: Container(
        width: 350,
        height: 300,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow("Category:", widget.category),
              _buildInfoRow("Number of People:", widget.numPeople.toString()),
              _buildInfoRow("Date:", widget.date),
              _buildInfoRow("Time:", widget.time),
              _buildInfoRow("Location:", widget.location),
              _buildInfoRow("Posted by:", widget.userEmail),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.isEditable)
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              // Show edit confirmation if people are interested
              if (widget.likes.length > 0) {
                _showEditConfirmation(context);
              } else {
                _showEditDialog(context);
              }
            },
          ),
        if (widget.isEditable)
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: const Text("Close"),
        ),
      ],
    );
  }

  // Helper method to build info rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            "$label ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  // Method to show the edit confirmation dialog if people are interested
  void _showEditConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Are you sure you want to edit?"),
        content: Text(
          "There are ${widget.likes.length} people interested in joining. Editing it may burden others",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _showEditDialog(context); // Show edit form
            },
            child: const Text("Confirm Edit"),
          ),
        ],
      ),
    );
  }

  // Method to show the delete confirmation dialog if people are interested
  void _showDeleteConfirmation(BuildContext context) {
    if (widget.likes.length > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Are you sure you want to delete?"),
          content: Text(
            "There are ${widget.likes.length} people interested in joining the activity. Deleting it will remove them as well.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onDelete(); // Perform the delete operation
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Close the post details dialog
              },
              child: const Text("Confirm Delete"),
            ),
          ],
        ),
      );
    } else {
      widget.onDelete(); // No people interested, directly delete
      Navigator.pop(context); // Close the dialog
    }
  }

  // Method to show the edit dialog
  void _showEditDialog(BuildContext context) {
    final activityNameController = TextEditingController(text: widget.activityName);
    final numPeopleController = TextEditingController(text: widget.numPeople.toString());
    final dateController = TextEditingController(text: widget.date);
    final timeController = TextEditingController(text: widget.time);
    final locationController = TextEditingController(text: widget.location);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text("Edit Post", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: activityNameController,
                  decoration: const InputDecoration(hintText: "Activity Name"),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                  items: ['Exercise', 'Study', 'Entertainment'] // Replace with actual categories
                      .map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  decoration: const InputDecoration(hintText: "Category"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: numPeopleController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: "Number of People"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(hintText: "Location"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(hintText: "Date"),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      final formattedDate =
                          "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
                      dateController.text = formattedDate;
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(hintText: "Time"),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (selectedTime != null) {
                      final formattedTime =
                          "${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}";
                      timeController.text = formattedTime;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // Collect updated data
              final updatedData = {
                'ActivityName': activityNameController.text,
                'NumPeople': int.tryParse(numPeopleController.text) ?? 0,
                'Category': selectedCategory, // Include selected category in the updated data
                'Date': dateController.text,
                'Time': timeController.text,
                'Location': locationController.text,
              };
              widget.onEdit(updatedData); // Pass updated data to the onEdit callback
              Navigator.pop(context); // Close the dialog
            },
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }
}
