import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'shell.dart';
import 'orders_page.dart';

/// Halaman Payment: ringkasan order, tahap proses (1-2-3), dan info pembayaran.
class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key, required this.order});

  final LaundryOrder order;

  @override
  Widget build(BuildContext context) {
    final step = order.status.index; // 0 received, 1 on progress, 2 completed
    return AppShell(
      title: 'Payment',
      current: NavItem.orders,
      child: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(40, 14, 40, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _InfoField('Customer', appState.currentUser?.name ?? '-'),
                    ),
                    const SizedBox(width: 34),
                    Expanded(child: _InfoField('Order ID', order.id)),
                  ],
                ),
                const SizedBox(height: 22),
                _Stepper(step: step),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _ItemsPanel(order: order)),
                    const SizedBox(width: 34),
                    Expanded(child: _PaymentPanel(order: order)),
                  ],
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    text: 'Back to Orders',
                    width: 190,
                    radius: 30,
                    onPressed: () => replacePage(context, const OrdersPage()),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

/// Garis 1 - 2 - 3 : Received, On Progress, Completed.
class _Stepper extends StatelessWidget {
  const _Stepper({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    const labels = ['Received', 'On Progress', 'Completed'];
    Widget dot(int i) {
      final active = i <= step;
      return Column(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? AppColors.primary : const Color(0xFFC4C4C4),
            ),
            child: Text(
              '${i + 1}',
              style: TextStyle(color: active ? Colors.white : Colors.black87),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            labels[i],
            style: TextStyle(
              fontSize: 12,
              color: active ? AppColors.primary : AppColors.muted,
            ),
          ),
        ],
      );
    }

    Widget line(bool active) => Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Container(
              height: 4,
              color: active ? AppColors.primary : const Color(0xFFC4C4C4),
            ),
          ),
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        dot(0),
        line(step >= 1),
        dot(1),
        line(step >= 2),
        dot(2),
      ],
    );
  }
}

class _ItemsPanel extends StatelessWidget {
  const _ItemsPanel({required this.order});

  final LaundryOrder order;

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Items', style: AppText.heading),
          const SizedBox(height: 14),
          for (var i = 0; i < order.items.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Cell(order.items[i].serviceName, bold: true),
                        Text(
                          '${formatQty(order.items[i].qty)} kg x ${formatRupiah(order.items[i].pricePerKg)}',
                          style: const TextStyle(fontSize: 13, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatRupiah(order.items[i].subtotal),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          const Text('Note', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 90),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(order.note.isEmpty ? '-' : order.note),
          ),
        ],
      ),
    );
  }
}

class _PaymentPanel extends StatelessWidget {
  const _PaymentPanel({required this.order});

  final LaundryOrder order;

  @override
  Widget build(BuildContext context) {
    Widget line(String k, Widget v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(k, style: const TextStyle(fontSize: 16, color: AppColors.muted)),
              const Spacer(),
              v,
            ],
          ),
        );

    return Panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Info', style: AppText.heading),
          const SizedBox(height: 14),
          line('Order Date', Text(formatDate(order.date))),
          line('Total Weight', Text('${formatQty(order.totalQty)} kg')),
          line('Method', Text(order.paymentMethod?.label ?? '-')),
          line(
            'Payment',
            Text(
              order.paid ? 'Paid' : 'Unpaid',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: order.paid ? const Color(0xFF16A34A) : AppColors.danger,
              ),
            ),
          ),
          line('Status', StatusChip(order.status)),
          const Divider(height: 32),
          Row(
            children: [
              const Text('Total', style: TextStyle(fontSize: 22, color: AppColors.primary)),
              const Spacer(),
              Text(
                formatRupiah(order.total),
                style: const TextStyle(fontSize: 26, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
