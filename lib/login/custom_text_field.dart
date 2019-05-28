import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final Color baseColor;
  final Color borderColor;
  final Color errorColor;
  final TextInputType inputType;
  final bool obscureText;
  final Function validator;
  final Function onChanged;

  CustomTextField(
      {this.hint,
      this.controller,
      this.onChanged,
      this.baseColor,
      this.borderColor,
      this.errorColor,
      this.inputType = TextInputType.text,
      this.obscureText = false,
      this.validator});

  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  Color currentColor;
  bool error = false;

  @override
  void initState() {
    super.initState();
    currentColor = widget.borderColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Stack(
        children: <Widget>[
          TextField(
            obscureText: widget.obscureText,
            onChanged: (text) {
              if (widget.onChanged != null) {
                widget.onChanged(text);
              }
              setState(() {
                if (!widget.validator(text) || text.length == 0) {
                  currentColor = widget.errorColor;
                  error = true;
                } else {
                  currentColor = widget.baseColor;
                  error = false;
                }
              });
            },
            //keyboardType: widget.inputType,
            controller: widget.controller,
            decoration: InputDecoration(
              hintStyle: TextStyle(
                color: widget.baseColor,
                fontFamily: "OpenSans",
                fontWeight: FontWeight.w300,
              ),
              border: InputBorder.none,
              hintText: widget.hint,
            ),
          ),

          error ? Positioned(right:10, child: Text("!", style: TextStyle(color: Colors.red),),)
          : SizedBox()
        ],
      ),
    );
  }
}
