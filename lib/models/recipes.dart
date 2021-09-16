class RecipesInfo {
  DateTime scanTime;
  String foodName;
  String servingSize;
  String calories;

  RecipesInfo({
    required this.scanTime,
    required this.foodName,
    required this.servingSize,
    required this.calories,
  });

  Map<String, dynamic> mapUsers() {
    return {
      'foodName': foodName,
      'scanTime': scanTime,
      'servingSize': servingSize,
      'calories': calories,
    };
  }

  Map<String, dynamic> mapRecipes() {
    return {
      'foodName': foodName,
      'scanTime': scanTime,
      'servingSize': servingSize,
      'calories': calories,
    };
  }

  RecipesInfo.fromFirestore(Map<String, dynamic> firestore)
      : foodName = firestore['foodName'],
        scanTime = firestore['scanTime'],
        servingSize = firestore['servingSize'],
        calories = firestore['calories'];
}
