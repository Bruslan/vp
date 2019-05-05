
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';




typedef TagsCallback = void Function(bool selected);
typedef TagPillsCallback = void Function(List<Map<String, dynamic>> newTags);

class TagPills extends StatefulWidget {
  final TagPillsCallback onTagsSet;
  final List<Map<String, dynamic>> tags;

  const TagPills({Key key, this.onTagsSet, this.tags}) : super(key: key);

  @override
  _TagPillsState createState() => _TagPillsState(tags, onTagsSet);
}

class _TagPillsState extends State<TagPills> {
  final TagPillsCallback onTagsSet;

  final List<Map<String, dynamic>> tags;
 List<Map<String, dynamic>> tagsCache;
  _TagPillsState(this.tags, this.onTagsSet);

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    
  }

 

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        width: MediaQuery.of(context).size.width,
        height: 30,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: tags.length,
          itemBuilder: (context, int index) {
            return GestureDetector(
              onTap: () {
                bool cache = tags[index]["value"];
                tags.forEach((f) => f["value"] = false);

                tags[index]["value"] = !cache;
                onTagsSet(tags);
                setState(() {});
              },
              child: TagIndicator(
                text: tags[index]["name"],
                selected: tags[index]["value"],
              ),
            );
          },
        ));
  }
}
class TagIndicator extends StatelessWidget {
  final bool selected;
  final String text;
  const TagIndicator({Key key, this.selected, this.text}) : super(key: key);
  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: selected ? Colors.grey : Colors.grey.shade100,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey,
              ),
            )),
      ),
    );
  }
}
