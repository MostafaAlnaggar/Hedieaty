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
  final TextEditingController _searchController = TextEditingController();
  late Future<List<UserModel>> _friendsFuture;
  late List<UserModel> _allFriends; // To hold the complete list of friends
  late List<UserModel> _filteredFriends; // To hold the filtered list
  final UserController _userController = UserController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _friendsFuture = _userController.fetchFriends();
    _friendsFuture.then((friends) {
      _allFriends = friends;
      _filteredFriends = friends;
    });
  }

  Future<void> _addNewFriend() async {
    final phoneNumber = _friendController.text;
    if (phoneNumber.isNotEmpty) {
      String addFriend = await _userController.addFriend(phoneNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(addFriend)),
      );
      setState(() {
        _friendsFuture = _userController.fetchFriends();
        _friendsFuture.then((friends) {
          _allFriends = friends;
          _filteredFriends = friends;
        });
        _friendController.text = "";
      });
    }
  }

  void _filterFriends(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredFriends = _allFriends;
      } else {
        _filteredFriends = _allFriends
            .where((friend) =>
            friend.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
                  controller: _searchController,
                  onChanged: _filterFriends,
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
            Expanded(
              child: FutureBuilder<List<UserModel>>(
                future: _friendsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No friends found.'));
                  } else {
                    return ListView.builder(
                      itemCount: _filteredFriends.length,
                      itemBuilder: (context, index) {
                        return _buildFriendCard(
                            context, _filteredFriends[index]); // Replace '0' with event count if needed
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 2),
    );
  }


  Widget _buildFriendCard(BuildContext context, UserModel friend) {
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
        trailing: FutureBuilder<int>(
          future: _userController.fetchUserUpcomingEventsLength(friend.uid), // Pass friend's ID to fetch their event count
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(
                color: Color(0xFFDB2367),
                strokeWidth: 2,
              );
            } else if (snapshot.hasError) {
              return Icon(Icons.error, color: Colors.red);
            } else if (!snapshot.hasData || snapshot.data == 0) {
              return CircleAvatar(
                backgroundColor: Colors.grey,
                child: Text(
                  '0',
                  style: TextStyle(
                    fontFamily: 'Aclonica',
                    color: Colors.white,
                  ),
                ),
              );
            } else {
              return CircleAvatar(
                backgroundColor: Color(0xFFDB2367),
                child: Text(
                  '${snapshot.data}', // Display the event count
                  style: TextStyle(
                    fontFamily: 'Aclonica',
                    color: Colors.white,
                  ),
                ),
              );
            }
          },
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/friend',
            arguments: friend,
          );
        },
      ),
    );
  }

}
