import 'package:flutter/material.dart';
import 'package:mobile_lab_3/controllers/user_controller.dart';
import 'package:mobile_lab_3/layouts/navbar.dart';
import 'package:mobile_lab_3/models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _friendController = TextEditingController();
  late Future<List<UserModel>> _friendsFuture;
  UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    _friendsFuture = _userController.fetchFriends();
  }

  Future<void> _addNewFriend() async {
    final phoneNumber = _friendController.text;
    if (phoneNumber.isNotEmpty) {
      String addFriend = await _userController.addFriend(phoneNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(addFriend)),
      );
      setState(() {
        _friendsFuture = _userController.fetchFriends(); // Refresh friends list
        _friendController.text = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hedieaty',
              style: TextStyle(
                fontFamily: 'LobsterTwo',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDB2367),
              ),
            ),
            SizedBox(width: 8.0),
            Image.asset(
              'assets/icons/Gift_title_Icon.png',
              height: 30.0,
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
                width: MediaQuery.of(context).size.width * 0.75,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _friendController,
                        decoration: InputDecoration(
                          hintText: "Add Friend",
                          hintStyle: TextStyle(
                            fontFamily: 'Aclonica',
                            color: Colors.pinkAccent.shade100,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color(0xFFDB2367),
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Color(0xFFDB2367),
                              width: 2.5,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.person_add_alt_1,
                            color: Color(0xFFDB2367),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: FloatingActionButton(
                        onPressed: _addNewFriend,
                        backgroundColor: Color(0xFFFFD700),
                        shape: CircleBorder(),
                        child: Icon(
                          Icons.add,
                          size: 30,
                          color: Color(0xFFDB2367),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'assets/images/gift_box.png',
                      height: 140,
                    ),
                  ),
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
                          ),
                        ),
                        SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () {},
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
                width: MediaQuery.of(context).size.width * 0.75,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: TextStyle(
                      fontFamily: 'Aclonica',
                      color: Colors.pinkAccent.shade100,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Color(0xFFDB2367), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Color(0xFFDB2367), width: 2.5),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xFFDB2367),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),
            // Fetch and display friends dynamically
            FutureBuilder<List<UserModel>>(
              future: _friendsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No friends found.'));
                } else {
                  final friends = snapshot.data!;

                  return Expanded(
                    child: ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<int>(
                          future: _userController.fetchUserUpcomingEventsLength(friends[index].uid), // Fetch the events length asynchronously
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              // Show loading indicator while the data is being fetched
                              return _buildFriendCard(context, friends[index], '..');
                            } else if (snapshot.hasError) {
                              // Handle error
                              return _buildFriendCard(context, friends[index], '!');
                            } else if (snapshot.hasData) {
                              // When the data is fetched successfully
                              return _buildFriendCard(context, friends[index], snapshot.data.toString());
                            } else {
                              // In case there's no data
                              return _buildFriendCard(context, friends[index], '0');
                            }
                          },
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 2),
    );
  }

  Widget _buildFriendCard(BuildContext context, UserModel friend, String count) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFFFD700).withOpacity(0.4),
          child: Text(
            friend.name[0],
            style: TextStyle(
              fontFamily: 'Aclonica',
              color: Color(0xFFDB2367),
            ),
          ),
        ),
        title: Text(
          friend.name,
          style: TextStyle(
            fontFamily: 'Aclonica',
          ),
        ),
        trailing: CircleAvatar(
          backgroundColor: Color(0xFFDB2367),
          child: Text(
            count,
            style: TextStyle(
              fontFamily: 'Aclonica',
              color: Colors.white,
            ),
          ),
        ),
        onTap: () {
          Navigator.pushNamed(context,
              '/friend',
              arguments: friend,
          );
        },
      ),
    );
  }
}
