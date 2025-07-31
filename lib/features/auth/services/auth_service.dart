import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User?> signIn(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<User?> register(
    String email,
    String password,
    String phoneNumber,
  ) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      final uri = Uri.parse('http://10.0.2.2:3000/users/register');

      final body = {
        "uid": user.uid,
        "email": email,
        "phoneNumber": phoneNumber,
      };

      try {
        final response = await http.post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );

        if (response.statusCode != 201 && response.statusCode != 200) {
          throw Exception(
            'Nu s-a putut realiza înregistrarea utilizatorului: ${response.body}',
          );
        }
      } catch (e) {
        await user.delete();
        rethrow;
      }
    }

    return user;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<Map<String, dynamic>> verifyUserCodes({
    required String uid,
    required String otpCode,
    required String smsCode,
  }) async {
    final uri = Uri.parse('http://10.0.2.2:3000/users/verify');
    final body = {"uid": uid, "otpCode": otpCode, "smsCode": smsCode};

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        "success": true,
        "message": decoded["message"] ?? "Cont verificat!",
      };
    } else {
      return {
        "success": false,
        "message": decoded["message"] ?? "Verificare eșuată!",
      };
    }
  }

  Future<bool> isUserVerified(String uid) async {
    final uri = Uri.parse('http://10.0.2.2:3000/users/status/$uid');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      print("[DEBUG] User verification status: $decoded");
      return decoded["verified"] == true;
    }

    return false;
  }
}
