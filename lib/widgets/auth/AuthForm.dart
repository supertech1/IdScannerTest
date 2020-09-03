import 'package:IdScannerTest/providers/AuthProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthForm extends StatefulWidget {
  final Function(String email, String password, bool isLoading) submitAuth;
  final isLoading;
  final errMsg;
  AuthForm({this.submitAuth, this.isLoading, this.errMsg});
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  String _userEmail = "";
  String _userPassword = "";

  void _submitForm() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context)
        .unfocus(); //remove the keyboard and make all form field back to unfocus
    if (!isValid) {
      return;
    }
    _formKey.currentState.save();
    widget.submitAuth(_userEmail, _userPassword, _isLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isLogin ? "Login to your account" : "Create an account",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).accentColor),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  key: ValueKey("email"),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) {
                    _userEmail = value;
                  },
                  validator: (value) {
                    if (value.isEmpty || !value.contains("@")) {
                      return "Enter a valid email address";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Email Address",
                  ),
                ),
                TextFormField(
                  key: ValueKey("password"),
                  obscureText: true,
                  controller: _passwordController,
                  onSaved: (value) {
                    _userPassword = value;
                  },
                  validator: (value) {
                    if (value.isEmpty || value.length < 7) {
                      return "Password must be at least 7 characters long.";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Password",
                  ),
                ),
                if (!_isLogin)
                  TextFormField(
                    key: ValueKey("confirmPassword"),
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                    ),
                  ),
                SizedBox(
                  height: 12,
                ),
                if (widget.isLoading) CircularProgressIndicator(),
                if (!widget.isLoading)
                  RaisedButton(
                    child: Text(_isLogin ? "Login" : "Signup"),
                    onPressed: () {
                      _submitForm();
                    },
                  ),
                Text(
                  widget.errMsg,
                  style: TextStyle(color: Theme.of(context).errorColor),
                ),
                if (!widget.isLoading)
                  FlatButton(
                    child: Text(
                      _isLogin
                          ? "Not yet a user? Create Account"
                          : "Already have an account? Login",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
