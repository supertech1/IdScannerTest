import 'dart:async';
import 'dart:convert';

import "package:flutter/foundation.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import '../models/IdentityDocumentModel.dart';

import '../config.dart' as config;

class IdentityDocumentProvider with ChangeNotifier {
  final String token, userId;
  IdentityDocumentProvider(this.token, this.userId);
  Future<void> uploadDocumentData(dynamic userData) async {
    final url =
        "https://idscanner-98fbd.firebaseio.com/IdentityDocuments/$userId.json?auth=$token";
    await http.put(url, body: jsonEncode(userData));
  }

  Future<IdentityDocumentModel> fetchDocumentData() async {
    Map myMap = Map();

    final url =
        "https://idscanner-98fbd.firebaseio.com/IdentityDocuments/$userId.json?auth=$token";
    final response = await http.get(url);
    final responseData = jsonDecode(response.body) as List<dynamic>;
    if (responseData == null || responseData.isEmpty) {
      return null;
    }

    for (var i = 0; i < responseData.length; i++) {
      responseData[i].forEach((key, value) {
        print(key);
        print(value);
        myMap["$key"] = value;
      });
    }

    IdentityDocumentModel identityDocument = IdentityDocumentModel(myMap);
    return identityDocument;
  }
}
