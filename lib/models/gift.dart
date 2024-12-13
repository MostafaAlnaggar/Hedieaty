class Gift {
  int? id;
  String title;
  String category;
  String price;
  String description;
  bool isPledged;
  int eventId; // New field for foreign key

  Gift({
    this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.description,
    required this.isPledged,
    required this.eventId,
  });

  // Convert Gift to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'price': price,
      'description': description,
      'isPledged': isPledged ? 1 : 0, // Use 1/0 for boolean values
      'event_id': eventId, // Include event_id in the map
    };
  }

  // Create Gift from Map (useful for reading from DB)
  static Gift fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      price: map['price'],
      description: map['description'],
      isPledged: map['isPledged'] == 1,
      eventId: map['event_id'], // Read event_id from map
    );
  }
}
