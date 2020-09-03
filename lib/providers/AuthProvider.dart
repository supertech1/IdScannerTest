import 'dart:async';
import 'dart:convert';

import "package:flutter/foundation.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

import '../config.dart' as config;

class AuthProvider with ChangeNotifier {
  String _token, _userId;
  DateTime _expiryDate;
  Timer _authTimer;

  bool get isAuthenticated {
    if (token == null) {
      return false; //not authenticated
    }
    return true; //authenticated
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    if (_userId != null) {
      return _userId;
    }
    return null;
  }

  Future<void> signUp(String email, String password) async {
    const url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${config.apiKey}";
    final response = await http.post(
      url,
      body: jsonEncode({
        "email": email,
        "password": password,
        "returnSecureToken": true,
      }),
    );
    final responseData = jsonDecode(response.body);
    if (responseData["error"] != null) {
      throw HttpException(responseData["error"]["message"]);
    }
    _token = responseData["idToken"];
    _userId = responseData["localId"];
    _expiryDate = DateTime.now().add(
      Duration(seconds: int.parse(responseData["expiresIn"])),
    );
    autoLogout();

    final prefs = await SharedPreferences.getInstance();
    final userData = jsonEncode({
      "token": _token,
      "userId": _userId,
      "expiryDate": _expiryDate.toIso8601String()
    });
    prefs.setString("userData", userData);

    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    const url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${config.apiKey}";
    final response = await http.post(
      url,
      body: jsonEncode({
        "email": email,
        "password": password,
        "returnSecureToken": true,
      }),
    );
    final responseData = jsonDecode(response.body);
    if (responseData["error"] != null) {
      throw HttpException(responseData["error"]["message"]);
    }
    _token = responseData["idToken"];
    _userId = responseData["localId"];
    _expiryDate = DateTime.now().add(
      Duration(seconds: int.parse(responseData["expiresIn"])),
    );
    autoLogout();
    final prefs = await SharedPreferences.getInstance();
    final userData = jsonEncode({
      "token": _token,
      "userId": _userId,
      "expiryDate": _expiryDate.toIso8601String()
    });
    prefs.setString("userData", userData);
    notifyListeners();
  }

  void logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("userData");
    notifyListeners();
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("userData")) {
      return false;
    }

    final userData =
        jsonDecode(prefs.getString("userData")) as Map<String, Object>;
    final expiryDate = DateTime.parse(userData["expiryDate"]);

    if (expiryDate.isBefore(DateTime.now())) {
      return false; //token has expired
    }

    _token = userData["token"];

    _userId = userData["userId"];

    _expiryDate = DateTime.parse(userData["expiryDate"]);

    autoLogout();
    notifyListeners();
    return true;
  }

  void autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
