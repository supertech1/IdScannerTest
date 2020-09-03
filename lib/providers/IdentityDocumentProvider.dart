import 'dart:async';
import 'dart:convert';

import "package:flutter/foundation.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

import '../config.dart' as config;

class IdentityDocumentProvider with ChangeNotifier {
  final String token, userId;
  IdentityDocumentProvider(this.token, this.userId);
  Future<void> uploadDocumentData(dynamic userData) async {
    final url =
        "https://idscanner-98fbd.firebaseio.com/IdentityDocuments/$userId.json?auth=$token";
    await http.put(url, body: jsonEncode(userData));
  }
}
