import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:caloriescounters/res/custom_colors.dart';
import 'package:caloriescounters/screens/sign_in_screen.dart';
import 'package:caloriescounters/utils/authentication.dart';
import 'package:caloriescounters/widgets/app_bar_title.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class fdaAPI {
  List<Foods> foods;

  fdaAPI({required this.foods});

  factory fdaAPI.fromJson(Map<String, dynamic> json) => fdaAPI(
        foods: List<Foods>.from(json["foods"].map((x) => Foods.fromJson(x))),
      );
}

class Foods {
  List<FoodNutrients> foodNutrients;

  Foods({required this.foodNutrients});

  factory Foods.fromJson(Map<String, dynamic> json) => Foods(
        foodNutrients: List<FoodNutrients>.from(
            json["foodNutrients"].map((x) => FoodNutrients.fromJson(x))),
      );
}

class FoodNutrients {
  FoodNutrients({
    required this.nutrientId,
    required this.nutrientName,
    required this.nutrientNumber,
    required this.value,
  });

  int nutrientId;
  String nutrientName;
  String nutrientNumber;
  int value;

  factory FoodNutrients.fromJson(Map<String, dynamic> json) => FoodNutrients(
        nutrientId: json["nutrientId"],
        nutrientName: json["nutrientName"],
        nutrientNumber: json["nutrientNumber"],
        value: json["value"],
      );
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late User _user;
  String? scanResult;
  String? scanCalorie;
  bool _isSigningOut = false;

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Future barcodescan() async {
    String scanResult;
    try {
      scanResult = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException {
      scanResult = 'Failed to get platform version.';
    }
    setState(() => this.scanResult = scanResult);

    print(scanResult);
    fetchAPI();
  }

  Future fetchAPI() async {
    String keyAPI = '24UiyDidqSIdtVPaIMo0NnR8pZuE6CrzWqpmwjwZ';
    //scanResult = '022000159359';
    final response = await http.get(Uri.parse(
        'https://api.nal.usda.gov/fdc/v1/foods/search?query=$scanResult&api_key=$keyAPI'));
    String scanCalorie;
    double calories = 0;
    Map<String, dynamic> nutrientsVal;
    try {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      nutrientsVal = json.decode(response.body.toString());
      List<dynamic> data = nutrientsVal["foods"];
      List<dynamic> data2 = data[0]["foodNutrients"];
      print(data2);
      double proteinValue = data2[0]["value"].toDouble() * 4;
      double fatValue = data2[1]["value"].toDouble() * 9;
      double carbValue = data2[2]["value"].toDouble() * 4;
      calories = proteinValue + fatValue + carbValue;
      scanCalorie = calories.toStringAsFixed(1);
      print(scanCalorie);
    } on PlatformException {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      scanCalorie = 'Failed to load album';
    }
    setState(() => this.scanCalorie = scanCalorie);

    print(scanCalorie);
  }

  @override
  void initState() {
    _user = widget._user;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.firebaseNavy,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomColors.firebaseNavy,
        title: AppBarTitle(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(),
              _user.photoURL != null
                  ? ClipOval(
                      child: Material(
                        color: CustomColors.firebaseGrey.withOpacity(0.3),
                        child: Image.network(
                          _user.photoURL!,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    )
                  : ClipOval(
                      child: Material(
                        color: CustomColors.firebaseGrey.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: CustomColors.firebaseGrey,
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 16.0),
              Text(
                'Hello',
                style: TextStyle(
                  color: CustomColors.firebaseGrey,
                  fontSize: 26,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                _user.displayName!,
                style: TextStyle(
                  color: CustomColors.firebaseYellow,
                  fontSize: 26,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                '( ${_user.email!} )',
                style: TextStyle(
                  color: CustomColors.firebaseOrange,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () => barcodescan(),
                //onPressed: () => fetchAPI(),
                child: Text('Scan Barcode'),
              ),
              SizedBox(height: 24.0),
              Text(
                scanResult == null ? 'Scan A code' : 'Scan result: $scanResult',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                scanCalorie == null ? 'Scan A code' : 'Calories: $scanCalorie',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'You are now signed in using your Google account. To sign out of your account click the "Sign Out" button below.',
                style: TextStyle(
                    color: CustomColors.firebaseGrey.withOpacity(0.8),
                    fontSize: 14,
                    letterSpacing: 0.2),
              ),
              SizedBox(height: 16.0),
              _isSigningOut
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.redAccent,
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          _isSigningOut = true;
                        });
                        await Authentication.signOut(context: context);
                        setState(() {
                          _isSigningOut = false;
                        });
                        Navigator.of(context)
                            .pushReplacement(_routeToSignInScreen());
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
