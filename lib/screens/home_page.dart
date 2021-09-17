import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:caloriescounters/models/recipes.dart';
import 'package:caloriescounters/models/user_db.dart';
//import 'package:caloriescounters/models/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:caloriescounters/res/custom_colors.dart';
import 'package:caloriescounters/screens/sign_in_screen.dart';
import 'package:caloriescounters/utils/authentication.dart';
import 'package:caloriescounters/widgets/app_bar_title.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class FdaAPI {
  List<Foods> foods = [];

  FdaAPI({required this.foods});

  factory FdaAPI.fromJson(Map<String, dynamic> json) => FdaAPI(
        foods: List<Foods>.from(json["foods"].map((x) => Foods.fromJson(x))),
      );
}

class Foods {
  String description;
  List<FoodNutrients> foodNutrients = [];

  Foods({required this.description, required this.foodNutrients});

  factory Foods.fromJson(Map<String, dynamic> json) => Foods(
        description: json["description"],
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
  double value;

  factory FoodNutrients.fromJson(Map<String, dynamic> json) => FoodNutrients(
        nutrientId: json["nutrientId"],
        nutrientName: json["nutrientName"],
        nutrientNumber: json["nutrientNumber"],
        value: json["value"].toDouble(),
      );
}

class Recipe {
  DateTime scanTime;
  String foodName;
  String servingSize;
  String calories;

  Recipe({
    required this.scanTime,
    required this.foodName,
    required this.servingSize,
    required this.calories,
  });
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
    requestServings();
  }

  double servingSize = 0.0;
  String valueText = "";

  Future<void> requestServings() async {
    TextEditingController _Controller = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Serving size'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _Controller,
              decoration: InputDecoration(hintText: "in grams"),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Submit'),
                onPressed: () {
                  setState(() {
                    servingSize = double.parse(valueText);
                    Navigator.pop(context);
                    fetchAPI();
                  });
                },
              ),
            ],
          );
        });
  }

  Future fetchAPI() async {
    String keyAPI = '24UiyDidqSIdtVPaIMo0NnR8pZuE6CrzWqpmwjwZ';
    //scanResult = '040000513070';
    final response = await http.get(Uri.parse(
        'https://api.nal.usda.gov/fdc/v1/foods/search?query=$scanResult&api_key=$keyAPI'));
    String scanCalorie;
    double calories = 0;
    String foodName = '';
    Map<String, dynamic> nutrientsVal;

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      nutrientsVal = json.decode(response.body.toString());
      final testing = FdaAPI.fromJson(nutrientsVal);
      List<dynamic> data = nutrientsVal["foods"];
      List<dynamic> data2 = data[0]["foodNutrients"];
      foodName = data[0]["description"];
      print(foodName);
      double energyValue = data2[3]["value"].toDouble();
      print(energyValue);
      print(servingSize);
      calories = energyValue * servingSize / 100;
      scanCalorie = calories.toStringAsFixed(1);
      print(scanCalorie);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      scanCalorie = 'Failed to load album';
    }
    setState(() => this.scanCalorie = scanCalorie);

    print(scanCalorie);
    var now = DateTime.now();
    print(now);

    // add to firestore collection
    final CollectionReference recipeCollection =
        FirebaseFirestore.instance.collection("users");

    recipeCollection.doc(_user.uid).set(
        {'name': _user.displayName, 'uid': _user.uid, 'email': _user.email});

    recipeCollection.doc(_user.uid).collection('recipes').add({
      "foodName": foodName.toString(),
      "scanTime": now.toString(),
      "servingSize": servingSize.toString(),
      "calories": scanCalorie.toString()
    });
  }

  @override
  void initState() {
    _user = widget._user;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F0E3),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(),
              SizedBox(height: 16.0),
              Text(
                'Hello, ' + _user.displayName!,
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              SizedBox(height: 4.0),
              _isSigningOut
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.redAccent.shade200,
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
                        padding: EdgeInsets.only(top: 2.0, bottom: 2.0),
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 8.0),
              Text(
                '\nTo begin, click the Scan Barcode button.\nAnd enter the serving size in grams.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.green.shade200),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
                ),
                onPressed: () => barcodescan(),
                //onPressed: () => fetchAPI(),
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Text(
                    'Scan Barcode',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(_user.uid)
                      .collection('recipes')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return Container(
                        child: Text("Loading"),
                      );
                    } else {
                      return Expanded(
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                    title: buildCard(
                                  context,
                                  snapshot.data!.docs[index]['foodName'],
                                  DateTime.parse(
                                      snapshot.data!.docs[index]['scanTime']),
                                  snapshot.data!.docs[index]['servingSize'],
                                  snapshot.data!.docs[index]['calories'],
                                ));
                              }));
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildCard(
  BuildContext context,
  String foodName,
  DateTime scanTime,
  String servingSize,
  String calories,
) {
  return GestureDetector(
    child: Card(
      color: Color(0xFFC7F6B6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 1,
      child: Container(
        height: 100,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: <Widget>[
            AutoSizeText(
              foodName.toString(),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
            ),
            Expanded(
              child: Container(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Calorie:  ",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "Serving Size:  ",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "Scan Time: ",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AutoSizeText(
                        calories + 'kcal',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                      ),
                      AutoSizeText(
                        servingSize + 'g',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                      ),
                      AutoSizeText(
                        scanTime.toIso8601String(),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
