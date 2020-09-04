import 'dart:async';
import 'dart:convert';

import "package:flutter/foundation.dart";
import 'package:http/http.dart' as http;

import '../models/IdentityDocumentModel.dart';

class IdentityDocumentProvider with ChangeNotifier {
  final String token, userId;
  IdentityDocumentProvider(this.token, this.userId);
  List<IdentityDocumentModel> documents = [];
  Future<void> uploadDocumentData(dynamic userData) async {
    final url =
        "https://idscanner-98fbd.firebaseio.com/IdentityDocuments/$userId.json?auth=$token";
    await http.post(url, body: jsonEncode(userData));
    notifyListeners();
  }

  Future<void> fetchDocumentData() async {
    documents = [];
    Map myMap = Map();

    final url =
        "https://idscanner-98fbd.firebaseio.com/IdentityDocuments/$userId.json?auth=$token";
    final response = await http.get(url);
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    if (responseData == null) {
      return;
    }

    responseData.forEach((docKey, docData) {
      for (var i = 0; i < docData.length; i++) {
        docData[i].forEach((key, value) {
          myMap["$key"] = value;
        });
      }
      IdentityDocumentModel identityDocument = IdentityDocumentModel(myMap);
      documents.add(identityDocument);
      myMap.clear();
    });
    print(documents);
    notifyListeners();
  }
}
