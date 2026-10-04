import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/shell.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _form = GlobalKey<FormState>();
  late final _username = TextEditingController(text: appState.currentAdmin?.username ?? '');
  late final _name = TextEditingController(text: appState.currentAdmin?.name ?? '');
  late final _address = TextEditingController(text: appState.currentAdmin?.address ?? '');
  late final _phone = TextEditingController(text: appState.currentAdmin?.phone ?? '');
  late final _password = TextEditingController(text: appState.currentAdmin?.password ?? '');

  @override
  void dispose() {
    _username.dispose();
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final err = appState.updateAdmin(
      username: _username.text.trim(),
      name: _name.text.trim(),
      address: _address.text.trim(),
      phone: _phone.text.trim(),
      password: _password.text,
    );
    showMessage(context, err ?? 'Account updated');
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Account Settings',
      current: NavItem.account,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 505),
            child: Panel(
              padding: const EdgeInsets.fromLTRB(40, 32, 40, 24),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Edit User', style: AppText.heading),
                    const SizedBox(height: 20),
                    AppTextField(label: 'Username', controller: _username, validator: requiredField),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Name', controller: _name, validator: requiredField),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Address', controller: _address, validator: requiredField),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Phone Number',
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      validator: phoneField,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Password',
                      controller: _password,
                      password: true,
                      validator: passwordField,
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppButton(
                        text: 'Accept',
                        width: 176,
                        height: 48,
                        radius: 12,
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
