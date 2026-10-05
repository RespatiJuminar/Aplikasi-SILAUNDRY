import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'shell.dart';
import 'payment_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Dashboard',
      current: NavItem.dashboard,
      child: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final orders = appState.myOrders.take(4).toList();
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Panel(
                    padding: const EdgeInsets.all(28),
                    radius: 20,
                    child: Container(
                      height: 136,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(32, 22, 32, 16),
                      decoration: BoxDecoration(
                        color: AppColors.tile,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(35),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome To SILAUNDRY',
                            style: TextStyle(
                              fontFamily: 'Consolas',
                              fontFamilyFallback: ['Courier New', 'monospace'],
                              fontSize: 26,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            appState.currentUser?.name ?? '',
                            style: const TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Panel(
                  padding: const EdgeInsets.fromLTRB(14, 20, 14, 14),
                  radius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 14),
                        child: Text(
                          'Your Order',
                          style: AppText.heading.copyWith(fontSize: 24),
                        ),
                      ),
                      if (orders.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: Text("You don't have any order yet")),
                        )
                      else
                        for (var i = 0; i < orders.length; i++)
                          _OrderRow(index: i, order: orders[i]),
                    ],
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

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.index, required this.order});

  final int index;
  final LaundryOrder order;

  @override
  Widget build(BuildContext context) {
    return RowCard(
      index: index,
      flex: const [4, 4, 3],
      icon: Icons.local_laundry_service,
      onTap: () => replacePage(context, PaymentPage(order: order)),
      cells: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Cell(order.id, bold: true),
            Cell(order.items.map((i) => i.serviceName).join(', ')),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Cell(formatDate(order.date)),
            const SizedBox(height: 2),
            StatusChip(order.status),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Cell(formatRupiah(order.total), bold: true),
        ),
      ],
    );
  }
}
