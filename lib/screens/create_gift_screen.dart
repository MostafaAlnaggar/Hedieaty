import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
import '../controllers/gift_controller.dart';
import '../models/event.dart';
import '../models/gift.dart';
import '../layouts/custom_title.dart';
import '../layouts/navbar.dart';

class CreateGiftScreen extends StatefulWidget {
  @override
  _CreateGiftScreenState createState() => _CreateGiftScreenState();
}

class _CreateGiftScreenState extends State<CreateGiftScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _category = '';
  String _price = '';
  String _description = '';
  int? _selectedEventId;

  final GiftController _giftController = GiftController();
  final EventController _eventController = EventController();

  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final events = await _eventController.getAllEvents();
    print(events);
    setState(() {
      _events = events;
    });
  }

  void _saveGift() async {
    if (_formKey.currentState!.validate() && _selectedEventId != null) {
      _formKey.currentState!.save();

      // Create a new Gift object
      final newGift = Gift(
        title: _title,
        category: _category,
        price: _price,
        description: _description,
        isPledged: false, // Set isPledged to false by default
        eventId: _selectedEventId!,
      );

      // Save the gift using the GiftController
      await _giftController.addGift(newGift);

      // Show a confirmation message (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gift created successfully!')),
      );

      // Navigate back to the previous screen
      Navigator.pushNamed(context, '/gifts');
    } else {
      // Show an error message if validation fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields and select an event')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTitle(), // Use the custom title bar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Gift",
                style: TextStyle(
                  fontFamily: 'Aclonica',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDB2367),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Select Event',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                items: _events.map((event) {
                  return DropdownMenuItem<int>(
                    value: event.id,
                    child: Text(event.title),
                  );
                }).toList(),
                onChanged: (value) => setState(() {
                  _selectedEventId = value;
                }),
                validator: (value) {
                  if (value == null) {
                    return 'Please select an event';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Gift Title',
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
                items: ['Electronics', 'Clothing', 'Books', 'General', 'Other']
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
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
                onSaved: (value) => _price = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _saveGift,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDB2367),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text(
                    'Save Gift',
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
      bottomNavigationBar: CustomNavBar(selectedIndex: 3, highlightSelected: false),
    );
  }
}
