import 'package:flutter/material.dart';
import 'package:mobile_lab_3/layouts/gift_card.dart';
import 'package:mobile_lab_3/models/gift.dart';
import 'package:mobile_lab_3/controllers/gift_controller.dart';
import 'package:mobile_lab_3/layouts/custom_title.dart';
import 'package:mobile_lab_3/layouts/navbar.dart';

class GiftsScreen extends StatefulWidget {
  @override
  _GiftsScreenState createState() => _GiftsScreenState();
}

class _GiftsScreenState extends State<GiftsScreen> {
  final GiftController _controller = GiftController();
  List<Gift> _gifts = [];
  String? _selectedSortOption;
  int eventId = -1; // Default value
  String eventName = "";

  @override
  void initState(){
    super.initState();
    _loadGifts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Extract eventId from route arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args['eventId'] != null && args['eventName'] != null) {
      setState(() {
        eventId = args['eventId'] as int;
        eventName = args["eventName"] as String;
      });
      // _loadGifts();
    } else {
      // _loadGifts(); // Load all gifts if no eventId is passed
    }
  }

  Future<void> _loadGifts() async {
    List<Gift> gifts;
    if (eventId == -1) {
      gifts = await _controller.getAllGifts();
    } else {
      gifts = await _controller.getGiftsByEventId(eventId);
    }

    setState(() {
      _gifts = gifts;
    });
  }

  void _sortGifts(String sortOption) {
    setState(() {
      _selectedSortOption = sortOption;
      switch (sortOption) {
        case "Sort by Name":
          _gifts.sort((a, b) => a.title.compareTo(b.title));
          break;
        case "Sort by Category":
          _gifts.sort((a, b) => a.category.compareTo(b.category));
          break;
        case "Sort by Price":
          _gifts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case "Sort by Event":
          _gifts.sort((a, b) => a.eventId.compareTo(b.eventId));
          break;
        case "Sort by Status":
          _gifts.sort((a, b) => a.isPledged ? 1 : 0.compareTo(b.isPledged ? 1 : 0));
          break;
      }
    });
  }

  void _addGift() async {
    Navigator.pushNamed(context, '/create_gift');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTitle(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible( // Allows Text to take up available space
                  child: Text(
                    eventId == -1 ? "All Gifts" : "Gifts for $eventName",
                    style: TextStyle(
                      fontFamily: 'Aclonica',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDB2367),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                FloatingActionButton(
                  onPressed: _addGift,
                  mini: true,
                  backgroundColor: Color(0xFFFFD700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(Icons.add, color: Color(0xFFDB2367)),
                ),
              ],
            ),

            SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Color(0xFFDB2367), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Color(0xFFDB2367), width: 2.5),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    prefixIcon: Icon(
                      Icons.sort,
                      color: Color(0xFFDB2367),
                    ),
                  ),
                  items: [
                    "Sort by Name",
                    "Sort by Category",
                    "Sort by Price",
                    "Sort by Event",
                    "Sort by Status"
                  ]
                      .map(
                        (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontFamily: 'Aclonica',
                          fontSize: 16,
                          color: Color(0xFFDB2367),
                        ),
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) _sortGifts(value);
                  },
                  value: _selectedSortOption,
                  hint: Center(
                    child: Text(
                      "Sort By",
                      style: TextStyle(
                        fontFamily: 'Aclonica',
                        color: Colors.pinkAccent.shade200,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _gifts.isEmpty
                  ? Center(child: Text('No gifts available.'))
                  : ListView.builder(
                itemCount: _gifts.length,
                itemBuilder: (context, index) {
                  final gift = _gifts[index];
                  return GiftCard(gift: gift);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 0),
    );
  }
}
