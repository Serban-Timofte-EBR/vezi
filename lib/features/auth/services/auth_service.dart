import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User?> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseLoginError(e);
    }
  }

  String _mapFirebaseLoginError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Adresa de email nu este validă.';
      case 'user-not-found':
        return 'Nu există un cont cu acest email.';
      case 'wrong-password':
        return 'Parola introdusă este greșită.';
      case 'user-disabled':
        return 'Acest cont a fost dezactivat.';
      case 'too-many-requests':
        return 'Ai încercat de prea multe ori. Încearcă mai târziu.';
      default:
        return 'Autentificarea a eșuat. Te rugăm să verifici datele.';
    }
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
      final uri = Uri.parse('https://api.openfocsani.eu/users/register');

      final body = {
        "uid": user.uid,
        "email": email,
        "phoneNumber": phoneNumber,
      };

      const username = 'veziAdmin';
      const password = 'Mareparolagrea1234!';
      final basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';

      try {
        final response = await http.post(
          uri,
          headers: {
            "Content-Type": "application/json",
            'Authorization': basicAuth,
          },
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
    final uri = Uri.parse('https://api.openfocsani.eu/users/verify');
    final body = {"uid": uid, "otpCode": otpCode, "smsCode": smsCode};

    const username = 'veziAdmin';
    const password = 'Mareparolagrea1234!';
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json", 'Authorization': basicAuth},
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
    final uri = Uri.parse('https://api.openfocsani.eu/users/status/$uid');
    const username = 'veziAdmin';
    const password = 'Mareparolagrea1234!';
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final response = await http.get(uri, headers: {'Authorization': basicAuth});

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      print("[DEBUG] User verification status: $decoded");
      return decoded["verified"] == true;
    }

    return false;
  }
}
