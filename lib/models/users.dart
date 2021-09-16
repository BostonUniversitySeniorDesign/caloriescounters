class User {
  final String uid;

  User({required this.uid});
}

class UserData {
  final String uid;
  final String email;
  final String userName;

  UserData({required this.uid, required this.email, required this.userName});
  //get the data for current user
  UserData.fromFirestore(Map<String, dynamic> firestore, this.uid)
      : email = firestore['email'],
        userName = firestore['name'];
}
