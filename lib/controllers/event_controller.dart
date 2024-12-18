import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_lab_3/controllers/gift_controller.dart';
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

  Future<int> publishEventsToFirebase(String uid) async {
    try {
      // Firestore instance
      FirebaseFirestore db = FirebaseFirestore.instance;
      GiftController giftController = GiftController();
      // Fetch all local events
      List<Event> localEvents = await getAllEvents();
      // Fetch Firebase events
      CollectionReference eventsRef = db.collection('events');

      // Publish or update events in Firebase
      int count = 0;

      for (Event event in localEvents) {
        if(await _publishSingleEvent(event=event,uid=uid,eventsRef=eventsRef,giftController=giftController)){
          count++;
        }
      }

      // Return the count of newly added or updated events
      return count;
    } catch (e) {
      print(e);
      return -1;
    }
  }


  Future<bool> _publishSingleEvent(Event event, String uid, CollectionReference eventsRef,GiftController giftController ) async{
    String uniqueId = '${uid}_${event.id}'; // Create composite ID
    DocumentSnapshot existingEventDoc = await eventsRef.doc(uniqueId).get();
    bool returnValue = false;
    // Check if event already exists in Firebase
    if (existingEventDoc.exists) {
      // Compare and update if data is different
      Map<String, dynamic> existingData = existingEventDoc.data() as Map<String, dynamic>;

      bool needsUpdate = false;
      if (existingData['title'] != event.title ||
          existingData['category'] != event.category ||
          existingData['date'] != event.date) {
        needsUpdate = true;
      }

      // Update the event if necessary
      if (needsUpdate) {
        await eventsRef.doc(uniqueId).update({
          'title': event.title,
          'category': event.category,
          'date': event.date,
          'createdBy': uid,
        });
        returnValue = true;
        print('Event updated successfully');
      }
      giftController.publishGiftsOnFirebase(uniqueId);
    } else {
      // If event doesn't exist, create a new one
      await eventsRef.doc(uniqueId).set({
        'title': event.title,
        'category': event.category,
        'date': event.date,
        'createdBy': uid,
      });
      giftController.publishGiftsOnFirebase(uniqueId);
      returnValue = true;
      print('Event added successfully');
    }

    return returnValue;

  }

  Future<List<Event>> getEventsByUserIdFromFirebase(String userId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Query Firestore to get events where 'createdBy' matches the userId
      final querySnapshot = await firestore
          .collection('events')
          .where('createdBy', isEqualTo: userId)
          .get();

      // Map the fetched documents into a list of Event objects
      List<Event> events = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Event(
          title: data['title'] ?? '',
          category: data['category'] ?? '',
          date: data['date'],
          userId: userId,
          firebaseId: doc.id
        );
      }).toList();

      return events;
    } catch (e) {
      print("Error fetching events for user $userId: ${e.toString()}");
      return []; // Return an empty list in case of error
    }
  }

}
