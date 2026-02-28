import 'package:flutter/material.dart';

import '../models/user_model.dart';

enum ChangePasswordAction {
  changePassword,
}

class ChangePasswordViewModel extends ChangeNotifier {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> changePasswordAction(
    ChangePasswordAction action,
    BuildContext context,
  ) async {
    switch (action) {
      case ChangePasswordAction.changePassword:
        await _handleChangePassword(context);
        break;
    }
  }

  Future<void> _handleChangePassword(BuildContext context) async {
    final oldPass = oldPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      displayError(context, 'Please fill in all fields');
      return;
    }

    if (newPass != confirmPass) {
      displayError(context, 'Passwords do not match');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await UserModel.changePassword(oldPass, newPass);

      if (!context.mounted) return;
      displayMessage(context, 'Password updated successfully');
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      displayError(context, 'Change password failed: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
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
