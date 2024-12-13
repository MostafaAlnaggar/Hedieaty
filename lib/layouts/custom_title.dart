import 'package:flutter/material.dart';

class CustomTitle extends StatelessWidget implements PreferredSizeWidget {
  const CustomTitle({Key? key}) : super(key: key);

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      leading: Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: Color(0xFFDB2367),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigate back to the previous screen
            Navigator.pop(context);
          },
        ),
      ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Hedieaty',
            style: TextStyle(
              fontFamily: 'LobsterTwo',
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFFDB2367),
            ),
          ),
          SizedBox(width: 8.0),
          Image.asset(
            'assets/icons/Gift_title_Icon.png',
            height: 36.0,
            width: 36.0,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
