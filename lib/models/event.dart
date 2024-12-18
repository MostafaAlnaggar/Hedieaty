class Event {
  int? id; // Local database ID
  String title;
  String category;
  String date;
  String userId; // User who created the event
  String? firebaseId; // Optional Firebase document ID

  Event({
    this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.userId,
    this.firebaseId, // Optional field with default value
  });

  // Convert Event to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'date': date,
      'userId': userId,
    };
  }

  // From Firestore data
  factory Event.fromFirestore(Map<String, dynamic> data, [String? firebaseId]) {
    return Event(
      id: data['id'],
      title: data['title'] ?? '',
      date: data['date'],
      userId: data['createdBy'] ?? '',
      category: data['category'],
      firebaseId: firebaseId, // Assign the Firebase document ID
    );
  }

  // Create Event from Map (useful for reading from local DB)
  static Event fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      date: map['date'],
      userId: map['userId'],
    );
  }
}
