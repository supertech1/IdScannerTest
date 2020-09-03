import "dart:convert";
import 'package:flutter/material.dart';

class DocImage extends StatelessWidget {
  String imageBase64, imageTag;
  double width, height;
  DocImage({this.imageBase64, this.imageTag, this.width, this.height});
  @override
  Widget build(BuildContext context) {
    if (imageBase64 != null && imageBase64 != "") {
      return Column(
        children: <Widget>[
          Text("$imageTag"),
          Image.memory(
            Base64Decoder().convert(imageBase64),
            height: height,
            width: width,
          )
        ],
      );
    }
    return Container();
  }
}
