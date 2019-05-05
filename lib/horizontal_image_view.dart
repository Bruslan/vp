import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef DeletePhotoClicked = void Function(int index);

class HorizontalImageViewList extends StatelessWidget {
  final List<File> imageFileList;
  final DeletePhotoClicked onPhotoTapped;

  const HorizontalImageViewList(
      {Key key, this.imageFileList, this.onPhotoTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _selectImage(int index) async {
      return showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!

        builder: (BuildContext context) {
          return new SimpleDialog(
            title: const Text('Image Options'),
            children: <Widget>[
              new SimpleDialogOption(
                  child: const Text('Delete?'),
                  onPressed: () {
                    onPhotoTapped(index);
                    Navigator.pop(context);
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

    return Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        width: MediaQuery.of(context).size.width,
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: imageFileList.length,
          itemBuilder: (context, int index) {
            return new Container(
              margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
              height: 50.0,
              width: 50.0,
              child: new AspectRatio(
                aspectRatio: 487 / 451,
                child: GestureDetector(
                  onTap: () {
                    _selectImage(index);
                  },
                  child: new Container(
                    decoration: new BoxDecoration(
                        image: new DecorationImage(
                      fit: BoxFit.fitHeight,
                      alignment: FractionalOffset.topCenter,
                      image: new FileImage(imageFileList[index]),
                    )),
                  ),
                ),
              ),
            );
          },
        ));
  }
}
