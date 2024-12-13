import 'package:flutter/material.dart';
import 'package:mobile_lab_3/controllers/event_controller.dart';
import 'package:mobile_lab_3/layouts/custom_title.dart';
import 'package:mobile_lab_3/layouts/event_card.dart';
import 'package:mobile_lab_3/layouts/navbar.dart';
import 'package:mobile_lab_3/models/event.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventController _controller = EventController();
  List<Event> _events = [];
  String? _currentSortOption; // Stores selected sorting option
  bool _isLoading = false; // Indicates if loading is in progress

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    final events = await _controller.getAllEvents();
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  void _sortEvents(String? sortOption) async {
    if (sortOption == null) return;

    setState(() {
      _isLoading = true;
      _events.clear(); // Clear the current list
    });

    final events = await _controller.getAllEvents();

    if (sortOption == "Sort by Title") {
      events.sort((a, b) => a.title.compareTo(b.title));
    } else if (sortOption == "Sort by Date") {
      events.sort((a, b) => a.date.compareTo(b.date));
    } else if (sortOption == "Sort by Category") {
      events.sort((a, b) => a.category.compareTo(b.category));
    }

    setState(() {
      _events = events; // Rebuild with sorted list
      _isLoading = false;
    });
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
                Text(
                  "Events",
                  style: TextStyle(
                    fontFamily: 'Aclonica',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDB2367),
                  ),
                ),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/create_event');
                  },
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
                  value: _currentSortOption,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color:Color(0xFFDB2367), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Color(0xFFDB2367), width: 2.5),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    prefixIcon: Icon(Icons.sort, color: Color(0xFFDB2367)),
                  ),
                  items: ["Sort by Title", "Sort by Date", "Sort by Category"]
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
                    setState(() {
                      _currentSortOption = value;
                    });
                    _sortEvents(value); // Trigger sorting
                  },
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
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _events.isEmpty
                  ? Center(child: Text('No events available.'))
                  : ListView.builder(
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  return EventCard(
                    title: event.title,
                    category: event.category,
                    date: event.date,
                    icon: Icons.event,
                    iconColor: Color(0xFFFFD700),
                    onDelete: () async {
                      await _controller.deleteEvent(event.id!);
                      _loadEvents();
                    },
                    onUpdate: (updatedEvent) async {
                      final updatedWithId = Event(
                        id: event.id,
                        title: updatedEvent.title,
                        category: updatedEvent.category,
                        date: updatedEvent.date,
                        userId: updatedEvent.userId
                      );
                      await _controller.updateEvent(updatedWithId);
                      _loadEvents();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 3),
    );
  }
}
