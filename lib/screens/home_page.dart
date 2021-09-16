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
        backgroundColor: Color(0xFFF8F0E3),
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
              // _user.photoURL != null
              //     ? ClipOval(
              //         child: Material(
              //           color: CustomColors.firebaseGrey.withOpacity(0.3),
              //           child: Image.network(
              //             _user.photoURL!,
              //             fit: BoxFit.fitHeight,
              //           ),
              //         ),
              //       )
              //     : ClipOval(
              //         child: Material(
              //           color: CustomColors.firebaseGrey.withOpacity(0.3),
              //           child: Padding(
              //             padding: const EdgeInsets.all(16.0),
              //             child: Icon(
              //               Icons.person,
              //               size: 60,
              //               color: CustomColors.firebaseGrey,
              //             ),
              //           ),
              //         ),
              //       ),
              SizedBox(height: 16.0),
              Text(
                'Hello, ' + _user.displayName!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 26,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'To begin, click the Scan Barcode button.',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 8.0),
              // email
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.orange.shade200),
                ),
                onPressed: () => barcodescan(),
                //onPressed: () => fetchAPI(),
                child: Text('Scan Barcode'),
              ),
              SizedBox(height: 24.0),

              Text(
                '',
                style: TextStyle(
                    color: CustomColors.firebaseGrey.withOpacity(0.8),
                    fontSize: 65,
                    letterSpacing: 0.2),
              ),
              Text(
                'You are now signed in using your Google account. To sign out of your account click the "Sign Out" button below.',
                style: TextStyle(
                    color: Colors.green, fontSize: 14, letterSpacing: 0.2),
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
  // var date = new DateTime.fromMillisecondsSinceEpoch(1000 * submittedTime);
  print(scanTime);
  print(calories);
  return GestureDetector(
    onTap: () async {
      print('ontap');
      await showDialog(
          context: context,
          builder: (_) => Dialog(
                  child: Container(
                height: 480,
                child: Column(
                  children: [
                    SizedBox(
                      height: 14,
                    ),
                    AutoSizeText(
                      'Food: ' + foodName,
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                    ),
                    AutoSizeText(
                      'Calories : ' + calories + 'kcal',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                    ),
                    AutoSizeText(
                      'Serving Size : ' + servingSize,
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                    ),
                    AutoSizeText(
                      'Scanned Time : ' + scanTime.toIso8601String(),
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              )));
    },
    child: Card(
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
              scanTime.toString(),
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
                        "Food: ",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Scan Time: ",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "calorie:  ",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
                        foodName.toString(),
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                      ),
                      AutoSizeText(
                        scanTime.toIso8601String(),
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                      ),
                      AutoSizeText(
                        calories + 'kcal',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
