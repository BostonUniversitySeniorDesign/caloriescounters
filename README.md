# Calories Counter App


![food](https://github.com/amg1998/caloriescounters/blob/main/lib/media/icon.png)


## What is Calorie Counter? 
Calorie Counter app is a cross-platform mobile app using [Flutter](https://github.com/flutter/flutter) that is designed to keep track of the calories consumed over the day while grouping items and recipes for future usage.

## Features
- Read barcodes of products
- Calculate calories of products based on custom servings size
- Display all previous scanned products & calories
- TimeStamp & Recipe saving to revisit and produce similar meals in the future.
- Google sign in authenication
- Multi-user system, seperated database

## Work Divisions
Annamalai - Primary Focus on UI/Front End + Google Authentication System for Sign in Page + Inclusion of BarCode Scanner

Hin Lui- User main page UI design, connect Barcode scanner with FDA API and retrieve nutrition values. Set up database for saving and recieving users' scanned products.
 
## Agile Software Design

### Design Process
1 - Initial started design of app based on React-Native framework & Google Firebase for storage options. After building the initial UI using React Native, the integration of Google OAuth into the app was deprecated for React. After further communicated, we mutually decided to switch to Flutter in order to keep all aspects of the app consistent to Google based frameworks. Initially designed a 4-page application (overcomplicated).

2- Redesigned App basic structure setup. We divided our work into two: The sign-in page and the main page after sign in. This would include functions such as Google sign-up/sign-in, barcode scanner to retrieve nutrition of products, user main dashboard to view scanned products history.

3- Place holder sign in page with google oauth was built, which was succeeded by the development of the features within the home page of the app. Implemented functions in the following order: barcode scanner, connect FDA API, retrieve nutrition values data, pop up box requesting for serving size, implementation of FireStore to save scanned products.

4 - Finalize the app UI design, using a green & white color for base colors of the application and added a welcome message to user. [Hin Lui](https://github.com/jshumhl) sums up the entire projects by writing a comprehensible Readme 

### Work Divisions
Annamalai - Sign in page. Primary Focus on UI/Front End + Google Authentication System + Inclusion of BarCode Scanner

Hin Lui- User main page UI design, connect Barcode scanner with FDA API and retrieve nutrition values. Set up database for saving and recieving users' scanned products.

## REST API
Data transformation. Created classes to store data retrieved from FDA API.
```dart
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
```
To obtain data from or store data into Firebase, we need a way to convert data inside the class to Firebase readable data.
Clients can infinitely add scanned products in a recipe folder under a collection named by their uid. Each user has seperated database and their scanned products will never be mixed.
```dart
recipeCollection.doc(_user.uid).set(
        {'name': _user.displayName, 'uid': _user.uid, 'email': _user.email});

    recipeCollection.doc(_user.uid).collection('recipes').add({
      "foodName": foodName.toString(),
      "scanTime": now.toString(),
      "servingSize": servingSize.toString(),
      "calories": scanCalorie.toString()
    });
```


## Testing and Results

### Page Layout
#### Sign-in Screen - A logo in the center with a Google Sign-In button

<img src="https://github.com/amg1998/caloriescounters/blob/main/lib/media/signin_page.jpg" width="300">

#### Home-page Screen - Our main page consists of a welcome message, sign-out button, scan barcode button and a list view of past scanned products

<img src="https://github.com/amg1998/caloriescounters/blob/main/lib/media/mainpage.jpg" width="300">

### Google Sign-In
Google sign up/sign in based on Firebase. New database setup for new user signed in. 

![Google Sign-in](https://github.com/amg1998/caloriescounters/blob/main/lib/media/googlesignin.gif)

### Scan barcode, ask for servings, calculate calories
Click the scan barcode button to start scanning, can switch camera side, turn on/off flashlight.
When a barcode is successfully scanned, a dialog box pop up to request for servings.

![Barcode Scan](https://github.com/amg1998/caloriescounters/blob/main/lib/media/scanbarcode.gif)

### List view of scanned products
Scanned products will be saved in the database with the following entries: Product description, calories, sercing size, scanned date/time

![List View](https://github.com/amg1998/caloriescounters/blob/main/lib/media/infinite_list.gif)

### Each user has their own database
User A can only see A's previous scanned products. User B has a different collection.

![Different database](https://github.com/amg1998/caloriescounters/blob/main/lib/media/differentaccount.gif)

### Firebase/Firestore backend
Each user's collection is named with unique user id. Scanned foods are saved in collection "recipes" under the document "uid" in "users" collection. (please wait for the gif to load)

![Firestore database](https://github.com/amg1998/caloriescounters/blob/main/lib/media/firebasebackend.gif)

## Authors

Made by [Hin Lui Shum @jshumhl](https://github.com/jshumhl) and [@Annamalai](https://github.com/amg2005)
