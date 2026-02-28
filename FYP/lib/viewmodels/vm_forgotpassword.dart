import 'package:flutter/material.dart';

import '../models/user_model.dart';

enum ForgotPasswordAction {
  sendResetEmail,
}

class ForgotPasswordViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  bool isLoading = false;

  Future<void> forgotPasswordAction(
    ForgotPasswordAction action,
    BuildContext context,
  ) async {
    switch (action) {
      case ForgotPasswordAction.sendResetEmail:
        await _handleSendReset(context);
        break;
    }
  }

  Future<void> _handleSendReset(BuildContext context) async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      displayError(context, 'Please enter your email');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await UserModel.sendPasswordReset(email);

      if (!context.mounted) return;
      displayMessage(context, 'Reset email sent. Please check your inbox.');
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      displayError(context, e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void displayMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void displayError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
