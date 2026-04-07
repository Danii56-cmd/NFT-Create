import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class AuthService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _emailKey = 'userEmail';
  static const String _passwordHashKey = 'userPasswordHash';
  static const String _userIdKey = 'userId'; // New: Unique ID per user

  final Uuid _uuid = const Uuid();

  // Hash password
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // ====================== REGISTER ======================
  Future<bool> register(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final existingEmail = prefs.getString(_emailKey);

      // If same email already exists → don't allow duplicate registration
      if (existingEmail != null &&
          existingEmail.toLowerCase() == email.toLowerCase()) {
        return false;
      }

      String userId = _uuid.v4(); // Generate unique user ID
      String hashedPassword = _hashPassword(password);

      // Save user data
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_emailKey, email);
      await prefs.setString(_passwordHashKey, hashedPassword);
      await prefs.setString(_userIdKey, userId); // Important for per-user NFTs

      return true;
    } catch (e) {
      print("Register Error: $e");
      return false;
    }
  }

  // ====================== LOGIN ======================
  Future<bool> login(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final storedEmail = prefs.getString(_emailKey);
      final storedHash = prefs.getString(_passwordHashKey);

      if (storedEmail == null || storedHash == null) {
        return false;
      }

      String inputHash = _hashPassword(password);

      if (storedEmail.toLowerCase() == email.toLowerCase() &&
          storedHash == inputHash) {
        await prefs.setBool(_isLoggedInKey, true);
        return true;
      }

      return false;
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }

  // ====================== CHECK LOGIN STATUS ======================
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  // ====================== GET CURRENT USER ID ======================
  Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      return null;
    }
  }

  // ====================== GET CURRENT EMAIL ======================
  Future<String?> getCurrentEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_emailKey);
    } catch (e) {
      return null;
    }
  }

  // ====================== LOGOUT ======================
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, false);
      // Note: We keep email and userId so user can login again easily
    } catch (e) {
      print("Logout Error: $e");
    }
  }

  // ====================== CLEAR ALL DATA (For Testing) ======================
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print("Clear Data Error: $e");
    }
  }
}
