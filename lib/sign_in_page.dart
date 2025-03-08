import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dashboard_page.dart'; // Import DashboardPage

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  Future<User?> _signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            User? user = await _signInWithGoogle();
            if (user != null) {
              print('User signed in: ${user.displayName}');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage(user: user)),
              );
            } else {
              print('Sign in failed');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sign in failed. Please try again.')),
              );
            }
          },
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}
