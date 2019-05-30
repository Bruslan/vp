import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vp/models/chat_message_model.dart';
import 'models/comment_model.dart';
import 'models/feed_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'models/user_model.dart';

final Firestore _firestore = Firestore.instance;

Future<bool> checkUserNameExists(String username) async {
  bool exists = false;

  await _firestore
      .collection("users")
      .where("userName", isEqualTo: username)
      .getDocuments()
      .then((onValue) {
    if (onValue.documents.length > 0) {
      exists = true;
    } else {
      exists = false;
    }
  });
  return exists;
}

Future<String> uploadImage(File imageFile) async {
  var uuid = new Uuid().v1();
  StorageReference ref = FirebaseStorage.instance.ref().child("post_$uuid.jpg");
  StorageUploadTask uploadTask = ref.putFile(imageFile);

  String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
  return downloadUrl;
}

Future<List<String>> uploadImages(List<File> imageFiles) async {
  List<String> downloadURLs = [];
  for (File file in imageFiles) {
    var uuid = new Uuid().v1();
    StorageReference ref =
        FirebaseStorage.instance.ref().child("post_$uuid.jpg");
    StorageUploadTask uploadTask = ref.putFile(file);

    String downloadUrl =
        await (await uploadTask.onComplete).ref.getDownloadURL();
    downloadURLs.add(downloadUrl);
  }

  return downloadURLs;
}

Future<void> uploadFeed(FeedModel feed, DocumentReference reference) async {
  reference.setData(feed.toJson()).catchError((error) {
    print("error beim uploaden des Feeds");
  });
}

Future<void> uploadOptionsForFeed(
    String feedId, Map<String, dynamic> options) async {
  _firestore
      .collection("options")
      .document(feedId)
      .setData(options)
      .catchError((error) {
    print("error beim uploaden der Options");
  });
}

Future<void> userhasVoted(
    String feedId, String userId, String optionKey) async {
  await _firestore
      .collection("options")
      .document(feedId)
      .collection("voters")
      .document(userId)
      .setData({userId: optionKey});
}

Future<void> userhasDeletedVote(
    String feedId, String userId, String optionKey) async {
  await _firestore
      .collection("options")
      .document(feedId)
      .collection("voters")
      .document(userId)
      .delete();
}

Future<String> userHasVotedThisOption(String feedId, String userId) async {
  String votedOption = "";

  await _firestore
      .collection("options")
      .document(feedId)
      .collection("voters")
      .document(userId)
      .get()
      .then((snapshot) {
    if (snapshot != null) {
      if (snapshot.data != null) {
        votedOption = snapshot.data[userId];
      } else {
        votedOption = "";
      }
    }
  }).catchError((onError) {
    print(onError);
  });

  return votedOption;
}

Future<int> userHasVotedThisFeed(String feedId, String userId) async {
  int votedOption;

  await _firestore
      .collection("votes")
      .document(feedId)
      .collection("voters")
      .document(userId)
      .get()
      .then((snapshot) {
    if (snapshot != null) {
      if (snapshot.data != null) {
        votedOption = snapshot.data[userId];
      } else {
        votedOption = 0;
      }
    }
  }).catchError((onError) {
    print(onError);
  });

  return votedOption;
}

Future<void> userHasVotedFeed(String feedId, String userId, int voteKey) async {
  await _firestore
      .collection("votes")
      .document(feedId)
      .collection("voters")
      .document(userId)
      .setData({userId: voteKey});
}

Future<void> deleteUserVoteForFeed(String feedId, String userId) async {
  await _firestore
      .collection("votes")
      .document(feedId)
      .collection("voters")
      .document(userId)
      .delete();
}



Future<void> incrementFeedVote(String feedId, String voteString) async {
  await _firestore
      .collection("feeds")
      .document(feedId)
      .updateData({voteString: FieldValue.increment(1)});
}

Future<void> decrementFeedVote(String feedId, String voteString) async {
  await _firestore
      .collection("feeds")
      .document(feedId)
      .updateData({voteString: FieldValue.increment(-1)});
}

Future<void> incrementOptionVote(String feedId, String optionKey) async {
  await _firestore
      .collection("options")
      .document(feedId)
      .updateData({optionKey: FieldValue.increment(1)});
}

Future<void> decrementoptionVote(String feedId, String optionKey) async {
  await _firestore
      .collection("options")
      .document(feedId)
      .updateData({optionKey: FieldValue.increment(-1)});
}

Future<DocumentSnapshot> getOptionsForFeed(String feedId) async {
  DocumentSnapshot options;
  await _firestore
      .collection("options")
      .document(feedId)
      .get()
      .then((documentSnapshot) {
    options = documentSnapshot;
  }).catchError((error) {
    print(error);
  });

  return options;
}

Future<void> createUser(User user) async {
  DocumentReference reference = _firestore.collection("users").document();

  reference.setData(user.toJson()).catchError((error) {
    print("error beim erstellen des User");
  });
}

Future<List<FeedModel>> getFeeds(int feedCount, String collection,
    List<Map<String, dynamic>> tagNames) async {
  List<FeedModel> feeds = new List();
  String tagFilter = "";

  tagNames.forEach((f) {
    if (f["value"] == true) {
      tagFilter = f["name"];
      return;
    }
  });

  if (tagFilter == "") {
    await _firestore
        .collection(collection)
        .orderBy('timestamp', descending: true)
        .limit(feedCount)
        // .startAt([startAtDocument])
        .getDocuments()
        .then((snapshot) {
      snapshot.documents.forEach((document) {
        feeds.add(FeedModel.fromDocument(document));
      });
    });
  } else {
    await _firestore
        .collection(collection)
        .orderBy('timestamp', descending: true)
        .where("tag", isEqualTo: tagFilter)
        .limit(feedCount)
        // .startAt([startAtDocument])
        .getDocuments()
        .then((snapshot) {
      snapshot.documents.forEach((document) {
        feeds.add(FeedModel.fromDocument(document));
      });
    });
  }
  return feeds;
}


Future<List<FeedModel>> loadMoreFeeds(FeedModel lastFeed, int feedCount, String collection,
  List<Map<String, dynamic>> tagNames) async {
  List<FeedModel> feeds = new List();
  String tagFilter = "";

  tagNames.forEach((f) {
    if (f["value"] == true) {
      tagFilter = f["name"];
      return;
    }
  });

  if (tagFilter == "") {
    await _firestore
        .collection(collection)
        .orderBy('timestamp', descending: true)
        .startAfter([lastFeed.timestamp])
        .limit(feedCount)
        // .startAt([startAtDocument])
        .getDocuments()
        .then((snapshot) {
      snapshot.documents.forEach((document) {
        feeds.add(FeedModel.fromDocument(document));
      });
    });
  } else {
    await _firestore
        .collection(collection)
        .orderBy('timestamp', descending: true)
        .startAfter([lastFeed.timestamp])
        .where("tag", isEqualTo: tagFilter)
        .limit(feedCount)
        // .startAt([startAtDocument])
        .getDocuments()
        .then((snapshot) {
      snapshot.documents.forEach((document) {
        feeds.add(FeedModel.fromDocument(document));
      });
    });
  }
  return feeds;
}

Future<List<CommentModel>> getCommentsForFeed(String feedId) async {
  List<CommentModel> comments = new List();
  await _firestore
      .collection("comments")
      .document(feedId)
      .collection("comments")
      .getDocuments()
      .then((snapshot) {
    snapshot.documents.forEach((document) {
      comments.add(CommentModel.fromDocument(document));
    });
  }).catchError((error) {
    print(error);
  });

  return comments;
}

Future<void> _incrementCommentCount(String feedId) async {
  await _firestore
      .collection("feeds")
      .document(feedId)
      .updateData({"commentCount": FieldValue.increment(1)});
}

Future<void> createCommentForFeed(String feedId, CommentModel comment) async {
  return _firestore
      .collection("comments")
      .document(feedId)
      .collection("comments")
      .document()
      .setData(comment.toJson())
      .then((_) {
    _incrementCommentCount(feedId);
  });
}

Future<User> getUserProfile(String userId) async {
  User user;
  await _firestore
      .collection("users")
      // .startAt([startAtDocument])
      .document(userId)
      .get()
      .then((snapShot) {
    user = User.fromDocument(snapShot);
  }).catchError((error) {
    print("Error beim User fetch");
    print(error);
  });
  return user;
}

Future<void> updateProfilePicture(String userId, String downloadUrl) {
  return _firestore
      .collection("users")
      .document(userId)
      .updateData({"profileImageUrl": downloadUrl});
}

Future<void> removeDocument(String collection, String documentId) {
  return _firestore.collection(collection).document(documentId).delete();
}

Future<void> reportFeed(String collection, String postId, String reporter) {
  return _firestore
      .collection(collection)
      .document(postId)
      .setData({reporter: true});
}

Stream<QuerySnapshot> getChatStream(String conversationID) {
  return Firestore.instance
      .collection("messages")
      .document(conversationID)
      .collection("messages")
      .orderBy('timestamp', descending: true)
      .limit(20)
      .snapshots();
}

Stream<QuerySnapshot> getConversationStream(String userID) {
  return Firestore.instance
      .collection("conversations")
      .document(userID)
      .collection("conversations")
      .orderBy('timestamp', descending: true)
      .snapshots();
}

Future saveTextChat(ChatMessage chatMessage, String conversationId) {
  return _firestore
      .collection("messages")
      .document(conversationId)
      .collection("messages")
      .document()
      .setData(chatMessage.toJson());
}

Future<void> removeConversation(String userID, String collectionID) {
  return _firestore
      .collection("conversations")
      .document(userID)
      .collection("conversations")
      .document(collectionID)
      .delete();
}

saveConversation(String receiverID, String message, String senderID,
    String conversationID, User currentUser, User receiverUser) async {
  _firestore
      .collection("conversations")
      .document(senderID)
      .collection("conversations")
      .document(conversationID)
      .setData({
    'username': receiverUser.userName,
    'userId': senderID,
    'lastMessage': message,
    'receiverID': receiverID,
    'avatarUrl': receiverUser.profileImageUrl,
    'timestamp': new DateTime.now().toString(),
    'conversationId': conversationID
  }).then((onValue) {
    _firestore
        .collection("conversations")
        .document(receiverID)
        .collection("conversations")
        .document(conversationID)
        .setData({
      'username': currentUser.userName,
      'userId': receiverID,
      'lastMessage': message,
      'receiverID': senderID,
      'avatarUrl': currentUser.profileImageUrl,
      'timestamp': new DateTime.now().toString(),
      'conversationId': conversationID
    });
  });
}
