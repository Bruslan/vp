import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String ownerId;
  final String message;
  final String timestamp;


  ChatMessage(
      {this.ownerId,
      this.message,
      this.timestamp,
});

  Map<String, Object> toJson() {
    return {
      'timestamp': timestamp,
      'ownerId': ownerId,
      'message': message,

    };
  }

  factory ChatMessage.fromJson(Map<String, Object> doc) {
    ChatMessage message = new ChatMessage(
        ownerId: doc['ownerId'],
        message: doc['message'],
        timestamp: doc['timestamp'],
);
        
    return message;
  }

  factory ChatMessage.fromDocument(DocumentSnapshot doc) {
    return ChatMessage.fromJson(doc.data);
  }
}
