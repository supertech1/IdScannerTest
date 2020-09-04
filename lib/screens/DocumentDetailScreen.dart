import 'dart:convert';

import 'package:IdScannerTest/providers/AuthProvider.dart';
import 'package:blinkid_flutter/microblink_scanner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/scan_doc_screen_widgets/doc_image.dart';
import '../widgets/scan_doc_screen_widgets/detailed_document.dart';

class DocumentDetail extends StatelessWidget {
  final dynamic documentData;
  DocumentDetail(this.documentData);

  Widget getIdResultContainer(dynamic result) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildResult(result.fullName, "fullName", "FULL NAME"),
          buildDateResult(result.dateOfBirth, "dateOfBirth", "DATE OF BIRTH"),
          buildResult(result.age.toString(), "age", "AGE"),
          buildResult(result.sex, "sex", "SEX"),
          buildResult(result.address, "address", "ADDRESS"),
          buildResult(result.maritalStatus, "maritalStatus", "Marital Status"),
          buildDateResult(result.dateOfIssue, "dateOfIssue", "DATE OF ISSUE"),
          buildDateResult(
              result.dateOfExpiry, "dateOfExpiry", "DATE OF EXPIRY"),
          buildResult(
              result.documentNumber, "documentNumber", "DOCUMENT NUMBER"),
          buildResult(
              result.issuingAuthority, "issuingAuthority", "ISSUING AUTHORITY"),
          buildResult(result.nationality, "nationality", "NATIONALITY"),
          buildResult(result.profession, "profession", "PROFESSION"),
          buildResult(result.race, "race", "RACE"),
          buildResult(result.religion, "religion", "RELIGION"),
        ],
      ),
    );
  }

  Widget buildResult(String result, String key, String propertyName) {
    if (result == null || result.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            propertyName,
          ),
          SizedBox(
            height: 7,
          ),
          Text(
            result,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            height: 1,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget buildDateResult(dynamic result, String key, String propertyName) {
    if (result == null) {
      return Container();
    }
    String date = "";

    if (result is Date) {
      date = "${result.day} - ${result.month} - ${result.year}";
    } else {
      date = result;
    }

    return buildResult(date, key, propertyName);
  }

  @override
  Widget build(BuildContext context) {
    Widget _resultContainer = getIdResultContainer(documentData);

    String _fullDocumentFrontImageBase64 = documentData.fullDocumentFrontImage;
    String _faceImageBase64 = documentData.faceImage;
    String docType = documentData.docType;

    Widget fullDocumentFrontImage = DocImage(
      imageBase64: _fullDocumentFrontImageBase64,
      imageTag: "Document Front Side :",
      width: 350,
      height: 180,
    );

    Widget faceImage = DocImage(
      imageBase64: _faceImageBase64,
      imageTag: "",
      width: 100,
      height: 150,
    );

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Document Detail")),
        actions: [
          DropdownButton(
            underline: Container(),
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: [
                      Icon(Icons.lock_open),
                      SizedBox(
                        width: 8,
                      ),
                      Text("Logout")
                    ],
                  ),
                ),
                value: "logout",
              ),
            ],
            onChanged: (itemIdentifier) {
              if (itemIdentifier == "logout") {
                Provider.of<AuthProvider>(context, listen: false).logout();
              }
            },
          ),
        ],
      ),
      body: DetailedDocument(
        faceImage: faceImage,
        docType: docType,
        resultContainer: _resultContainer,
        fullDocumentFrontImage: fullDocumentFrontImage,
      ),
    );
  }
}
