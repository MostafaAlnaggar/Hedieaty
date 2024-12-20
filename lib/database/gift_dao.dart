import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_lab_3/database/database_helper.dart';
import '../controllers/user_controller.dart';
import '../models/gift.dart';
import '../models/user.dart';

class GiftDAO {
  final dbHelper = DatabaseHelper.instance;
  User? currentUser = FirebaseAuth.instance.currentUser; // Get the current Firebase user
  final UserController _userController = UserController();
  Future<int> create(Gift gift) async {
    final db = await dbHelper.database;
    return await db.insert('gifts', gift.toMap());
  }

  Future<Map<String, dynamic>?> _fetchGiftFromFirebase(int localId) async {
    try {
      print("Fetching gift with localId: $localId");

      // Get the current user
      UserModel? currentUser = await _userController.getCurrentUser();
      if (currentUser == null) {
        throw Exception("Error: User is not logged in or connection error.");
      }
      String userId = currentUser.uid;

      // Reference to the Firestore collection for events
      final eventsCollection = FirebaseFirestore.instance.collection('events');

      // Query all events created by the current user
      QuerySnapshot eventsSnapshot = await eventsCollection
          .where('createdBy', isEqualTo: userId)
          .get();

      if (eventsSnapshot.docs.isEmpty) {
        return null; // No events found
      }

      // Iterate through each event
      for (var eventDoc in eventsSnapshot.docs) {
        final giftsCollection = eventDoc.reference.collection('gifts');
        QuerySnapshot giftsSnapshot = await giftsCollection
            .where('localId', isEqualTo: localId)
            .get();

        if (giftsSnapshot.docs.isNotEmpty) {
          // Return the first matching gift
          final giftDoc = giftsSnapshot.docs.first;
          return giftDoc.data() as Map<String, dynamic>;
        }
      }

      return null; // No matching gift found
    } catch (e) {
      print("Error fetching gift from Firebase: $e");
      return null;
    }
  }


  Future<List<Gift>> readAll() async {
    if (currentUser == null) return [];
    final db = await dbHelper.database;

    // Query to get the gifts for the current user by joining the gifts table with events table
    final localGifts = await db.rawQuery('''
    SELECT g.* FROM gifts g
    JOIN events e ON g.event_id = e.id
    WHERE e.userId = ?
  ''', [currentUser!.uid]);

    // Map the local gifts to Gift objects
    final gifts = localGifts.map((map) => Gift.fromMap(map)).toList();

    // Sync with Firebase
    for (var gift in gifts) {
      // Check in Firebase
      final firebaseGift = await _fetchGiftFromFirebase(gift.id as int);

      if (firebaseGift != null) {
        // Compare `isPledged` status
        if (firebaseGift['isPledged'] != gift.isPledged) {
          // Update local database if needed
          await db.update(
            'gifts',
            {'isPledged': firebaseGift['isPledged']},
            where: 'id = ?',
            whereArgs: [gift.id],
          );
          // Update the in-memory gift object
          gift.isPledged = firebaseGift['isPledged'];
        }
      }
    }

    return gifts;
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

    // Query gifts from the local database
    final localGifts = await db.query(
      'gifts',
      limit: limit,
    );

    // Map the local gifts to Gift objects
    final gifts = localGifts.map((map) => Gift.fromMap(map)).toList();

    // Sync with Firebase
    for (var gift in gifts) {
      // Check in Firebase
      final firebaseGift = await _fetchGiftFromFirebase(gift.id as int);

      if (firebaseGift != null) {
        // Compare `isPledged` status
        if (firebaseGift['isPledged'] != gift.isPledged) {
          // Update local database if needed
          await db.update(
            'gifts',
            {'isPledged': firebaseGift['isPledged']},
            where: 'id = ?',
            whereArgs: [gift.id],
          );
          // Update the in-memory gift object
          gift.isPledged = firebaseGift['isPledged'];
        }
      }
    }

    return gifts;
  }


  Future<List<Gift>> getGiftsByEventId(int eventId) async {
    final db = await dbHelper.database;

    // Query gifts from the local database
    final localGifts = await db.query(
      'gifts',
      where: 'event_id = ?', // Filtering by event_id
      whereArgs: [eventId], // Pass the eventId as an argument
    );

    // Map the local gifts to Gift objects
    final gifts = localGifts.map((map) => Gift.fromMap(map)).toList();

    // Sync with Firebase
    for (var gift in gifts) {
      // Check in Firebase
      final firebaseGift = await _fetchGiftFromFirebase(gift.id as int);

      if (firebaseGift != null) {
        // Compare `isPledged` status
        if (firebaseGift['isPledged'] != gift.isPledged) {
          // Update local database if needed
          await db.update(
            'gifts',
            {'isPledged': firebaseGift['isPledged']},
            where: 'id = ?',
            whereArgs: [gift.id],
          );
          // Update the in-memory gift object
          gift.isPledged = firebaseGift['isPledged'];
        }
      }
    }

    return gifts;
  }


  Future<Gift?> getById(int id) async {
    final db = await dbHelper.database;

    // Query the local database for the gift with the specified ID
    final localGift = await db.query(
      'gifts',
      where: 'id = ?', // Filter by the ID
      whereArgs: [id], // Pass the ID as an argument
      limit: 1, // Ensure only one result is returned
    );

    if (localGift.isEmpty) {
      // If no gift is found locally, return null
      return null;
    }

    // Map the result to a Gift object
    Gift gift = Gift.fromMap(localGift.first);

    // Fetch the corresponding gift from Firebase
    final firebaseGift = await _fetchGiftFromFirebase(id);

    if (firebaseGift != null) {
      // Compare and update the `isPledged` status if they differ
      if (firebaseGift['isPledged'] != gift.isPledged) {
        // Update the local database
        await db.update(
          'gifts',
          {'isPledged': firebaseGift['isPledged']},
          where: 'id = ?',
          whereArgs: [id],
        );

        // Update the in-memory gift object
        gift.isPledged = firebaseGift['isPledged'];
      }
    }

    return gift;
  }


}

