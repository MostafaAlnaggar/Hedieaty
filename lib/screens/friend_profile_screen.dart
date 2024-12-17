import 'package:flutter/material.dart';
import 'package:mobile_lab_3/controllers/event_controller.dart';
import 'package:mobile_lab_3/controllers/gift_controller.dart';
import 'package:mobile_lab_3/layouts/custom_title.dart';
import 'package:mobile_lab_3/layouts/event_card.dart';
import 'package:mobile_lab_3/layouts/navbar.dart';
import 'package:mobile_lab_3/models/event.dart';


class FriendProfileScreen extends StatefulWidget {
  @override
  _FriendProfileScreenState createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  final EventController _eventController = EventController();
  final GiftController _giftController = GiftController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomTitle(),

        body: Padding(
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
                        "M",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Aclonica',
                          color: Color(0xFFDB2367),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "user2",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Aclonica',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
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
                          "01010834903",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Aclonica',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16)
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
              Expanded(
                child: FutureBuilder<List<Event>>(
                  future: _eventController.getAllEvents(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No events available.'));
                    } else {
                      final events = snapshot.data!;
                      return ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return EventCard(
                            eventId: event.id,
                            title: event.title,
                            category: event.category,
                            date: event.date,
                            icon: Icons.event, // Customize icon based on category if needed
                            iconColor: Color(0xFFFFD700), // Customize icon color if needed
                            onDelete: ()  {},
                            showActions: false,
                            onUpdate: (updatedData) {},
                          );
                        },
                      );
                    }
                  },
                ),
              ),


              // SizedBox(height: 16),
              // Text(
              //   "Gifts",
              //   style: TextStyle(
              //     fontFamily: 'Aclonica',
              //     fontSize: 22,
              //     fontWeight: FontWeight.bold,
              //     color: Color(0xFFDB2367),
              //   ),
              // ),
              //
              // SizedBox(height: 8),
              // Expanded(
              //   child: FutureBuilder<List<Gift>>(
              //     future: _giftController.getAllGifts(),
              //     builder: (context, snapshot) {
              //       if (snapshot.connectionState == ConnectionState.waiting) {
              //         return Center(child: CircularProgressIndicator());
              //       } else if (snapshot.hasError) {
              //         return Center(child: Text('Error: ${snapshot.error}'));
              //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              //         return Center(child: Text('No gifts available.'));
              //       } else {
              //         final gifts = snapshot.data!;
              //         return ListView.builder(
              //           itemCount: gifts.length,
              //           itemBuilder: (context, index) {
              //             final gift = gifts[index];
              //             return GiftCard(gift: gift,);
              //           },
              //         );
              //       }
              //     },
              //   ),
              // ),

            ],
          ),
        ),
        bottomNavigationBar: CustomNavBar(selectedIndex: 4, highlightSelected: false)
    );
  }

}