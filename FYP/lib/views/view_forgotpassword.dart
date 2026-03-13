import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../viewmodels/vm_forgotpassword.dart';
import '../widgets/tng_header.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ForgotPasswordViewModel>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          TngHeader(
            title: 'forgot_password_title'.tr(),
            subtitle: 'forgot_password_subtitle'.tr(),
            height: 220,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'reset_password_label'.tr(),
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'reset_password_instruction'.tr(),
                    style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 18),
                  _EmailField(controller: vm.emailController),
                  const SizedBox(height: 35),
                  vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => vm.forgotPasswordAction(
                              ForgotPasswordAction.sendResetEmail,
                              context,
                            ),
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 56)),
                            child: Text('reset_password_button'.tr(),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
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
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.email, color: cs.primary),
          labelText: 'email_hint'.tr(),
        ),
      ),
    );
  }
}
