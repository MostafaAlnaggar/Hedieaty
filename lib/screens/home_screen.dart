import 'package:flutter/material.dart';
import 'package:mobile_lab_3/layouts/navbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the default back button
        title: Row(
          mainAxisSize: MainAxisSize.min, // Ensures the row takes up only as much space as needed
          children: [
            Text(
              'Hedieaty',
              style: TextStyle(
                fontFamily: 'LobsterTwo', // Use the family name defined in pubspec.yaml
                fontSize: 24,
                fontWeight: FontWeight.bold, // Matches the 700 weight in the YAML file
                color: Color(0xFFDB2367),
              ),
            ),
            SizedBox(width: 8.0), // Add spacing between the text and image
            Image.asset(
              'assets/icons/Gift_title_Icon.png',
              height: 30.0, // Adjust size as needed
              width: 30.0,
            ),
          ],
        ),
        centerTitle: true,
      ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Friend and Special Moments Section
            Center(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75, // 75% of the screen width
                    child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Add Friend",
                            hintStyle: TextStyle(
                                fontFamily: 'Aclonica',
                                color: Colors.pinkAccent.shade100), // Hint text in pink
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(color: Color(0xFFDB2367), width: 1.0), // Border color when not focused
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(color: Color(0xFFDB2367), width: 2.5), // Border color when focused
                            ),
                            prefixIcon: Icon(
                              Icons.person_add_alt_1,
                              color: Color(0xFFDB2367), // Change icon color
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 8),
                      SizedBox(
                        height: 50, // Customize height
                        width: 50,  // Customize width
                        child: FloatingActionButton(
                          onPressed: () {}, // Adjust icon size
                          backgroundColor: Color(0xFFFFD700), // Gold color
                          shape: CircleBorder(), // Add your logic
                          child: Icon(Icons.add, size: 30, color: Color(0xFFDB2367)), // Ensures round shape
                        ),
                      ),

                    ],
                  )
                )
            ),
            SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Color(0xFFDB2367),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Left side illustration
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'assets/images/gift_box.png', // Replace with actual asset
                      height: 140,
                    ),
                  ),
                  // Right side text and button
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Special gifts for\nspecial moments!",
                          style: TextStyle(
                            fontFamily: 'Aclonica',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            // fontFamily:
                          ),
                        ),
                        SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () {}, // Add your logic
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFD700),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/create_event');
                            },
                            child: Text(
                              "Create your event",
                              style: TextStyle(
                                fontFamily: 'Aclonica',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFDB2367),
                              ),
                            ),
                          ),

                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75, // 75% of the screen width
                // Search bar
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: TextStyle(
                        fontFamily: 'Aclonica',
                        color: Colors.pinkAccent.shade100), // Hint text in pink
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Color(0xFFDB2367), width: 1.0), // Border color when not focused
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Color(0xFFDB2367), width: 2.5), // Border color when focused
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xFFDB2367), // Change icon color
                    ),
                  ),
                ),
              )
            ),
            SizedBox(height: 25),
            // Friend List
            Expanded(
              child: ListView(
                children: [
                  _buildFriendCard(context,"Mostafa Essam", 3),
                  _buildFriendCard(context,"Ahmed Baher", 1),
                ],
              ),
            ),
          ],
        ),
      ),
        bottomNavigationBar: CustomNavBar(selectedIndex: 2)

    );
  }

  Widget _buildFriendCard(BuildContext context, String name, int count) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFFFD700).withOpacity(0.4),
          child: Text(
            name[0],
            style: TextStyle(
              fontFamily: 'Aclonica',
              color: Color(0xFFDB2367),
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontFamily: 'Aclonica',
          ),
        ),
        trailing: CircleAvatar(
          backgroundColor: Color(0xFFDB2367),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontFamily: 'Aclonica',
              color: Colors.white,
            ),
          ),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/friend');
        },
      ),
    );
  }


}
