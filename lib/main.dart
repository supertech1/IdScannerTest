import 'package:IdScannerTest/screens/ScanDocumentScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/AuthProvider.dart';
import './providers/IdentityDocumentProvider.dart';

import './screens/AuthScreen.dart';
import './screens/SplashScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, IdentityDocumentProvider>(
          update: (ctx, auth, idp) {
            return IdentityDocumentProvider(auth.token, auth.userId);
          },
        ),
      ],
      child: Consumer<AuthProvider>(builder: (bCtx, auth, _) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            accentColor: Colors.teal,
            buttonTheme: ButtonTheme.of(context).copyWith(
              buttonColor: Colors.deepPurple,
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          home: auth.isAuthenticated
              ? ScanDocumentScreen()
              : FutureBuilder(
                  future: auth.autoLogin(),
                  builder: (bCtx, authResultSnapShot) =>
                      authResultSnapShot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
        );
      }),
    );
  }
}
