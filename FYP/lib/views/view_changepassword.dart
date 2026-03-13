import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
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
          TngHeader(
            title: 'change_password_title'.tr(),
            subtitle: 'change_password_subtitle'.tr(),
            height: 160,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
              child: Column(
                children: [
                  _buildInputField(
                    label: "old_password_label".tr(),
                    controller: vm.oldPasswordController,
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 18),
                  _buildInputField(
                    label: "new_password_label".tr(),
                    controller: vm.newPasswordController,
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                  const SizedBox(height: 18),
                  _buildInputField(
                    label: "confirm_password_hint".tr(),
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
                            child: Text('update_password_button'.tr()),
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
                color: Theme.of(context).shadowColor.withOpacity(0.05),
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
