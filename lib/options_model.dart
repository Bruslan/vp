import 'package:cloud_firestore/cloud_firestore.dart';

class FeedModel {
  final String userName;
  final List<dynamic> imageUrls;
  final String textContent;
  final String userId;
  final String tag;
  final String location;
  final String postId;
  final String timestamp;
  final List<dynamic> options;
  final int commentCount;

  FeedModel(
      {this.commentCount,
      this.options,
      this.userName,
      this.textContent,
      this.imageUrls,
      this.userId,
      this.postId,
      this.location,
      this.tag,
      this.timestamp});

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    return FeedModel(
        postId: json["postId"],
        commentCount: json["commentCount"],
        location: json["location"],
        tag: json["tag"],
        userName: json['userName'],
        imageUrls: json['imageUrls'] == null ? [] : json['imageUrls'],
        textContent: json['textContent'],
        userId: json['userId'],
        options: json["options"] == null ? [] : json["options"],
        timestamp: json["timestamp"]);
  }

  factory FeedModel.fromDocument(DocumentSnapshot doc) {
    return FeedModel.fromJson(doc.data);
  }

  Map<String, Object> toJson() {
    return {
      "commentCount": commentCount,
      'userName': userName,
      'imageUrls': imageUrls,
      'textContent': textContent,
      "userId": userId,
      "tag": tag,
      "location": location,
      "postId": postId,
      "timestamp": timestamp,
      "options": options
    };
  }
}