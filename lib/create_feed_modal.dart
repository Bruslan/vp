import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as Math;
import 'package:image/image.dart' as Im;

import 'location.dart';

import 'filter_pins.dart';



class CreateFeedModal extends StatefulWidget {
  final String currentUser;

  CreateFeedModal({Key key, @required this.currentUser}) : super(key: key);

  _CreateFeedModal createState() => new _CreateFeedModal();
}

class _CreateFeedModal extends State<CreateFeedModal> {
  File file;
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
          // leading: new IconButton(
          //     icon: new Icon(Icons.arrow_back, color: Colors.black),
          //     onPressed: clearImage),
          middle: const Text(
            'Post to',
            style: const TextStyle(color: Colors.black),
          ),
          trailing: 
            new FlatButton(
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
                ))
          
        ),
        body: new ListView(
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
            new PostForm(
              onImagePressed: () {
                _selectImage();
              },
              imageFile: file,
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
                  setState(() {
                    file = imageFile;
                  });
                }),
            new SimpleDialogOption(
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  File imageFile = await ImagePicker.pickImage(
                      source: ImageSource.gallery,
                      maxHeight: 400,
                      maxWidth: 400);

                  setState(() {
                    file = imageFile;
                  });
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

  void compressImage() async {
    print('starting compression');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = new Math.Random().nextInt(10000);

    Im.Image image = Im.decodeImage(file.readAsBytesSync());
    Im.copyResize(image, 500);

//    image.format = Im.Image.RGBA;
//    Im.Image newim = Im.remapColors(image, alpha: Im.LUMINANCE);

    var newim2 = new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 20));

    setState(() {
      file = newim2;
    });
    print('done');
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

    if (file != null && tagFilter != "") {
      posting = true;
      setState(() {
        uploading = true;
      });
      // compressImage();
      uploadImage(file).then((String data) {
        postToFireStore(
 );
      }).catchError((onError) {
        print("ein Error beim Upload");
        print(onError);
      }).then((_) {
        setState(() {
          file = null;
          uploading = false;
        });
        Navigator.pop(context);
      }).catchError((onError) {
        print("beim Speichern des LInks vom Image");
        print(onError);
      });
    } else {
      if (descriptionController.text != "" && tagFilter != "") {
        posting = true;
        postToFireStore(
       );

        Navigator.pop(context);
      }
    }
  }
}

class PostForm extends StatelessWidget {
  final PostFormCallback onImagePressed;
  final imageFile;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final bool loading;

  PostForm(
      {this.onImagePressed,
      this.imageFile,
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
            GestureDetector(
              onTap: () {
                onImagePressed();
              },
              child: new Container(
                height: 45.0,
                width: 45.0,
                child: new AspectRatio(
                  aspectRatio: 487 / 451,
                  child: new Container(
                    decoration: new BoxDecoration(
                        image: new DecorationImage(
                      fit: BoxFit.fill,
                      alignment: FractionalOffset.topCenter,
                      image: imageFile == null
                          ? ExactAssetImage("images/placeholder.png")
                          : new FileImage(imageFile),
                    )),
                  ),
                ),
              ),
            ),
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

Future<String> uploadImage(var imageFile) async {
  // var uuid = new Uuid().v1();
  // StorageReference ref = FirebaseStorage.instance.ref().child("post_$uuid.jpg");
  // StorageUploadTask uploadTask = ref.putFile(imageFile);

  // String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
  // return downloadUrl;
}

void postToFireStore(
    ) {

}

typedef PostFormCallback = void Function();
