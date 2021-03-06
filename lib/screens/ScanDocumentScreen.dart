import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:blinkid_flutter/microblink_scanner.dart';

import '../providers/AuthProvider.dart';
import '../providers/IdentityDocumentProvider.dart';

import '../models/IdentityDocumentModel.dart';

import '../widgets/scan_doc_screen_widgets/doc_image.dart';
import '../widgets/scan_doc_screen_widgets/single_document.dart';

import '../config.dart' as config;

class ScanDocumentScreen extends StatefulWidget {
  @override
  _ScanDocumentScreenState createState() => _ScanDocumentScreenState();
}

class _ScanDocumentScreenState extends State<ScanDocumentScreen> {
  bool _isInit = true;
  bool _isLoading = true;
  bool showData = false;
  Widget _resultContainer = Container();
  String _fullDocumentFrontImageBase64 = "";
  String _fullDocumentBackImageBase64 = "";
  String _faceImageBase64 = "";
  BlinkIdCombinedRecognizerResult resultData;
  String docType = "";
  List<Map<String, dynamic>> userData = [];

  Future<void> scan() async {
    List<RecognizerResult> results;
    String license = "";

    var recognizer = BlinkIdCombinedRecognizer();
    recognizer.returnFullDocumentImage = true;
    recognizer.returnFaceImage = true;

    OverlaySettings settings = BlinkIdOverlaySettings();

    // set license
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      license = "${config.bLinkLicenseKeyIos}";
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      license = "${config.bLinkLicenseKeyAndroid}";
    }

    try {
      // perform scan and gather results
      results = await MicroblinkScanner.scanWithCamera(
          RecognizerCollection([recognizer]), settings, license);
      if (results.length == 0) return;

      for (var result in results) {
        if (result is BlinkIdCombinedRecognizerResult) {
          if (result.mrzResult.documentType == MrtdDocumentType.Passport) {
            //Document is an international passport
            setState(() {
              docType = "International Passport";
            });
          } else if (result.driverLicenseDetailedInfo != null &&
              (result.driverLicenseDetailedInfo.vehicleClass.isNotEmpty ||
                  result.driverLicenseDetailedInfo.endorsements.isNotEmpty ||
                  result.driverLicenseDetailedInfo.conditions.isNotEmpty ||
                  result.driverLicenseDetailedInfo.restrictions.isNotEmpty)) {
            //document is a driver's license
            setState(() {
              docType = "Driver's License";
            });
          } else {
            setState(() {
              docType = "Identity Card";
            });
          }

          //empty previous data to add new data
          userData.clear();

          _resultContainer = getIdResultContainer(result);
          setState(() {
            // resultData = result;
            showData = true;

            _faceImageBase64 = result.faceImage;
            _resultContainer = _resultContainer;
            _fullDocumentFrontImageBase64 = result.fullDocumentFrontImage;
            _fullDocumentBackImageBase64 = result.fullDocumentBackImage;
            userData.add({"faceImage": _faceImageBase64});
            userData
                .add({"fullDocumentFrontImage": _fullDocumentFrontImageBase64});

            userData.add({"docType": docType});
          });

          setState(() {
            _isLoading = true;
          });
          await Provider.of<IdentityDocumentProvider>(context, listen: false)
              .uploadDocumentData(userData);
          await Provider.of<IdentityDocumentProvider>(context, listen: false)
              .fetchDocumentData()
              .then((_) {
            setState(() {
              _isLoading = false;
              showData = true;
            });
          });

          return;
        }
      }
    } on PlatformException catch (err) {
      showDialog(
        context: context,
        builder: (bCtx) => AlertDialog(
          content: Text("Unable to process document, Please try again later"),
          actions: [
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      );
    }
  }

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

    setState(() {
      userData.add({key: result});
    });

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
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (_isInit) {
      Provider.of<IdentityDocumentProvider>(context, listen: false)
          .fetchDocumentData()
          .then((_) {
        setState(() {
          _isLoading = false;
          showData = true;
        });
      });
    }
    _isInit = false;
  }

  @override
  Widget build(BuildContext context) {
    List<IdentityDocumentModel> documents =
        Provider.of<IdentityDocumentProvider>(context).documents;

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Identification Card")),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            width: MediaQuery.of(context).size.width,
            height: 80,
            color: Colors.grey.withOpacity(0.4),
            child: RaisedButton.icon(
              onPressed: () {
                scan().then((value) => {print("done")});
              },
              icon: Icon(Icons.camera_alt),
              label: Text("Scan Document"),
            ),
          ),
          _isLoading
              ? Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Expanded(
                  child: showData
                      ? ListView(
                          children: documents.length <= 0
                              ? [
                                  Container(
                                    padding: EdgeInsets.only(top: 40),
                                    child: Text(
                                      "You have not scanned any Identity Document yet",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ]
                              : documents.map(
                                  (e) {
                                    dynamic data = e;
                                    print(data);
                                    return SingleDocument(
                                      docData: data,
                                    );
                                  },
                                ).toList(),
                        )
                      : Container(),
                ),
        ],
      ),
    );
  }
}
