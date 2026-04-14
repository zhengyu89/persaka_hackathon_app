import 'package:shared_preferences/shared_preferences.dart';

class EmailLinkStorage {
  static const String _pendingEmailKey = 'auth.email_link.pending_email';

  Future<void> saveEmail(String email) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_pendingEmailKey, email.trim());
  }

  Future<String?> loadEmail() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? email = preferences.getString(_pendingEmailKey)?.trim();

    if (email == null || email.isEmpty) {
      return null;
    }

    return email;
  }

  Future<void> clearEmail() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(_pendingEmailKey);
  }
}
