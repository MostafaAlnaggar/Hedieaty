import 'package:flutter/material.dart';
import 'package:mobile_lab_3/controllers/gift_controller.dart';
import 'package:mobile_lab_3/models/gift.dart';

class FriendGiftCard extends StatefulWidget {
  final Gift gift;
  String? eventTitle;
  final String eventId;

  FriendGiftCard({
    required this.gift,
    this.eventTitle,
    required this.eventId,
    Key? key,
  }) : super(key: key);

  @override
  _FriendGiftCardState createState() => _FriendGiftCardState();
}

class _FriendGiftCardState extends State<FriendGiftCard> {
  late bool isPledged;
  GiftController _giftController = GiftController();
  @override
  void initState() {
    super.initState();
    isPledged = widget.gift.isPledged;
  }

  void _togglePledgeStatus() async {
    if(!isPledged){
      String returnOfFunction = await _giftController.pledgeGift(widget.eventId,widget.gift.firebaseId,widget.gift.title);
      if (returnOfFunction.startsWith("Success")) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(returnOfFunction),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          isPledged = true;
          widget.gift.isPledged = true;
        });
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(returnOfFunction),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    else{
      String returnOfFunction = await _giftController.unpledgeGift(widget.eventId,widget.gift.firebaseId,widget.gift.title);
      if (returnOfFunction.startsWith("Success")) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(returnOfFunction),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          isPledged = false;
          widget.gift.isPledged = false;
        });
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(returnOfFunction),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() {
    });
    // Perform any additional logic for toggling pledge status, e.g., API calls.
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isPledged ? Color(0xFFDB2367) : Colors.white,
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
            color: isPledged ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          "Category: ${widget.gift.category}\n"
              "Price: ${widget.gift.price}\n"
              "${widget.eventTitle != null ? "Event: ${widget.eventTitle}" : ""}",
          style: TextStyle(
            fontFamily: 'Aclonica',
            fontSize: 14,
            color: isPledged ? Colors.white : Colors.black54,
          ),
        ),

        trailing: IconButton(
          icon: Image.asset(
            'assets/icons/Hand_Icon.png',
            color: isPledged ? Colors.white : Color(0xFFDB2367)
          ),
          onPressed: _togglePledgeStatus, // Handle the onPress functionality
        ),
      ),
    );
  }
}
