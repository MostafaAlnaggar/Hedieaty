import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this if storing phone in Firestore
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
  bool _isEditingName = false; // For name editing
  bool _isEditingPhone = false; // For phone editing
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: currentUser?.displayName ?? "");
    _phoneController = TextEditingController();
    _fetchPhoneNumber();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Function to fetch phone number from Firestore
  Future<void> _fetchPhoneNumber() async {
    if (currentUser != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      if (doc.exists) {
        setState(() {
          _phoneController.text = doc.data()?['phone'] ?? ''; // Fetch the phone field
        });
      }
    }
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
  Future<void> _saveDisplayName() async {
    try {
      if (_nameController.text.isNotEmpty) {
        await FirebaseAuth.instance.currentUser?.updateDisplayName(_nameController.text);
        await FirebaseAuth.instance.currentUser?.reload();
        setState(() {
          currentUser = FirebaseAuth.instance.currentUser;
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

  // Function to update the phone number in Firestore
  Future<void> _savePhoneNumber() async {
    try {
      if (_phoneController.text.isNotEmpty && currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .update({'phone': _phoneController.text});
        setState(() {
          _isEditingPhone = false; // Exit editing mode
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phone number updated successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update phone number: $e')),
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
                      radius: 50,
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
                          onPressed: _saveDisplayName,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _isEditingName = false;
                            });
                          },
                        ),
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
                              _isEditingName = true;
                            });
                          },
                          icon: Icon(Icons.edit),
                          color: Color(0xFFDB2367),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    _isEditingPhone
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Phone Number',
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: _savePhoneNumber,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _isEditingPhone = false;
                            });
                          },
                        ),
                      ],
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Phone: ",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Aclonica',
                            color: Color(0xFFDB2367)
                          ),
                        ),
                        Text(
                          _phoneController.text.isNotEmpty ? _phoneController.text : "No Phone",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Aclonica',
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isEditingPhone = true;
                            });
                          },
                          icon: Icon(Icons.edit),
                          color: Color(0xFFDB2367),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
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
                                events.remove(event);
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
