import 'package:IdScannerTest/screens/DocumentDetailScreen.dart';
import 'package:flutter/material.dart';
import '../../widgets/scan_doc_screen_widgets/doc_image.dart';
import '../../screens/DocumentDetailScreen.dart';

class SingleDocument extends StatelessWidget {
  const SingleDocument({
    @required this.docData,
  });

  final dynamic docData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      color: Colors.grey.withOpacity(0.6),
      child: Row(
        children: [
          DocImage(
            imageBase64: docData.faceImage,
            imageTag: "",
            width: 80,
            height: 120,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "ID Type:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "[ ${docData.docType} ]",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).primaryColor),
                ),
                SizedBox(height: 5),
                RaisedButton(
                  child: Text("View Details"),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                DocumentDetail(docData)));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
