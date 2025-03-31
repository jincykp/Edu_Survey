import 'package:edusurvey/data/database/hive_user_services.dart';
import 'package:edusurvey/data/model/user_model.dart';

class UserRepository {
  final HiveUserService _hiveService = HiveUserService();

  Future<void> registerUser(String name, String email, String password) async {
    UserModel user = UserModel(name: name, email: email, password: password);
    await _hiveService.addUser(user);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    return await _hiveService.getUser(email);
  }

  Future<bool> updateUserPassword(String email, String newPassword) async {
    try {
      // Get the current user
      final user = await _hiveService.getUser(email);

      if (user == null) {
        return false;
      }

      // Create updated user with new password
      final updatedUser = UserModel(
        name: user.name,
        email: user.email,
        password: newPassword,
      );

      // Save the updated user
      await _hiveService.addUser(updatedUser);
      return true;
    } catch (e) {
      print("Error updating password: ${e.toString()}");
      return false;
    }
  }
}
