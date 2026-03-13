import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/vm_signup.dart';
import '../widgets/tng_header.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignupViewModel>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          const TngHeader(
            title: 'Create Account',
            subtitle: 'Sign up to get started',
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
                        label: "Full Name",
                        controller: vm.nameController,
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 18),
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
                        obscureText: !vm.isPasswordVisible,
                        suffix: IconButton(
                          onPressed: vm.togglePasswordVisibility,
                          icon: Icon(
                            vm.isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildInputField(
                        label: "Confirm Password",
                        controller: vm.confirmPasswordController,
                        icon: Icons.lock_outline,
                        obscureText: !vm.isConfirmPasswordVisible,
                        suffix: IconButton(
                          onPressed: vm.toggleConfirmPasswordVisibility,
                          icon: Icon(
                            vm.isConfirmPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),
                      vm.isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () =>
                                  vm.signupAction(SignupAction.signup, context),
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 56)),
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                      const SizedBox(height: 25),
                      GestureDetector(
                        onTap: () =>
                            vm.signupAction(SignupAction.goToLogin, context),
                        child: Text(
                          "Already have an account? Login",
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
    bool obscureText = false,
    Widget? suffix,
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
            obscureText: obscureText,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: cs.primary),
              suffixIcon: suffix,
              labelText: label,
            ),
          ),
        );
      },
    );
  }
}
