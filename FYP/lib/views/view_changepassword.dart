
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/vm_changepassword.dart';
import '../widgets/tng_header.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChangePasswordViewModel>();

    return Scaffold(
      body: Column(
        children: [
          const TngHeader(
            title: 'Change Password',
            subtitle: 'Keep your account secure',
            height: 160,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
              child: Column(
                children: [
            _buildInputField(
              label: "Old Password",
              controller: vm.oldPasswordController,
              icon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 18),
            _buildInputField(
              label: "New Password",
              controller: vm.newPasswordController,
              icon: Icons.lock,
              isPassword: true,
            ),
            const SizedBox(height: 18),
            _buildInputField(
              label: "Confirm Password",
              controller: vm.confirmPasswordController,
              icon: Icons.lock,
              isPassword: true,
            ),
            const SizedBox(height: 25),
                    vm.isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => vm.changePasswordAction(
                                ChangePasswordAction.changePassword,
                                context,
                              ),
                              child: const Text('Update Password'),
                            ),
                          ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: cs.primary),
              labelText: label,
            ),
          ),
        );
      },
    );
  }
}
