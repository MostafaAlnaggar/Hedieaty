class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
  });

  // Convert Firebase data to UserModel
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
    );
  }

  // Convert UserModel to Firebase format
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}
