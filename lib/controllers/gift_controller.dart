import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_lab_3/controllers/user_controller.dart';
import 'package:mobile_lab_3/database/gift_dao.dart';
import 'package:mobile_lab_3/models/gift.dart';
import 'package:mobile_lab_3/services/notification_service.dart';

import '../models/user.dart';

class GiftController {
  final UserController _userController = UserController();
  final GiftDAO _dao = GiftDAO();

  // Get all gifts
  Future<List<Gift>> getAllGifts() async {
    return await _dao.readAll();
  }

  Future<void> addGift(Gift gift) async {
    try {
      // Add the gift to the local database and get the generated ID
      int generatedId = await _dao.create(gift);

      // Update the `id` in the gift object
      gift.id = generatedId;

      // Get the current user
      UserModel? currentUser = await _userController.getCurrentUser();
      if (currentUser == null) {
        throw Exception("Error: No logged-in user found.");
      }

      // Construct the Firebase event ID
      String eventFirebaseId = '${currentUser.uid}_${gift.eventId}';

      // Check if the event exists in Firebase
      bool eventExists = await _checkEventExistsInFirebase(eventFirebaseId);

      if (eventExists) {
        // If the event exists, add the gift to the event in Firebase
        await _addGiftToEventInFirebase(eventFirebaseId, gift);
      } else {
        // Handle the case where the event does not exist
        print("Event with ID $eventFirebaseId does not exist in Firebase.");
      }
    } catch (e) {
      print("Error adding gift: $e");
    }
  }

  Future<bool> _checkEventExistsInFirebase(String eventFirebaseId) async {
    try {
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventFirebaseId)
          .get();

      return eventDoc.exists;
    } catch (e) {
      print("Error checking if event exists: $e");
      return false;
    }
  }


  // Update an existing gift
  Future<void> updateGift(Gift gift) async {
    try{
    await _dao.update(gift);
    // Get the current user
    UserModel? currentUser = await _userController.getCurrentUser();
    if (currentUser == null) {
      throw Exception("Error: No logged-in user found.");
    }

    // Construct the Firebase event ID
    String eventFirebaseId = '${currentUser.uid}_${gift.eventId}';

    // Check if the event exists in Firebase
    bool eventExists = await _checkEventExistsInFirebase(eventFirebaseId);

    if (eventExists) {
      // If the event exists, add the gift to the event in Firebase
      await _addGiftToEventInFirebase(eventFirebaseId, gift);
    } else {
      // Handle the case where the event does not exist
      print("Event with ID $eventFirebaseId does not exist in Firebase.");
    }
    } catch (e) {
      print("Error adding gift: $e");
    }
  }

  // Delete a gift by its ID
// Delete a gift by its ID
  Future<void> deleteGift(int id) async {
    try {
      // Fetch the gift details from the local database
      Gift? gift = await _dao.getById(id);

      if (gift == null) {
        print("Gift with ID $id does not exist in the local database.");
        return;
      }

      // Get the current user
      UserModel? currentUser = await _userController.getCurrentUser();
      if (currentUser == null) {
        throw Exception("Error: No logged-in user found.");
      }

      // Construct the Firebase event ID
      String eventFirebaseId = '${currentUser.uid}_${gift.eventId}';

      // Check if the event exists in Firebase
      bool eventExists = await _checkEventExistsInFirebase(eventFirebaseId);

      if (eventExists) {
        // Delete the gift from the event in Firebase
        await _deleteGiftFromEventInFirebase(eventFirebaseId, gift);
      } else {
        print("Event with ID $eventFirebaseId does not exist in Firebase.");
      }

      // Delete the gift locally
      await _dao.delete(id);

      print("Gift with ID $id deleted successfully.");
    } catch (e) {
      print("Error deleting gift: $e");
    }
  }

// Helper function to delete a gift from Firebase
  Future<void> _deleteGiftFromEventInFirebase(String eventFirebaseId, Gift gift) async {
    try {
      // Reference the Firebase event's gifts collection
      final giftsCollection = FirebaseFirestore.instance
          .collection('events')
          .doc(eventFirebaseId)
          .collection('gifts');

      // Query the gift by its localId
      QuerySnapshot giftSnapshot = await giftsCollection
          .where('localId', isEqualTo: gift.id)
          .get();

      if (giftSnapshot.docs.isNotEmpty) {
        // Delete the gift document
        await giftSnapshot.docs.first.reference.delete();
        print("Gift with localId ${gift.id} deleted from Firebase.");
      } else {
        print("Gift with localId ${gift.id} does not exist in Firebase.");
      }
    } catch (e) {
      print("Error deleting gift from Firebase: $e");
    }
  }


  // Get the first 'n' gifts
  Future<List<Gift>> getFirstGifts(int limit) async {
    return await _dao.getFirstGifts(limit);
  }

  Future<List<Gift>> getGiftsByEventId(int eventId) async{
    return await _dao.getGiftsByEventId(eventId);
  }


  Future<void> publishGiftsOnFirebase(String fireBaseEventId) async {
    try {
      // Parse the local event ID from the Firebase event ID
      int localEventId = int.parse(fireBaseEventId.split('_').last);

      // Fetch the gifts related to this event
      List<Gift> gifts = await _dao.getGiftsByEventId(localEventId);

      // Loop through each gift and add it to Firebase
      for (Gift gift in gifts) {
        await _addGiftToEventInFirebase(fireBaseEventId, gift);
      }
      print('All gifts published successfully');
    } catch (e) {
      print('Error publishing event on Firebase: $e');
    }
  }


  Future<void> _addGiftToEventInFirebase(String fireBaseEventId, Gift gift) async {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;

      // Check if the gift already exists using the title as a unique identifier
      QuerySnapshot querySnapshot = await db
          .collection('events')
          .doc(fireBaseEventId)
          .collection('gifts')
          .where('title', isEqualTo: gift.title)
          .get();

      // If the gift exists and data is different, update it
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot existingDoc = querySnapshot.docs.first;
        Map<String, dynamic> existingData = existingDoc.data() as Map<String, dynamic>;

        // Compare the existing data with the new gift data and update if different
        bool needsUpdate = false;
        if (existingData['category'] != gift.category ||
            existingData['price'] != gift.price ||
            existingData['isPledged'] != gift.isPledged ||
            existingData['description'] != gift.description) {
          needsUpdate = true;
        }

        if (needsUpdate) {
          await existingDoc.reference.update({
            'category': gift.category,
            'price': gift.price,
            'isPledged': gift.isPledged,
            'description': gift.description,
            'localId': gift.id
          });
          print('Gift updated successfully');
        } else {
          print('Gift data is the same, no update required');
        }
      } else {
        // If the gift doesn't exist, add it as a new document
        await db
            .collection('events')
            .doc(fireBaseEventId)
            .collection('gifts')
            .add({
          'title': gift.title,
          'category': gift.category,
          'price': gift.price,
          'isPledged': gift.isPledged,
          'description': gift.description,
          'localId': gift.id
        });
        print('Gift added successfully');
      }
    } catch (e) {
      print('Error adding or updating gift: $e');
    }
  }

  Future<List<Gift>> fetchGiftsForEvent(String fireBaseEventId) async {
    try {
      int localEventId = int.parse(fireBaseEventId.split('_').last);
      FirebaseFirestore db = FirebaseFirestore.instance;
      QuerySnapshot snapshot = await db
          .collection('events')
          .doc(fireBaseEventId)
          .collection('gifts')
          .get();

      return snapshot.docs.map((doc) {
        return Gift(
          firebaseId: doc.id,
          title: doc['title'],
          price: doc['price'],
          description: doc['description'],
          category: doc['category'],
          isPledged: doc['isPledged'],
          eventId: localEventId,
        );
      }).toList();
    } catch (e) {
      print('Error fetching gifts: $e');
      return [];
    }
  }


  Future<String> pledgeGift(String eventId, String? giftId, String giftTitle) async {
    try {
      UserModel? currentUser = await _userController.getCurrentUser();
      String userId = "";
      String userName = "";
      if(currentUser != null){
        userId = currentUser.uid;
        userName = currentUser.name ?? "Someone";
      }
      else{
        return "Connection Error";
      }
      // Get a reference to the Firestore collection for events
      final eventDoc = FirebaseFirestore.instance.collection('events').doc(eventId);

      // Fetch the event document
      final eventSnapshot = await eventDoc.get();
      if (!eventSnapshot.exists) {
        return "Error: Event with ID $eventId does not exist.";
      }

      // Fetch the gifts collection inside the event
      final giftsCollection = eventDoc.collection('gifts');
      final giftDoc = giftsCollection.doc(giftId);

      // Fetch the gift document
      final giftSnapshot = await giftDoc.get();
      if (!giftSnapshot.exists) {
        return "Error: $giftTitle does not exist in event $eventId.";
      }

      // Check the isPledged attribute
      final giftData = giftSnapshot.data();
      if (giftData == null || giftData['isPledged'] == null) {
        return "Error: $giftTitle is missing required attributes.";
      }

      if (giftData['isPledged'] == true) {
        return "Error: $giftTitle is already pledged.";
      }

      // Update the gift to mark it as pledged and add the pledgedBy attribute
      await giftDoc.update({
        'isPledged': true,
        'pledgedBy': userId,
      });

      // Fetch the event owner
      String? eventOwnerId = await _userController.getEventOwnerByGiftId(giftId!);
      if (eventOwnerId == null) {
        return "Error: Unable to fetch event owner.";
      }

      // Fetch the event owner's FCM token
      String? recipientToken = await _userController.getUserTokenByUserId(eventOwnerId);
      if (recipientToken == null) {
        return "Error: Unable to fetch recipient's FCM token.";
      }


      NotificationService notificationService = NotificationService();
      await notificationService.sendPushNotification(
        recipientToken: recipientToken,
        title: "$userName pledged your gift",
        body: "Your gift $giftTitle has been pledged by $userName.",
      );

      return "Success: $giftTitle has been pledged.";
    } catch (e) {
      // Handle any errors
      return "Error: ${e.toString()}";
    }
  }


  Future<String> unpledgeGift(String eventId, String? giftId, String giftTitle) async {
    try {
      UserModel? currentUser = await _userController.getCurrentUser();
      String userId = "";
      String userName = ""; // Assuming UserModel has a `name` field
      if (currentUser != null) {
        userId = currentUser.uid;
        userName = currentUser.name ?? "Someone"; // Fallback for missing name
      } else {
        return "Connection Error";
      }

      // Get a reference to the Firestore collection for events
      final eventDoc = FirebaseFirestore.instance.collection('events').doc(eventId);

      // Fetch the event document
      final eventSnapshot = await eventDoc.get();
      if (!eventSnapshot.exists) {
        return "Error: Event with ID $eventId does not exist.";
      }

      // Fetch the gifts collection inside the event
      final giftsCollection = eventDoc.collection('gifts');
      final giftDoc = giftsCollection.doc(giftId);

      // Fetch the gift document
      final giftSnapshot = await giftDoc.get();
      if (!giftSnapshot.exists) {
        return "Error: $giftTitle does not exist in event $eventId.";
      }

      // Check the isPledged and pledgedBy attributes
      final giftData = giftSnapshot.data();
      if (giftData == null || giftData['isPledged'] == null || giftData['pledgedBy'] == null) {
        return "Error: $giftTitle is missing required attributes.";
      }

      if (giftData['isPledged'] == false) {
        return "Error: $giftTitle is not currently pledged.";
      }

      if (giftData['pledgedBy'] != userId) {
        return "Error: $giftTitle was not pledged by you.";
      }

      // Update the gift to unpledge it
      await giftDoc.update({
        'isPledged': false,
        'pledgedBy': FieldValue.delete(), // Removes the pledgedBy attribute
      });

      // Fetch the event owner
      String? eventOwnerId = await _userController.getEventOwnerByGiftId(giftId!);
      if (eventOwnerId == null) {
        return "Error: Unable to fetch event owner.";
      }

      // Fetch the event owner's FCM token
      String? recipientToken = await _userController.getUserTokenByUserId(eventOwnerId);
      if (recipientToken == null) {
        return "Error: Unable to fetch recipient's FCM token.";
      }

      // Send a notification
      NotificationService notificationService = NotificationService();
      await notificationService.sendPushNotification(
        recipientToken: recipientToken,
        title: "$userName unpledged your gift",
        body: "Your gift $giftTitle has been unpledged by $userName.",
      );

      return "Success: $giftTitle has been unpledged.";
    } catch (e) {
      // Handle any errors
      return "Error: ${e.toString()}";
    }
  }


  Future<List<Gift>> getGiftsPledgedByMe() async {
    try {
      // Get the current user
      UserModel? currentUser = await _userController.getCurrentUser();
      if (currentUser == null) {
        throw Exception("Error: User is not logged in or connection error.");
      }
      String userId = currentUser.uid;

      // Reference to the Firestore collection for events
      final eventsCollection = FirebaseFirestore.instance.collection('events');

      // Query all events to find gifts pledged by the user
      QuerySnapshot eventsSnapshot = await eventsCollection.get();
      if (eventsSnapshot.docs.isEmpty) {
        print("No Events Found");
        return []; // No events found
      }

      List<Gift> pledgedGifts = [];

      // Iterate through each event
      for (var eventDoc in eventsSnapshot.docs) {
        final giftsCollection = eventDoc.reference.collection('gifts');
        QuerySnapshot giftsSnapshot = await giftsCollection
            .where('pledgedBy', isEqualTo: userId)
            .get();
        for (var giftDoc in giftsSnapshot.docs) {
          final data = giftDoc.data() as Map<String, dynamic>;
          pledgedGifts.add(
            Gift(
              firebaseId: giftDoc.id,
              title: data['title'],
              category: data['category'],
              price: data['price'],
              description: data['description'],
              isPledged: data['isPledged'] ?? false,
              eventId: 0,
              eventFirebaseId: eventDoc.id
            ),
          );
        }
      }
      return pledgedGifts;
    } catch (e) {
      print("Error fetching gifts pledged by me: ${e.toString()}");
      return [];
    }
  }

  Future<List<Gift>> getGiftsPledgedForMe() async {
    try {
      print("Entered the function");
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
        return []; // No events found
      }

      List<Gift> pledgedGiftsForMe = [];

      // Iterate through each event
      for (var eventDoc in eventsSnapshot.docs) {
        final giftsCollection = eventDoc.reference.collection('gifts');
        QuerySnapshot giftsSnapshot = await giftsCollection
            .where('isPledged', isEqualTo: true)
            .get();

        for (var giftDoc in giftsSnapshot.docs) {
          final data = giftDoc.data() as Map<String, dynamic>;
          pledgedGiftsForMe.add(
            Gift(
              firebaseId: giftDoc.id,
              title: data['title'],
              category: data['category'],
              price: data['price'],
              description: data['description'],
              isPledged: data['isPledged'] ?? false,
              eventId: 0,
              eventFirebaseId: eventDoc.id
            ),
          );
        }
      }

      return pledgedGiftsForMe;
    } catch (e) {
      print("Error fetching gifts pledged for me: ${e.toString()}");
      return [];
    }
  }
}
