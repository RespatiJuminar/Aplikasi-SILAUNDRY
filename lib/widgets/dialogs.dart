import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../pages/login_page.dart';
import '../theme.dart';
import 'common.dart';

/// Bingkai dialog umum: border biru muda + tombol X di pojok kanan atas.
Future<T?> showFramedDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  double width = 420,
  Color color = Colors.white,
  bool bordered = true,
}) {
  return showDialog<T>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: bordered ? Border.all(color: AppColors.dialogBorder) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(35),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(padding: const EdgeInsets.all(28), child: builder(ctx)),
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.primary),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ---------------- Log Out ----------------

Future<void> showLogoutDialog(BuildContext context) {
  return showFramedDialog<void>(
    context,
    width: 390,
    builder: (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        const Text(
          "Once you're logout\nyou can't go back",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, height: 1.4, color: Color(0xFF555555)),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Back',
                style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
              ),
            ),
            const SizedBox(width: 14),
            AppButton(
              text: 'Logout',
              radius: 30,
              height: 40,
              width: 110,
              onPressed: () {
                appState.logout();
                Navigator.of(ctx).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ],
    ),
  );
}

// ---------------- Delete User ----------------

Future<void> showDeleteUserDialog(BuildContext context, {Customer? preselected}) {
  return showFramedDialog<void>(
    context,
    width: 560,
    builder: (ctx) => _DeleteUserBody(preselected: preselected, outerContext: context),
  );
}

class _DeleteUserBody extends StatefulWidget {
  const _DeleteUserBody({required this.preselected, required this.outerContext});

  final Customer? preselected;
  final BuildContext outerContext;

  @override
  State<_DeleteUserBody> createState() => _DeleteUserBodyState();
}

class _DeleteUserBodyState extends State<_DeleteUserBody> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.preselected?.id;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Select Username',
          style: TextStyle(fontSize: 18, color: Color(0xFF555555)),
        ),
        const SizedBox(height: 14),
        AppDropdown<String>(
          value: _selectedId,
          hint: 'Choose a username',
          items: [
            for (final c in appState.customers)
              DropdownMenuItem(value: c.id, child: Text('${c.username}  -  ${c.name}')),
          ],
          onChanged: (v) => setState(() => _selectedId = v),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Back',
                style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
              ),
            ),
            const SizedBox(width: 14),
            AppButton(
              text: 'Delete',
              color: AppColors.dangerSoft,
              radius: 30,
              height: 40,
              width: 110,
              onPressed: _selectedId == null
                  ? null
                  : () {
                      final target =
                          appState.customers.firstWhere((c) => c.id == _selectedId);
                      appState.deleteCustomer(target);
                      Navigator.pop(context);
                      showMessage(widget.outerContext, 'User "${target.username}" deleted');
                    },
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------- Edit User ----------------

Future<void> showEditUserDialog(BuildContext context, Customer customer) {
  return showFramedDialog<void>(
    context,
    width: 440,
    color: AppColors.panel,
    bordered: false,
    builder: (ctx) => _EditUserBody(customer: customer, outerContext: context),
  );
}

class _EditUserBody extends StatefulWidget {
  const _EditUserBody({required this.customer, required this.outerContext});

  final Customer customer;
  final BuildContext outerContext;

  @override
  State<_EditUserBody> createState() => _EditUserBodyState();
}

class _EditUserBodyState extends State<_EditUserBody> {
  final _form = GlobalKey<FormState>();
  late final _username = TextEditingController(text: widget.customer.username);
  late final _name = TextEditingController(text: widget.customer.name);
  late final _address = TextEditingController(text: widget.customer.address);
  late final _phone = TextEditingController(text: widget.customer.phone);
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final err = appState.updateCustomer(
      widget.customer,
      username: _username.text.trim(),
      name: _name.text.trim(),
      address: _address.text.trim(),
      phone: _phone.text.trim(),
    );
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    Navigator.pop(context);
    showMessage(widget.outerContext, 'User updated');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Edit User', style: AppText.heading),
          const SizedBox(height: 18),
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
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(text: 'Accept', width: 160, radius: 10, onPressed: _submit),
          ),
        ],
      ),
    );
  }
}

// ---------------- Add Service ----------------

Future<void> showAddServiceDialog(BuildContext context) {
  return showFramedDialog<void>(
    context,
    width: 440,
    color: AppColors.panel,
    bordered: false,
    builder: (ctx) => _AddServiceBody(outerContext: context),
  );
}

class _AddServiceBody extends StatefulWidget {
  const _AddServiceBody({required this.outerContext});

  final BuildContext outerContext;

  @override
  State<_AddServiceBody> createState() => _AddServiceBodyState();
}

class _AddServiceBodyState extends State<_AddServiceBody> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _days = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _days.dispose();
    super.dispose();
  }

  String? _positiveInt(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n <= 0) return 'Enter a number greater than 0';
    return null;
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    appState.addService(
      name: _name.text.trim(),
      pricePerKg: int.parse(_price.text.trim()),
      days: int.parse(_days.text.trim()),
    );
    Navigator.pop(context);
    showMessage(widget.outerContext, 'Service added');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Service', style: AppText.heading),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Service Name',
            hint: 'e.g. Laundry 2 Hari',
            controller: _name,
            validator: requiredField,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Price per kg (Rp)',
            hint: 'e.g. 8000',
            controller: _price,
            keyboardType: TextInputType.number,
            validator: _positiveInt,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Duration (days)',
            hint: 'e.g. 2',
            controller: _days,
            keyboardType: TextInputType.number,
            validator: _positiveInt,
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(text: 'Add', width: 160, radius: 10, onPressed: _submit),
          ),
        ],
      ),
    );
  }
}

// ---------------- Edit Order (ubah status) ----------------

Future<void> showEditOrderDialog(BuildContext context, LaundryOrder order) {
  return showFramedDialog<void>(
    context,
    width: 440,
    color: AppColors.panel,
    bordered: false,
    builder: (ctx) => _EditOrderBody(order: order, outerContext: context),
  );
}

class _EditOrderBody extends StatefulWidget {
  const _EditOrderBody({required this.order, required this.outerContext});

  final LaundryOrder order;
  final BuildContext outerContext;

  @override
  State<_EditOrderBody> createState() => _EditOrderBodyState();
}

class _EditOrderBodyState extends State<_EditOrderBody> {
  late OrderStatus _status = widget.order.status;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Edit ${widget.order.id}', style: AppText.heading),
        const SizedBox(height: 6),
        Text(widget.order.customerName, style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 18),
        AppDropdown<OrderStatus>(
          label: 'Order Status',
          value: _status,
          items: [
            for (final s in OrderStatus.values)
              DropdownMenuItem(value: s, child: Text(s.label)),
          ],
          onChanged: (v) => setState(() => _status = v ?? _status),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            text: 'Accept',
            width: 160,
            radius: 10,
            onPressed: () {
              appState.updateOrderStatus(widget.order, _status);
              Navigator.pop(context);
              showMessage(widget.outerContext, 'Order status updated');
            },
          ),
        ),
      ],
    );
  }
}
