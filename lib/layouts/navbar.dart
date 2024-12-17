import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final bool highlightSelected; // New flag to control highlighting

  const CustomNavBar({
    required this.selectedIndex,
    this.highlightSelected = true, // Default value is true
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          // Handle navigation logic
          if (index == 0) {
            Navigator.pushNamed(
              context,
              '/gifts',
              arguments: {'eventId': -1},
            );

          } else if (index == 1) {
            Navigator.pushNamed(context, '/donations');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/events');
          } else if (index == 4) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        backgroundColor: const Color(0xFFDB2367),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.white,
        iconSize: 35.0,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/Gift_Nav_Icon.png',
              color: (highlightSelected && selectedIndex == 0)
                  ? const Color(0xFFFFD700)
                  : Colors.white,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/Hand_Icon.png',
              color: (highlightSelected && selectedIndex == 1)
                  ? const Color(0xFFFFD700)
                  : Colors.white,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/Home_White_Icon.png',
              color: (highlightSelected && selectedIndex == 2)
                  ? const Color(0xFFFFD700)
                  : Colors.white,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/Event_Icon.png',
              color: (highlightSelected && selectedIndex == 3)
                  ? const Color(0xFFFFD700)
                  : Colors.white,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: (highlightSelected && selectedIndex == 4)
                  ? const Color(0xFFFFD700)
                  : Colors.white,
            ),
            label: "",
          ),
        ],
      ),
    );
  }
}
