import 'package:flutter/material.dart';
import '../admin/landing_page.dart' as admin;
import '../customer/landing_page.dart' as customer;
import '../data/app_state.dart';
import '../theme.dart';
import '../widgets/auth_layout.dart';
import '../widgets/common.dart';
import 'register_page.dart';
import 'role_toggle.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  UserRole _role = UserRole.customer;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    if (!_form.currentState!.validate()) return;
    final ok = appState.login(_username.text.trim(), _password.text, _role);
    if (!ok) {
      showMessage(context, 'Wrong username or password');
      return;
    }
    final Widget next = _role == UserRole.admin
        ? const admin.LandingPage()
        : const customer.LandingPage();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    final demo = _role == UserRole.admin
        ? 'Demo: username "admin", password "admin12345"'
        : 'Demo: username "budi01", password "rahasia12345"';
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
                      MaterialPageRoute(builder: (_) => RegisterPage(initialRole: _role)),
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
            const SizedBox(height: 26),
            RoleToggle(role: _role, onChanged: (r) => setState(() => _role = r)),
            const SizedBox(height: 26),
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
            const SizedBox(height: 40),
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
            Center(
              child: Text(
                demo,
                style: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
