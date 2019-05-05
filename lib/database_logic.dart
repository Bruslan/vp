import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'feed_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'user_model.dart';

final Firestore _firestore = Firestore.instance;

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

Future<void> uploadFeed(FeedModel feed) async {
  DocumentReference reference = _firestore.collection("feeds").document();

  reference.setData(feed.toJson()).catchError((error) {
    print("error beim uploaden des Feeds");
  });
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
