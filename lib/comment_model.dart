import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String userName;
  final String imageUrl;
  final String textContent;
  final String userId;
  final String postId;
  final String timestamp;
  final String imageProfileUrl;

  CommentModel(
      {this.imageUrl,
      this.imageProfileUrl,
      this.userName,
      this.textContent,
      this.userId,
      this.postId,
      this.timestamp});

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
        postId: json["postId"],
        userName: json['userName'],
        imageUrl: json['imageUrls'],
        textContent: json['textContent'],
        userId: json['userId'],
        imageProfileUrl: json["imageProfileUrl"],
        timestamp: json["timestamp"]);
  }

  factory CommentModel.fromDocument(DocumentSnapshot doc) {
    return CommentModel.fromJson(doc.data);
  }

  Map<String, Object> toJson() {
    return {
      'userName': userName,
      'imageUrls': imageUrl,
      'textContent': textContent,
      "userId": userId,
      "postId": postId,
      "timestamp": timestamp,
      "imageProfileUrl": imageProfileUrl
    };
  }
}
