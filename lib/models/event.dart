class Event {
  int? id;
  String title;
  String category;
  String date;
  String userId; // New field

  Event({
    this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.userId, // Add this field to the constructor
  });

  // Convert Event to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'date': date,
      'userId': userId, // Include userId
    };
  }

  // Create Event from Map (useful for reading from DB)
  static Event fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      date: map['date'],
      userId: map['userId'], // Map userId
    );
  }
}
