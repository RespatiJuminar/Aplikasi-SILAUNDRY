import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../theme.dart';
import '../widgets/auth_layout.dart';
import '../widgets/common.dart';
import 'landing_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    if (!_form.currentState!.validate()) return;
    final ok = appState.login(_username.text.trim(), _password.text);
    if (!ok) {
      showMessage(context, 'Wrong username or password');
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LandingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      form: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Get's Started",
              style: TextStyle(fontSize: 34, color: Color(0xFF808080)),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text(
                  "Don't have Account ?  ",
                  style: TextStyle(fontSize: 20, color: Color(0xFF808080)),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            AppTextField(
              label: 'Username',
              hint: 'Insert Username',
              icon: Icons.person_outline,
              controller: _username,
              outlined: true,
              validator: requiredField,
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Password',
              hint: 'Insert Password',
              icon: Icons.lock_outline,
              controller: _password,
              password: true,
              outlined: true,
              validator: requiredField,
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 44),
            Center(
              child: AppButton(
                text: 'Login',
                width: 180,
                height: 44,
                radius: 30,
                onPressed: _login,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Demo: username "admin", password "admin12345"',
                style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
