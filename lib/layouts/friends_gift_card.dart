import 'package:flutter/material.dart';
import 'package:mobile_lab_3/models/gift.dart';
import '../controllers/event_controller.dart';

class FriendGiftCard extends StatefulWidget {
  final Gift gift;
  final String eventTitle;

  const FriendGiftCard({
    required this.gift,
    required this.eventTitle,
    Key? key,
  }) : super(key: key);

  @override
  _FriendGiftCardState createState() => _FriendGiftCardState();
}

class _FriendGiftCardState extends State<FriendGiftCard> {
  final EventController _eventController = EventController();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.gift.isPledged ? Color(0xFFDB2367) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Image.asset(
          'assets/icons/Gift_title_Icon.png',
          height: 40.0,
          width: 40.0,
          color: Color(0xFFFFD700),
        ),
        title: Text(
          widget.gift.title,
          style: TextStyle(
            fontFamily: 'Aclonica',
            fontSize: 20,
            color: widget.gift.isPledged ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          "Category: ${widget.gift.category}\nPrice: ${widget.gift.price}\nEvent: ${widget.eventTitle}",
          style: TextStyle(
            fontFamily: 'Aclonica',
            fontSize: 14,
            color: widget.gift.isPledged ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}
