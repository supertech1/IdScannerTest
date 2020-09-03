import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/AuthProvider.dart';
import '../widgets/auth/AuthForm.dart';

import '../models/http_exception.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  String _errMsg = "";

  void _authenticate(String username, String password, bool isLogin) async {
    setState(() {
      _isLoading = true;
      _errMsg = "";
    });

    try {
      if (isLogin) {
        //signin mode
        await Provider.of<AuthProvider>(context, listen: false)
            .signIn(username, password);
      } else {
        //signup mode
        await Provider.of<AuthProvider>(context, listen: false)
            .signUp(username, password);
      }
    } on HttpException catch (err) {
      if (err.toString().contains("EMAIL_EXISTS")) {
        _errMsg = "This email address is already registered";
      } else if (err.toString().contains("INVALID_EMAIL")) {
        _errMsg = "This email address is not valid";
      } else if (err.toString().contains("WEAK_PASSWORD")) {
        _errMsg = "The password is too weak";
      } else if (err.toString().contains("EMAIL_NOT_FOUND")) {
        _errMsg = "No user with the email found";
      } else if (err.toString().contains("INVALID_PASSWORD")) {
        _errMsg = "Invalid Credentials";
      } else {
        _errMsg = "Authentication Failed";
      }

      print(err);
    } catch (err) {
      _errMsg = "Could not authenticate, please try again later";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).accentColor,
                Theme.of(context).primaryColor
              ]),
        ),
        child: AuthForm(
            submitAuth: _authenticate, isLoading: _isLoading, errMsg: _errMsg),
      ),
    );
  }
}
