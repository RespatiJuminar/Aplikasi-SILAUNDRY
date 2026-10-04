import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/auth_layout.dart';
import '../widgets/common.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _dob = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _name.dispose();
    _address.dispose();
    _dob.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) _dob.text = formatDate(picked);
  }

  void _goLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _signUp() {
    if (!_form.currentState!.validate()) return;
    final err = appState.registerAdmin(AdminAccount(
      username: _username.text.trim(),
      name: _name.text.trim(),
      address: _address.text.trim(),
      dob: _dob.text,
      phone: _phone.text.trim(),
      password: _password.text,
    ));
    if (err != null) {
      showMessage(context, err);
      return;
    }
    showMessage(context, 'Account created, please log in');
    _goLogin();
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
                  'Already have Account ?  ',
                  style: TextStyle(fontSize: 20, color: Color(0xFF808080)),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _goLogin,
                    child: const Text(
                      'Log In',
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
            const SizedBox(height: 24),
            AppTextField(
              label: 'Username',
              hint: 'Username',
              icon: Icons.person_outline,
              controller: _username,
              outlined: true,
              validator: requiredField,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Name',
              hint: 'Name',
              icon: Icons.badge_outlined,
              controller: _name,
              outlined: true,
              validator: requiredField,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Address',
              hint: 'Address',
              icon: Icons.location_on_outlined,
              controller: _address,
              outlined: true,
              validator: requiredField,
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Date of Birth',
                    hint: 'dd-mm-yyyy',
                    icon: Icons.calendar_month_outlined,
                    controller: _dob,
                    outlined: true,
                    readOnly: true,
                    onTap: _pickDate,
                    validator: requiredField,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Phone Number',
                    hint: 'Phone Number',
                    icon: Icons.phone_android,
                    controller: _phone,
                    outlined: true,
                    keyboardType: TextInputType.phone,
                    validator: phoneField,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Password',
              hint: '*Password length (10-32)',
              icon: Icons.lock_outline,
              controller: _password,
              password: true,
              outlined: true,
              validator: passwordField,
              onSubmitted: (_) => _signUp(),
            ),
            const SizedBox(height: 28),
            Center(
              child: AppButton(
                text: 'Sign Up',
                width: 180,
                radius: 30,
                onPressed: _signUp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
