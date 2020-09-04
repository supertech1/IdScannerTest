import 'package:flutter/material.dart';

class DetailedDocument extends StatelessWidget {
  const DetailedDocument({
    Key key,
    @required this.faceImage,
    @required this.docType,
    @required Widget resultContainer,
    @required this.fullDocumentFrontImage,
  })  : _resultContainer = resultContainer,
        super(key: key);

  final Widget faceImage;
  final String docType;
  final Widget _resultContainer;
  final Widget fullDocumentFrontImage;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        Row(
          children: [
            faceImage,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  "[ $docType ]",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ),
            )
          ],
        ),
        _resultContainer,
        fullDocumentFrontImage,
      ],
    );
  }
}
