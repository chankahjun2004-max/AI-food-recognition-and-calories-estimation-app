import 'package:flutter/material.dart';

import '../models/user_model.dart';

enum LoginAction {
  login,
  goToSignup,
  goToForgotPassword,
}

class LoginViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isRememberMe = false;
  bool isLoading = false;

  LoginViewModel() {
    _initRememberMe();
  }

  Future<void> _initRememberMe() async {
    isRememberMe = await UserModel.getRememberMe();
    notifyListeners();
  }

  void toggleRememberMe(bool value) {
    isRememberMe = value;
    UserModel.setRememberMe(value);
    notifyListeners();
  }

  /// Universal function for LoginView
  Future<void> authAction(LoginAction action, BuildContext context) async {
    switch (action) {
      case LoginAction.login:
        await _handleLogin(context);
        break;

      case LoginAction.goToSignup:
        Navigator.pushNamed(context, '/signup');
        break;

      case LoginAction.goToForgotPassword:
        Navigator.pushNamed(context, '/forgot_password');
        break;
    }
  }

  Future<void> _handleLogin(BuildContext context) async {
    if (isLoading) return;
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      displayError(context, 'Please enter email and password');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await UserModel.login(email, password);
      await UserModel.setRememberMe(isRememberMe);

      if (!context.mounted) return;
      directToHome(context);
    } catch (e) {
      if (!context.mounted) return;
      displayError(context, 'Login failed: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void directToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
  }

  

/// Clear login fields and reset flags when returning to login screen.
/// Use this on logout when Remember Me is OFF.
void resetForLoggedOut({bool clearEmail = true}) {
  if (clearEmail) {
    emailController.clear();
  }
  passwordController.clear();
  isLoading = false;
  isRememberMe = false;
  notifyListeners();
}

void displayError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
