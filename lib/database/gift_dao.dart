import 'package:mobile_lab_3/database/database_helper.dart';
import '../models/gift.dart';

class GiftDAO {
  final dbHelper = DatabaseHelper.instance;

  Future<int> create(Gift gift) async {
    final db = await dbHelper.database;
    return await db.insert('gifts', gift.toMap());
  }

  Future<List<Gift>> readAll() async {
    final db = await dbHelper.database;
    final result = await db.query('gifts');
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
}
