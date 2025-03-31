import 'package:edusurvey/data/model/user_model.dart';
import 'package:hive/hive.dart';

class HiveUserService {
  static const String userBoxName = 'userBox';

  Future<void> addUser(UserModel user) async {
    final box = await Hive.openBox<UserModel>(userBoxName);
    await box.put(user.email, user); // Use email as the unique key
  }

  Future<UserModel?> getUser(String email) async {
    try {
      final box = await Hive.openBox<UserModel>(userBoxName);
      print("Looking for user with email: $email");
      print("Available users in box: ${box.keys.toList()}");
      final user = box.get(email);
      print("Found user? ${user != null ? 'Yes' : 'No'}");
      return user;
    } catch (e) {
      print("Error retrieving user: ${e.toString()}");
      return null;
    }
  }

  Future<void> clearUsers() async {
    final box = await Hive.openBox<UserModel>(userBoxName);
    await box.clear();
  }
}
