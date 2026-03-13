import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          const TngHeader(
            title: 'Welcome Back',
            subtitle: 'Login to your account',
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
                        label: "Email",
                        controller: vm.emailController,
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 18),
                      _buildInputField(
                        label: "Password",
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
                              const Text("Remember me"),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => vm.authAction(
                                LoginAction.goToForgotPassword, context),
                            child: Text(
                              "Forgot Password?",
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
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                      const SizedBox(height: 25),
                      GestureDetector(
                        onTap: () =>
                            vm.authAction(LoginAction.goToSignup, context),
                        child: Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
