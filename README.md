# Calories Counter App

<p align="center">
<img![food](https://user-images.githubusercontent.com/36364359/133696837-7727bebb-8227-44b9-8243-11b59f567e81.png) />
</p>

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
1 - Initial started design of app based on React-Native framework & Google Firebase for storage options. After building the initial UI using React Native, the integration of Google OAuth into the app was deprecated for React. After further communicated, we mutually decided to switch to Flutter in order to keep all aspects of the app consistent to Google based frameworks. 

2- Redesigned App basic structure setup. We divided our work into two: The sign-in page and the main page after sign in. This would include functions such as Google sign-up/sign-in, barcode scanner to retrieve nutrition of products, user main dashboard to view scanned products history.

3- Place holder sign in page with google oauth was built, which was succeeded by the development of the features within the home page of the app. Implemented functions in the following order: barcode scanner, connect FDA API, retrieve nutrition values data, pop up box requesting for serving size, implementation of FireStore to save scanned products, Final UI design.

4 - FILL IN HOW THE FEATURES WERE DONE.

### Work Divisions
Annamalai - Sign in page. Primary Focus on UI/Front End + Google Authentication System + Inclusion of BarCode Scanner

Hin Lui- User main page UI design, connect Barcode scanner with FDA API and retrieve nutrition values. Set up database for saving and recieving users' scanned products.

 <p align="center"> Rest APIs </p>


 <p align="center"> Testing and Results </p>

ADD PICTURES OF THE APP AND INITIAL BUGS


