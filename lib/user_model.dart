import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userName;
  final String profileImageUrl;
  final String userId;

  User({
    this.userId,
    this.userName,
    this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        userName: json["userName"],
        profileImageUrl: json["profileImageUrl"],
        userId: json['userId']);
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    return User.fromJson(doc.data);
  }

  Map<String, Object> toJson() {
    return {
      'userName': userName,
      'profileImageUrl': profileImageUrl,
      'userId': userId
    };
  }
}
