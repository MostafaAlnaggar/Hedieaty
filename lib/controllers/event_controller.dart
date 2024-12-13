import 'package:mobile_lab_3/database/event_dao.dart';
import 'package:mobile_lab_3/models/event.dart';

class EventController {
  final EventDAO _dao = EventDAO();

  // Fetch all events
  Future<List<Event>> getAllEvents() async {
    return await _dao.readAll();
  }

  // Add a new event
  Future<void> addEvent(Event event) async {
    await _dao.create(event);
  }

  // Update an existing event
  Future<void> updateEvent(Event event) async {
    await _dao.update(event);
  }

  // Delete an event by its ID
  Future<void> deleteEvent(int id) async {
    await _dao.delete(id);
  }

  // Get the first 'n' events, sorted by date
  Future<List<Event>> getFirstEvents(int limit) async {
    return await _dao.getFirstEvents(limit);
  }

  Future<Event?> getEventById(int id) async {
    return await _dao.getEventById(id);
  }
}
