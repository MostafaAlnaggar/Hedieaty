import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_lab_3/database/database_helper.dart';
import '../models/event.dart';

class EventDAO {
  User? currentUser = FirebaseAuth.instance.currentUser; // Get the current Firebase user
  final dbHelper = DatabaseHelper.instance;

  // Fetch all events for the current user
  Future<List<Event>> readAll() async {
    if (currentUser == null) return []; // Return an empty list if no user is logged in
    final db = await dbHelper.database;
    final result = await db.query(
      'events',
      where: 'userId = ?', // Filter by userId
      whereArgs: [currentUser!.uid],
    );
    return result.map((map) => Event.fromMap(map)).toList();
  }

  // Update an event only if it belongs to the current user
  Future<int> update(Event event) async {
    if (currentUser == null) return 0; // Do nothing if no user is logged in
    final db = await dbHelper.database;
    return db.update(
      'events',
      event.toMap(),
      where: 'id = ? AND userId = ?', // Filter by event ID and userId
      whereArgs: [event.id, currentUser!.uid],
    );
  }

  Future<int> create(Event event) async {
    final db = await dbHelper.database;
    return db.insert('events', event.toMap());
  }

  // Delete an event only if it belongs to the current user
  Future<int> delete(int id) async {
    if (currentUser == null) return 0; // Do nothing if no user is logged in
    final db = await dbHelper.database;
    return await db.delete(
      'events',
      where: 'id = ? AND userId = ?', // Filter by event ID and userId
      whereArgs: [id, currentUser!.uid],
    );
  }

  // Fetch a limited number of events for the current user
  Future<List<Event>> getFirstEvents(int limit) async {
    if (currentUser == null) return []; // Return an empty list if no user is logged in
    final db = await dbHelper.database;
    final result = await db.query(
      'events',
      limit: limit,
      orderBy: 'title ASC', // Optional: sort by title (or any other column)
      where: 'userId = ?', // Filter by userId
      whereArgs: [currentUser!.uid],
    );
    return result.map((map) => Event.fromMap(map)).toList();
  }

  // Fetch a specific event by ID, only if it belongs to the current user
  Future<Event?> getEventById(int id) async {
    if (currentUser == null) return null; // Return null if no user is logged in
    final db = await dbHelper.database;
    final result = await db.query(
      'events',
      where: 'id = ? AND userId = ?', // Filter by event ID and userId
      whereArgs: [id, currentUser!.uid],
      limit: 1, // Ensure only one result is returned
    );

    if (result.isEmpty) {
      return null; // Return null if no matching event is found
    }

    return Event.fromMap(result.first); // Convert the first result to an Event object
  }
}
