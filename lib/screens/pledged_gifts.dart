import 'package:flutter/material.dart';
import 'package:mobile_lab_3/controllers/gift_controller.dart';
import 'package:mobile_lab_3/layouts/navbar.dart';

import '../layouts/custom_title.dart';
import '../layouts/friends_gift_card.dart';
import '../layouts/gift_card.dart';
import '../models/gift.dart';

class PledgedGiftsScreen extends StatefulWidget {
  @override
  _PledgedGiftsScreenState createState() => _PledgedGiftsScreenState();
}

class _PledgedGiftsScreenState extends State<PledgedGiftsScreen> {
  bool showPledgedByMe = true; // Tracks which list is currently shown
  List<Gift> pledgedByMe = [];
  List<Gift> pledgedForMe = [];
  bool isLoading = true;
  GiftController _giftController = GiftController();

  @override
  void initState() {
    super.initState();
    fetchPledgedGifts();
  }

  Future<void> fetchPledgedGifts() async {
    setState(() => isLoading = true);

    try {
      if (showPledgedByMe) {
        // Fetch gifts pledged by me
        List<Gift> byMe = await _giftController.getGiftsPledgedByMe();
        setState(() => pledgedByMe = byMe);
      } else {
        // Fetch gifts pledged for me
        List<Gift> forMe = await _giftController.getGiftsPledgedForMe();
        setState(() => pledgedForMe = forMe);
      }
    } catch (e) {
      print("Error fetching gifts: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void toggleView(bool isPledgedByMe) {
    setState(() {
      showPledgedByMe = isPledgedByMe;
    });
    fetchPledgedGifts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTitle(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showPledgedByMe
                        ? Colors.pinkAccent
                        : Colors.grey.shade300,
                    foregroundColor: showPledgedByMe ? Colors.white : Colors.black,
                  ),
                  onPressed: () => toggleView(true),
                  child: Text(
                      "Pledged by Me",
                    style: TextStyle(
                      fontFamily: 'Aclonica',
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !showPledgedByMe
                        ? Colors.pinkAccent
                        : Colors.grey.shade300,
                    foregroundColor: !showPledgedByMe ? Colors.white : Colors.black,
                  ),
                  onPressed: () => toggleView(false),
                  child: Text(
                      "Pledged for Me",
                    style: TextStyle(fontFamily: 'Aclonica',),
                  ),
                ),
              ],
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: showPledgedByMe
                ? ListView.builder(
              itemCount: pledgedByMe.length,
              itemBuilder: (context, index) {
                final gift = pledgedByMe[index];
                return FriendGiftCard(
                  gift: gift,
                  eventId: gift.eventFirebaseId??"",
                );
              },
            )
                : ListView.builder(
              itemCount: pledgedForMe.length,
              itemBuilder: (context, index) {
                final gift = pledgedForMe[index];
                return GiftCard(gift: gift);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 1),
    );
  }
}
