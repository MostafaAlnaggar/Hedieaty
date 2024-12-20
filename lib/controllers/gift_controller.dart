import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_lab_3/controllers/user_controller.dart';
import 'package:mobile_lab_3/database/gift_dao.dart';
import 'package:mobile_lab_3/models/gift.dart';
import 'package:mobile_lab_3/services/notification_service.dart';

import '../models/user.dart';

class GiftController {
  final GiftDAO _dao = GiftDAO();

  // Get all gifts
  Future<List<Gift>> getAllGifts() async {
    return await _dao.readAll();
  }

  // Add a new gift
  Future<void> addGift(Gift gift) async {
    await _dao.create(gift);
  }

  // Update an existing gift
  Future<void> updateGift(Gift gift) async {
    await _dao.update(gift);
  }

  // Delete a gift by its ID
  Future<void> deleteGift(int id) async {
    await _dao.delete(id);
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
      UserController userController = UserController();
      UserModel? currentUser = await userController.getCurrentUser();
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
      String? eventOwnerId = await getEventOwnerByGiftId(giftId!);
      if (eventOwnerId == null) {
        return "Error: Unable to fetch event owner.";
      }

      // Fetch the event owner's FCM token
      String? recipientToken = await getUserTokenByUserId(eventOwnerId);
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
      UserController userController = UserController();
      UserModel? currentUser = await userController.getCurrentUser();
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
      String? eventOwnerId = await getEventOwnerByGiftId(giftId!);
      if (eventOwnerId == null) {
        return "Error: Unable to fetch event owner.";
      }

      // Fetch the event owner's FCM token
      String? recipientToken = await getUserTokenByUserId(eventOwnerId);
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

  Future<String?> getEventOwnerByGiftId(String giftId) async {
    try {
      // Reference the 'events' collection
      QuerySnapshot<Map<String, dynamic>> eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .get();

      for (var eventDoc in eventsSnapshot.docs) {
        // Reference the 'gifts' collection inside the event
        CollectionReference<Map<String, dynamic>> giftsCollection =
        eventDoc.reference.collection('gifts');

        // Check if the gift document with the given ID exists
        DocumentSnapshot<Map<String, dynamic>> giftDoc = await giftsCollection.doc(giftId).get();
        if (giftDoc.exists) {
          // Return the 'createdBy' field from the event document
          String? createdBy = eventDoc.data()['createdBy'];
          return createdBy;
        }
      }

      print('No event found containing giftId: $giftId');
      return null;
    } catch (e) {
      print('Error fetching event owner: $e');
      return null;
    }
  }

  Future<String?> getUserTokenByUserId(String userId) async {
    try {
      // Reference the 'users' collection
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Get the 'token' field from the document
        String? token = userDoc.data()?['fcmToken'];
        return token;
      } else {
        print('User with ID $userId does not exist');
        return null;
      }
    } catch (e) {
      print('Error fetching user token: $e');
      return null;
    }
  }



}
