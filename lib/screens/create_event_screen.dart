import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../controllers/event_controller.dart';
import '../layouts/custom_title.dart';
import '../layouts/navbar.dart';
import '../models/event.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _category = '';
  DateTime? _date;

  final EventController _controller = EventController();

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        _date = selectedDate;
      });
    }
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate() && _date != null) {
      _formKey.currentState!.save();

      // Create a new Event object with the provided data
      final newEvent = Event(
        title: _title,
        category: _category,
        date: _date!.toLocal().toString().split(' ')[0], // Format date as string
        userId: currentUser?.uid??""
      );

      // Save the event using the EventController
      await _controller.addEvent(newEvent);

      // Show a confirmation message (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event created successfully!')),
      );

      // Navigate back to the previous screen
      Navigator.pushNamed(context, '/events');
    } else {
      // Show an error message if validation fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTitle(), // Use the same custom title bar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Event",
                style: TextStyle(
                  fontFamily: 'Aclonica',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDB2367),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                items: ['Fun', 'Work', 'Love', 'General', 'Other']
                    .map(
                      (category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ),
                )
                    .toList(),
                onChanged: (value) => setState(() {
                  _category = value!;
                }),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextButton.icon(
                onPressed: _pickDate,
                icon: Icon(Icons.calendar_today, color: Color(0xFFDB2367)),
                label: Text(
                  _date != null
                      ? 'Selected Date: ${_date!.toLocal().toString().split(' ')[0]}'
                      : 'Pick a Date',
                  style: TextStyle(
                    fontFamily: 'Aclonica',
                    color: Color(0xFFDB2367),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDB2367),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text(
                    'Save Event',
                    style: TextStyle(
                      fontFamily: 'Aclonica',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 3,highlightSelected: false), // Use the same navbar
    );
  }
}
