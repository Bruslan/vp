import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'feed_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

final Firestore _firestore = Firestore.instance;



Future<String> uploadImage(File imageFile) async {
  var uuid = new Uuid().v1();
  StorageReference ref = FirebaseStorage.instance.ref().child("post_$uuid.jpg");
  StorageUploadTask uploadTask = ref.putFile(imageFile);

  String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
  return downloadUrl;
}

Future<List<String>> uploadImages(List<File> imageFiles) async {

  List<String> downloadURLs =[];
  for (File file in imageFiles) {

  var uuid = new Uuid().v1();
  StorageReference ref = FirebaseStorage.instance.ref().child("post_$uuid.jpg");
  StorageUploadTask uploadTask = ref.putFile(file);

  String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
  downloadURLs.add(downloadUrl);

  }

  return downloadURLs;
}

Future<void> uploadFeed(FeedModel feed) async {

DocumentReference reference = _firestore.collection("feeds").document();

reference.setData(feed.toJson()).catchError((error){
print("error beim uploaden des Feeds");
});
}

