import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/shell.dart';
import 'customers_page.dart';

class NewUserPage extends StatefulWidget {
  const NewUserPage({super.key});

  @override
  State<NewUserPage> createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
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

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final err = appState.addCustomer(
      username: _username.text.trim(),
      name: _name.text.trim(),
      address: _address.text.trim(),
      dob: _dob.text,
      phone: _phone.text.trim(),
      password: _password.text,
    );
    if (err != null) {
      showMessage(context, err);
      return;
    }
    showMessage(context, 'User added');
    replacePage(context, const CustomersPage());
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'New User',
      current: NavItem.users,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 505,
              child: Panel(
                padding: const EdgeInsets.fromLTRB(40, 32, 40, 24),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Register New User', style: AppText.heading),
                      const SizedBox(height: 20),
                      AppTextField(label: 'Username', controller: _username, validator: requiredField),
                      const SizedBox(height: 10),
                      AppTextField(label: 'Name', controller: _name, validator: requiredField),
                      const SizedBox(height: 10),
                      AppTextField(label: 'Address', controller: _address, validator: requiredField),
                      const SizedBox(height: 10),
                      AppTextField(
                        label: 'Date Of Birth',
                        hint: 'dd-mm-yyyy',
                        controller: _dob,
                        readOnly: true,
                        onTap: _pickDate,
                        validator: requiredField,
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        label: 'Phone Number',
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        validator: phoneField,
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        label: 'Password',
                        controller: _password,
                        password: true,
                        validator: passwordField,
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => replacePage(context, const CustomersPage()),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          AppButton(text: 'Accept', width: 176, height: 48, radius: 12, onPressed: _submit),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(child: _PaperPencil()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaperPencil extends StatelessWidget {
  const _PaperPencil();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      height: 400,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 70,
            width: 300,
            child: Image.asset('assets/images/paper.png'),
          ),
          Positioned(
            left: 120,
            top: 0,
            width: 260,
            child: Image.asset('assets/images/pencil.png'),
          ),
        ],
      ),
    );
  }
}
