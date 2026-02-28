import 'package:flutter/material.dart';

import '../models/user_model.dart';

enum SignupAction {
  signup,
  goToLogin,
}

class SignupViewModel extends ChangeNotifier {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  /// Used by the UI eye icons.
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  bool isLoading = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    notifyListeners();
  }

  Future<void> signupAction(SignupAction action, BuildContext context) async {
    switch (action) {
      case SignupAction.signup:
        await _handleSignup(context);
        break;

      case SignupAction.goToLogin:
        Navigator.pushReplacementNamed(context, '/login');
        break;
    }
  }

  Future<void> _handleSignup(BuildContext context) async {
    if (isLoading) return;
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      displayError(context, 'Please fill in all fields');
      return;
    }

    if (password != confirmPassword) {
      displayError(context, 'Passwords do not match');
      return;
    }

    final strengthError = _passwordStrengthError(password);
    if (strengthError != null) {
      displayError(context, strengthError);
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await UserModel.signup(name, email, password);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup successful! Please login.')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!context.mounted) return;
      displayError(context, 'Signup failed: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// Returns a user-friendly error message if the password is weak; otherwise null.
  ///
  /// Policy:
  /// - at least 8 characters
  /// - at least 1 uppercase
  /// - at least 1 lowercase
  /// - at least 1 number
  /// - at least 1 special character
  String? _passwordStrengthError(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);
    final hasSpecial = RegExp(r'[^a-zA-Z0-9]').hasMatch(password);


    if (!hasUpper || !hasLower || !hasNumber || !hasSpecial) {
      return 'Password is too weak. Use uppercase, lowercase, number, and special character.';
    }
    return null;
  }

  void directToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
  }

  void displayError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
