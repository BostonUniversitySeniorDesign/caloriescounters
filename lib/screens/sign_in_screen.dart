import 'package:flutter/material.dart';
import 'package:caloriescounters/res/custom_colors.dart';
import 'package:caloriescounters/utils/authentication.dart';
import 'package:caloriescounters/widgets/google_sign_in_button.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Image.asset(
                        'assets/food.png',
                        height: 160,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Welcome to the Calorie Counter',
                      style: TextStyle(
                        color: Colors.lightGreen,
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      '',
                      style: TextStyle(
                        color: CustomColors.firebaseOrange,
                        fontSize: 110,
                      ),
                    ),
                    Text(
                      '',
                      style: TextStyle(
                        color: CustomColors.firebaseOrange,
                        fontSize: 110,
                      ),
                    ),
                    Text(
                      'Please sign in using your Google Account',
                      style: TextStyle(
                        color: CustomColors.firebaseOrange,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder(
                future: Authentication.initializeFirebase(context: context),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error initializing Firebase');
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return GoogleSignInButton();
                  }
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CustomColors.firebaseOrange,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
