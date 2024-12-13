import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_lab_3/controllers/event_controller.dart';
import 'package:mobile_lab_3/layouts/custom_title.dart';
import 'package:mobile_lab_3/layouts/event_card.dart';
import 'package:mobile_lab_3/layouts/navbar.dart';
import 'package:mobile_lab_3/models/event.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  final EventController _eventController = EventController();
  bool _isEditingName = false; // To toggle between text and text field
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: currentUser?.displayName ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Function to handle logout
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  // Function to update the display name in Firebase
  void _saveDisplayName() async {
      try {
        if (_nameController.text.isNotEmpty) {
          // Update the display name in Firebase
          await FirebaseAuth.instance.currentUser?.updateDisplayName(_nameController.text);

          // Reload the user to fetch the updated data
          await FirebaseAuth.instance.currentUser?.reload();

          // Fetch the updated user instance
          final updatedUser = FirebaseAuth.instance.currentUser;

          // Update the state with the new display name
          setState(() {
            currentUser = updatedUser;
            _isEditingName = false; // Exit editing mode
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Name updated successfully!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update name: $e')),
        );
      }
    }


    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTitle(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50, // Increase the size of the CircleAvatar
                      backgroundColor: Color(0xFFFFD700).withOpacity(0.4),
                      child: Text(
                        currentUser?.displayName != null && currentUser!.displayName!.isNotEmpty
                            ? currentUser!.displayName![0]
                            : "?",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Aclonica',
                          color: Color(0xFFDB2367),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    _isEditingName
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Display Name',
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: _saveDisplayName, // Save changes and close editing
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _isEditingName = false; // Cancel editing
                            });
                          },),
                      ],
                    )
                        : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentUser?.displayName ?? "No Name",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Aclonica',
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isEditingName = true; // Enable editing mode
                            });
                          },
                          icon: Icon(Icons.edit),
                          color: Color(0xFFDB2367),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Logout Button
                    TextButton(
                      onPressed: _logout,
                      child: Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Aclonica',
                          color: Color(0xFFDB2367),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationThickness: 5.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Events",
                style: TextStyle(
                  fontFamily: 'Aclonica',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDB2367),
                ),
              ),
              SizedBox(height: 8),
              FutureBuilder<List<Event>>(
                future: _eventController.getFirstEvents(3),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No events available.'));
                  } else {
                    final events = snapshot.data!;
                    return Column(
                      children: [
                        ...events.map((event) {
                          return EventCard(
                            title: event.title,
                            category: event.category,
                            date: event.date,
                            icon: Icons.event,
                            iconColor: Color(0xFFFFD700),
                            onDelete: () async {
                              await _eventController.deleteEvent(event.id!);
                              setState(() {
                                events.remove(event); // Update the list dynamically
                              });
                            },
                            onUpdate: (updatedData) {},
                          );
                        }).toList(),
                        if (events.length > 2)
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/events');
                              },
                              child: Text(
                                "View all",
                                style: TextStyle(
                                  fontFamily: 'Aclonica',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFDB2367),
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 10.0,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 4),
    );
  }
}
