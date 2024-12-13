import 'package:flutter/material.dart';
import 'package:mobile_lab_3/models/gift.dart';
import '../controllers/event_controller.dart';

class GiftCard extends StatefulWidget {
  final Gift gift;

  const GiftCard({
    required this.gift,
    Key? key,
  }) : super(key: key);

  @override
  _GiftCardState createState() => _GiftCardState();
}

class _GiftCardState extends State<GiftCard> {
  final EventController _eventController = EventController();
  String _eventTitle = "";

  @override
  void initState() {
    super.initState();
    _fetchEventTitle(); // Fetch the event title when the widget initializes
  }

  Future<void> _fetchEventTitle() async {
    final event = await _eventController.getEventById(widget.gift.eventId);
    if (event != null) {
      setState(() {
        _eventTitle = event.title;
      });
    }
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
          "Category: ${widget.gift.category}\nPrice: ${widget.gift.price}\nEvent: $_eventTitle",
          style: TextStyle(
            fontFamily: 'Aclonica',
            fontSize: 14,
            color: widget.gift.isPledged ? Colors.white : Colors.black54,
          ),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/gift_details',
            arguments: widget.gift,
          );
        },
      ),
    );
  }
}
