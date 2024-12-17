import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/event.dart';

class EventCard extends StatefulWidget {
  final int? eventId;
  final String title;
  final String category;
  final String date;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onDelete;
  final ValueChanged<Event> onUpdate; // Updated type
  final bool showActions;

  const EventCard({
    Key? key,
    required this.eventId,
    required this.title,
    required this.category,
    required this.date,
    required this.icon,
    required this.iconColor,
    required this.onDelete,
    required this.onUpdate,
    this.showActions = true,
  }) : super(key: key);

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isEditing = false;
  late String _title;
  late String _category;
  late String _date;

  late String _originalTitle;
  late String _originalCategory;
  late String _originalDate;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _category = widget.category;
    _date = widget.date;

    // Save original values for cancellation
    _originalTitle = widget.title;
    _originalCategory = widget.category;
    _originalDate = widget.date;
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_date) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _date = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap:(){
            Navigator.pushNamed(context, '/gifts', arguments: {'eventId': widget.eventId, 'eventName': widget.title});
          }, // Navigate when tapped
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(_isEditing ? 16.0 : 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: _isEditing
                  ? Border.all(color: const Color(0xFFFFD700), width: 2)
                  : null,
              boxShadow: [
                if (_isEditing)
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: widget.iconColor.withOpacity(0.4),
                    child: Icon(widget.icon, color: Color(0xFFDB2367)),
                  ),
                  title: _isEditing
                      ? TextFormField(
                    initialValue: _title,
                    onChanged: (value) => _title = value,
                    decoration: const InputDecoration(labelText: 'Title'),
                    style: const TextStyle(fontFamily: 'Aclonica'),
                  )
                      : Text(
                    _title,
                    style: const TextStyle(
                      fontFamily: 'Aclonica',
                      fontSize: 20,
                    ),
                  ),
                  subtitle: _isEditing
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _category,
                        items: ['Fun', 'Work', 'Love', 'General']
                            .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _category = value;
                            });
                          }
                        },
                        decoration:
                        const InputDecoration(labelText: 'Category'),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today,
                            color: Color(0xFFDB2367)),
                        label: Text(
                          _date.isNotEmpty
                              ? 'Selected Date: $_date'
                              : 'Pick a Date',
                          style: const TextStyle(
                            fontFamily: 'Aclonica',
                            fontSize: 12,
                            color: Color(0xFFDB2367),
                          ),
                        ),
                      ),
                    ],
                  )
                      : Text(
                    "Category: $_category\nDate: $_date",
                    style: const TextStyle(
                      fontFamily: 'Aclonica',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  trailing: widget.showActions
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = !_isEditing;

                            if (!_isEditing) {
                              _title = _originalTitle;
                              _category = _originalCategory;
                              _date = _originalDate;
                            }
                          });
                        },
                        icon: Icon(
                          _isEditing ? Icons.cancel : Icons.edit,
                          color: _isEditing
                              ? Colors.red
                              : Color(0xFFDB2367),
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onDelete,
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  )
                      : null,
                ),
                if (_isEditing)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFD700)),
                      onPressed: () {
                        final updatedEvent = Event(
                          title: _title,
                          category: _category,
                          date: _date,
                          userId: currentUser?.uid ?? "",
                        );

                        widget.onUpdate(updatedEvent);
                        setState(() {
                          _isEditing = false;
                          _originalTitle = _title;
                          _originalCategory = _category;
                          _originalDate = _date;
                          print('Saved changes: $updatedEvent');
                        });
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDB2367)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
