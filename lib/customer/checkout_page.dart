import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'shell.dart';
import 'orders_page.dart';
import 'payment_page.dart';

/// Halaman Check Out: pilih metode pembayaran lalu konfirmasi.
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.order});

  final LaundryOrder order;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  PaymentMethod? _method;

  void _confirm() {
    if (_method == null) {
      showMessage(context, 'Choose a payment method first');
      return;
    }
    appState.payOrder(widget.order, _method!);
    showMessage(context, 'Payment confirmed');
    replacePage(context, PaymentPage(order: widget.order));
  }

  void _cancel() {
    // Order yang belum dibayar dibatalkan (dihapus) saat Cancel ditekan.
    if (!widget.order.paid) appState.cancelOrder(widget.order);
    replacePage(context, const OrdersPage());
  }

  @override
  Widget build(BuildContext context) {
    final tiles = <(PaymentMethod, IconData)>[
      (PaymentMethod.cash, Icons.payments_outlined),
      (PaymentMethod.eWallet, Icons.account_balance_wallet),
      (PaymentMethod.bankTransfer, Icons.account_balance),
      (PaymentMethod.creditCard, Icons.credit_card),
    ];
    return AppShell(
      title: 'Check Out',
      current: NavItem.orders,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 30, 22, 22),
        child: Column(
          children: [
            Text(
              'Order #${widget.order.id.replaceAll('ORD-', '')}',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 14),
            Text(
              'Total Payment ${formatRupiah(widget.order.total)}',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 44),
            Wrap(
              spacing: 30,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: [
                for (final t in tiles)
                  _MethodTile(
                    icon: t.$2,
                    label: t.$1.label,
                    selected: _method == t.$1,
                    onTap: () => setState(() => _method = t.$1),
                  ),
              ],
            ),
            const SizedBox(height: 44),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 196,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: _cancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1.6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 40),
                AppButton(
                  text: 'Confirm Payment',
                  width: 196,
                  radius: 30,
                  onPressed: _confirm,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 180,
          height: 228,
          decoration: BoxDecoration(
            color: const Color(0xFF3084F2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? const Color(0xFF0B3D91) : Colors.transparent,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(selected ? 70 : 30),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 72),
              const SizedBox(height: 28),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
