import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'feed_model.dart';
import 'location.dart';
import 'filter_pins.dart';
import 'horizontal_image_view.dart';
import 'database_logic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';

class CreateFeedModal extends StatefulWidget {
  final String currentUser;

  CreateFeedModal({Key key, @required this.currentUser}) : super(key: key);

  _CreateFeedModal createState() => new _CreateFeedModal();
}

class _CreateFeedModal extends State<CreateFeedModal> {
  File file;
  List<File> imageFiles = [];
  //Strings required to save address

  Map<String, double> currentLocation = new Map();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController locationController = new TextEditingController();

  bool uploading = false;
  bool promted = false;
  bool posting = false;
  bool anonym = false;
  List<Map<String, dynamic>> tagsMap = [
    {
      "name": "VayGirls",
      "value": false,
    },
    {"name": "VayBoys", "value": false},
    {"name": "VayMusic", "value": false},
    {"name": "VayShop", "value": false},
    {"name": "VayBöhum", "value": false},
  ];

  @override
  initState() {
    //method to call location
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: new CupertinoNavigationBar(
            backgroundColor: Colors.white70,
            middle: const Text(
              'Post to',
              style: const TextStyle(color: Colors.black),
            ),
            trailing: new FlatButton(
                onPressed: () {
                  if (posting == false) {
                    postImage();
                  }
                },
                child: new Text(
                  "Post",
                  style: new TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ))),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
        onVerticalDragCancel: (){
          FocusScope.of(context).requestFocus(new FocusNode());
        },
          child: new ListView(
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      setState(() {
                        anonym = !anonym;
                      });
                    },
                    icon: Icon(
                      Icons.security,
                      color: anonym ? Colors.blue : Colors.grey,
                    ),
                  )
                ],
              ),

              HorizontalImageViewList(
                imageFileList: imageFiles,
                onPhotoTapped: (index) {
                  setState(() {
                    imageFiles.removeAt(index);
                  });
                },
              ),

              new PostForm(
                onImagePressed: () {
                  _selectImage();
                },
                imageFiles: imageFiles,
                descriptionController: descriptionController,
                locationController: locationController,
                loading: uploading,
              ),
              new Divider(),
              //  Hier komm ein TagPill rein
              TagPills(
                tags: tagsMap,
                onTagsSet: (tags) {
                  tagsMap = tags;
                },
              ),
            ],
          ),
        ));
  }

  //method to build buttons with location.
  buildLocationButton(String locationName) {
    if (locationName != null ?? locationName.isNotEmpty) {
      return InkWell(
        onTap: () {
          locationController.text = locationName;
        },
        child: Center(
          child: new Container(
            //width: 100.0,
            height: 30.0,
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            margin: EdgeInsets.only(right: 3.0, left: 3.0),
            decoration: new BoxDecoration(
              color: Colors.grey[200],
              borderRadius: new BorderRadius.circular(5.0),
            ),
            child: new Center(
              child: new Text(
                locationName,
                style: new TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  void postToFireStore(List<String> imageUrls, String tag) async {
// FirebaseUser user = await FirebaseAuth.instance.currentUser();

    FeedModel feed = new FeedModel(
      userName: "Ruslan",
      userId: "12345",
      imageUrls: imageUrls,
      textContent: descriptionController.text,
      tag: tag,
      timestamp: new DateTime.now().toString(),
    );

    uploadFeed(feed);
  }

  Future<Null> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 400,
      maxHeight: 400,
    );
    setState(() {
      imageFiles.add(croppedFile);
    });
  }

  _selectImage() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return new SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            new SimpleDialogOption(
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  File imageFile = await ImagePicker.pickImage(
                      source: ImageSource.camera,
                      maxHeight: 400,
                      maxWidth: 400);
                  _cropImage(imageFile);
                }),
            new SimpleDialogOption(
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  File imageFile = await ImagePicker.pickImage(
                      source: ImageSource.gallery,
                      maxHeight: 400,
                      maxWidth: 400);

                  _cropImage(imageFile);
                }),
            new SimpleDialogOption(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void clearImage() {
    setState(() {
      file = null;
    });
    Navigator.pop(context);
  }

  void postImage() {
    String tagFilter = "";

    tagsMap.forEach((f) {
      if (f["value"] == true) {
        tagFilter = f["name"];
        return;
      }
    });

    if (imageFiles.length != 0 && tagFilter != "") {
      posting = true;
      setState(() {
        uploading = true;
      });
      // compressImage();

      uploadImages(imageFiles).then((List<String> imageURLs) {
        postToFireStore(imageURLs, tagFilter);
      }).catchError((onError) {
        print("ein Error beim Upload vom Feed");
        print(onError);
      }).then((_) {
        setState(() {
          imageFiles.clear();
          uploading = false;
        });
        Navigator.pop(context);
      }).catchError((onError) {
        print("Error beim upload von Image");
        print(onError);
      });
    } else {
      if (descriptionController.text != "" && tagFilter != "") {
        posting = true;
        postToFireStore(null, tagFilter);
        Navigator.pop(context);
      }
    }
  }
}

class PostForm extends StatelessWidget {
  final PostFormCallback onImagePressed;
  final imageFiles;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final bool loading;

  PostForm(
      {this.onImagePressed,
      this.imageFiles,
      this.descriptionController,
      this.loading,
      this.locationController});

  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        loading
            ? new LinearProgressIndicator()
            : new Padding(padding: new EdgeInsets.only(top: 0.0)),
        new Divider(),
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            new Container(
              width: 250.0,
              child: new TextField(
                maxLines: 5,
                controller: descriptionController,
                decoration: new InputDecoration(
                    hintText: "Write a caption...", border: InputBorder.none),
              ),
            ),
            IconButton(onPressed: onImagePressed, icon: Icon(Icons.add_a_photo))
          ],
        ),
        new Divider(),
        new ListTile(
          leading: new IconButton(
              onPressed: () async {
                Address first = await getUserLocation();
                locationController.text =
                    first.countryName + ", " + first.locality;
              },
              icon: Icon(Icons.pin_drop)),
          title: new Container(
            width: 250.0,
            child: new TextField(
              controller: locationController,
              decoration: new InputDecoration(
                  hintText: "Where was this photo taken?",
                  border: InputBorder.none),
            ),
          ),
        )
      ],
    );
  }
}

typedef PostFormCallback = void Function();
