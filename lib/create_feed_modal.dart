import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vp/models/user_model.dart';
import 'dart:async';
import 'dart:io';
import 'package:vp/models/feed_model.dart';
import 'package:vp/location.dart';
import 'package:vp/filter_pins.dart';
import 'package:vp/horizontal_image_view.dart';
import 'package:vp/database_logic.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:vp/auth_class.dart';

import 'change_notifiers.dart';

class CreateFeedModal extends StatefulWidget {
  final BuildContext oldContext;
  CreateFeedModal({Key key, this.oldContext}) : super(key: key);

  _CreateFeedModal createState() => new _CreateFeedModal();
}

class _CreateFeedModal extends State<CreateFeedModal> {
  File file;
  List<File> imageFiles = [];
  bool tagIndicator = false;

  //Strings required to save address

  Map<String, double> currentLocation = new Map();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController locationController = new TextEditingController();
  final optionsControllers = List<TextEditingController>();
  List<Widget> optionsList = [];
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
    final refresher = Provider.of<FeedRefresh>(context);

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: new CupertinoNavigationBar(
            backgroundColor: Colors.white70,
            middle: const Text(
              'Create Post',
              style: const TextStyle(color: Colors.black),
            ),
            trailing: new FlatButton(
                onPressed: () {
                  if (posting == false) {
                    postImage(refresher);
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
          onVerticalDragCancel: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: new ListView(
            children: <Widget>[
              //  Hier komm ein TagPill rein
              Container(
                decoration: tagIndicator
                    ? BoxDecoration(
                        border: Border.all(width: 0.5, color: Colors.red))
                    : null,
                child: TagPills(
                  tags: tagsMap,
                  onTagsSet: (tags) {
                    tagsMap = tags;
                    setState(() {
                      tagIndicator = false;
                    });
                  },
                ),
              ),
              new PostForm(
                optionsControllers: optionsControllers,
                optionsList: optionsList,
                onImagePressed: () {
                  _selectImage();
                },
                onCameraPressed: () {
                  _takeAnImage();
                },
                imageFiles: imageFiles,
                descriptionController: descriptionController,
                locationController: locationController,
                loading: uploading,
              ),

              HorizontalImageViewList(
                imageFileList: imageFiles,
                onPhotoTapped: (index) {
                  setState(() {
                    imageFiles.removeAt(index);
                  });
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

    FirebaseUser currentUserFirebase = await Auth().getCurrentUser();
    User currentUser = await getUserProfile(currentUserFirebase.uid);
    final Firestore _firestore = Firestore.instance;
    DocumentReference reference = _firestore.collection("feeds").document();

    Map<String, dynamic> options = new Map();
    optionsControllers.forEach((f) {
      if (f.text != "") {
        options[f.text] = 0;
      }
    });

    FeedModel feed = new FeedModel(
        upVotes: 0,
        downVotes: 0,
        hasOptions: options.length != 0,
        userName: currentUser.userName,
        userId: currentUserFirebase.uid,
        imageUrls: imageUrls,
        textContent: descriptionController.text,
        tag: tag,
        timestamp: new DateTime.now().toString(),
        postId: reference.documentID);

    uploadFeed(feed, reference);
    if (options.length != 0) {
      uploadOptionsForFeed(reference.documentID, options);
    }
  }

  Future<Null> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 700,
      maxHeight: 700,
    );
    setState(() {
      imageFiles.add(croppedFile);
    });
  }

  _selectImage() async {
    File imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 1000, maxWidth: 1000);
    if (imageFile != null) {
      _cropImage(imageFile);
    }
  }

  _takeAnImage() async {
    File imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 700, maxWidth: 700);
    _cropImage(imageFile);
  }

  void clearImage() {
    setState(() {
      file = null;
    });
    Navigator.pop(context);
  }

  void postImage(FeedRefresh refresher) {
    String tagFilter = "";

    tagsMap.forEach((f) {
      if (f["value"] == true) {
        tagFilter = f["name"];
        return;
      }
    });

    if (tagFilter == "") {
      setState(() {
        tagIndicator = true;
      });
    }

    if (imageFiles.length != 0 && tagFilter != "") {
      posting = true;
      setState(() {
        uploading = true;
      });
      // compressImage();
      refresher.mustRefresh();
      Navigator.pop(context);
      uploadImages(imageFiles).then((List<String> imageURLs) {
        postToFireStore(imageURLs, tagFilter);
      }).catchError((onError) {
        print("ein Error beim Upload vom Feed");
        print(onError);
      }).then((_) {
        refresher.hasRefreshed();
        if (mounted) {
          setState(() {
            imageFiles.clear();
            uploading = false;
            
          });
        }
      }).catchError((onError) {
        print("Error beim upload von Image");
        print(onError);
      });
    } else {
      if (descriptionController.text != "" && tagFilter != "") {
        posting = true;
        postToFireStore(null, tagFilter);

        refresher.mustRefresh();
        Navigator.pop(context);
      }
    }
  }
}

class PostForm extends StatefulWidget {
  final PostFormCallback onImagePressed;
  final PostFormCallback onCameraPressed;
  final List<Widget> optionsList;
  final imageFiles;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final List<TextEditingController> optionsControllers;
  final bool loading;

  PostForm(
      {this.onCameraPressed,
      this.optionsControllers,
      this.onImagePressed,
      this.optionsList,
      this.imageFiles,
      this.descriptionController,
      this.loading,
      this.locationController});

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  Widget _buildOptions() {
    return Column(children: widget.optionsList);
  }

  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        widget.loading
            ? new LinearProgressIndicator()
            : new Padding(padding: new EdgeInsets.only(top: 0.0)),
        Column(
          children: <Widget>[
            new Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: new TextField(
                maxLines: 5,
                controller: widget.descriptionController,
                decoration: new InputDecoration(
                    hintText: "Write a caption...", border: InputBorder.none),
              ),
            ),
            _buildOptions(),
            _buildOptionButtons()
          ],
        ),
        new Divider(),
        new ListTile(
          leading: new IconButton(
              onPressed: () async {
                Address first = await getUserLocation();
                widget.locationController.text =
                    first.countryName + ", " + first.locality;
              },
              icon: Icon(Icons.pin_drop)),
          title: new Container(
            width: 250.0,
            child: new TextField(
              controller: widget.locationController,
              decoration: new InputDecoration(
                  hintText: "Where was this photo taken?",
                  border: InputBorder.none),
            ),
          ),
        )
      ],
    );
  }

  Row _buildOptionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        FlatButton(
          onPressed: () {
            TextEditingController optionsController =
                new TextEditingController();
            widget.optionsControllers.add(optionsController);

            widget.optionsList.add(OptionPill(
              optionController: optionsController,
              optionNr: widget.optionsList.length + 1,
            ));
            setState(() {});
          },
          child: Row(
            children: <Widget>[
              Icon(Icons.add),
              Text("Add Options"),
            ],
          ),
        ),
        FlatButton(
            onPressed: widget.onCameraPressed, child: Icon(Icons.camera_alt)),
        FlatButton(onPressed: widget.onImagePressed, child: Icon(Icons.image)),
        // hier anonym Button
      ],
    );
  }
}

class OptionPill extends StatelessWidget {
  final int optionNr;
  final TextEditingController optionController;
  const OptionPill({Key key, this.optionNr, this.optionController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          const Radius.circular(30.0),
        ),
        color: Colors.white,
      ),

      // width: 250.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width - 100,
            child: new TextField(
              controller: optionController,
              autofocus: true,
              // controller: locationController,
              decoration: new InputDecoration(
                  hintText: "Option " + optionNr.toString(),
                  border: InputBorder.none),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.remove_circle),
          )
        ],
      ),
    );
  }
}

typedef PostFormCallback = void Function();
