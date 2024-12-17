import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_lab_3/database/database_helper.dart';
import '../models/gift.dart';

class GiftDAO {
  final dbHelper = DatabaseHelper.instance;
  User? currentUser = FirebaseAuth.instance.currentUser; // Get the current Firebase user

  Future<int> create(Gift gift) async {
    final db = await dbHelper.database;
    return await db.insert('gifts', gift.toMap());
  }

  Future<List<Gift>> readAll() async {
    if (currentUser == null) return [];
    final db = await dbHelper.database;

    // Query to get the gifts for the current user by joining the gifts table with events table
    final result = await db.rawQuery('''
    SELECT g.* FROM gifts g
    JOIN events e ON g.event_id = e.id
    WHERE e.userId = ?
  ''', [currentUser!.uid]);

    // Map the query result to Gift objects and return the list
    return result.map((map) => Gift.fromMap(map)).toList();
  }


  Future<int> update(Gift gift) async {
    final db = await dbHelper.database;
    return await db.update('gifts', gift.toMap(), where: 'id = ?', whereArgs: [gift.id]);
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete('gifts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Gift>> getFirstGifts(int limit) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'gifts',
      limit: limit
    );
    // Ensure the result is converted to a List<Event>
    return result.map((map) => Gift.fromMap(map)).toList();
  }

  Future<List<Gift>> getGiftsByEventId(int eventId) async {
    final db = await dbHelper.database;
    final result = await db.query(
        'gifts',
        where: 'event_id = ?', // Filtering by event_id
        whereArgs: [eventId]    // Pass the eventId as an argument
    );

    // Convert the result to a List<Gift>
    return result.map((map) => Gift.fromMap(map)).toList();
  }

}
