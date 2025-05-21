class UserData {
  final String uid;
  final String email;

  UserData({required this.uid, required this.email});

  factory UserData.fromFirestore(Map<String, dynamic> data) {
    return UserData(uid: data['uid'] ?? '', email: data['email'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'email': email};
  }
}
