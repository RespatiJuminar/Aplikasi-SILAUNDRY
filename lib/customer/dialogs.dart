import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../auth/login_page.dart';
import '../theme.dart';
import '../widgets/common.dart';

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

// ---------------- Edit Order ----------------
// Customer hanya boleh mengubah order yang masih berstatus Received.

Future<void> showEditOrderDialog(BuildContext context, LaundryOrder order) {
  return showFramedDialog<void>(
    context,
    width: 460,
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
  final _form = GlobalKey<FormState>();
  late final Map<OrderItem, TextEditingController> _qty = {
    for (final i in widget.order.items)
      i: TextEditingController(text: formatQty(i.qty)),
  };
  late final _note = TextEditingController(text: widget.order.note);

  @override
  void dispose() {
    for (final c in _qty.values) {
      c.dispose();
    }
    _note.dispose();
    super.dispose();
  }

  String? _qtyValidator(String? v) {
    final q = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
    if (q == null || q <= 0) return 'Must be greater than 0';
    return null;
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    appState.updateOrder(
      widget.order,
      qty: {
        for (final e in _qty.entries)
          e.key: double.parse(e.value.text.trim().replaceAll(',', '.')),
      },
      note: _note.text.trim(),
    );
    Navigator.pop(context);
    showMessage(widget.outerContext, 'Order updated');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit ${widget.order.id}', style: AppText.heading),
          const SizedBox(height: 18),
          for (final e in _qty.entries) ...[
            AppTextField(
              label: '${e.key.serviceName} - Quantity (kg)',
              controller: e.value,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _qtyValidator,
            ),
            const SizedBox(height: 12),
          ],
          AppTextField(label: 'Services Detail', controller: _note, maxLines: 4),
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
