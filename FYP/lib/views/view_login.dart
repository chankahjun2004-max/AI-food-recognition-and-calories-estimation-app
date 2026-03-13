import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../viewmodels/vm_login.dart';
import '../widgets/tng_header.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          TngHeader(
            title: 'welcome'.tr(),
            subtitle: 'login_subtitle_text'.tr(),
            height: 220,
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildInputField(
                        label: 'email_hint'.tr(),
                        controller: vm.emailController,
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 18),
                      _buildInputField(
                        label: 'password_hint'.tr(),
                        controller: vm.passwordController,
                        icon: Icons.lock,
                        isPassword: true,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: vm.isRememberMe,
                                activeColor: cs.primary,
                                onChanged: (value) {
                                  if (value != null) {
                                    vm.toggleRememberMe(value);
                                  }
                                },
                              ),
                              Text("remember_me".tr()),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => vm.authAction(
                                LoginAction.goToForgotPassword, context),
                            child: Text(
                              "forgot_password_title".tr(),
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),
                      vm.isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () =>
                                  vm.authAction(LoginAction.login, context),
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 56)),
                              child: Text(
                                'login_button'.tr(),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                      const SizedBox(height: 25),
                      GestureDetector(
                        onTap: () =>
                            vm.authAction(LoginAction.goToSignup, context),
                        child: Text(
                          "signup_prompt".tr(),
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => context.setLocale(const Locale('en')),
                            child: const Text('EN'),
                          ),
                          TextButton(
                            onPressed: () => context.setLocale(const Locale('ms')),
                            child: const Text('MS'),
                          ),
                          TextButton(
                            onPressed: () => context.setLocale(const Locale('zh')),
                            child: const Text('ZH'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
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
