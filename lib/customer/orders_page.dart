import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'dialogs.dart';
import 'shell.dart';
import 'checkout_page.dart';
import 'new_order_page.dart';
import 'payment_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String? _selectedId;

  static const _flex = [2, 3, 2, 2, 2, 2];

  LaundryOrder? _find(List<LaundryOrder> list) {
    for (final o in list) {
      if (o.id == _selectedId) return o;
    }
    return null;
  }

  void _edit(List<LaundryOrder> list) {
    final o = _find(list);
    if (o == null) {
      showMessage(context, 'Select an order from the list first');
      return;
    }
    if (o.status != OrderStatus.received) {
      showMessage(context, 'Only orders with status Received can be edited');
      return;
    }
    showEditOrderDialog(context, o);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Order',
      current: NavItem.orders,
      child: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final list = appState.myOrders;
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      text: 'Edit Order',
                      color: AppColors.danger,
                      width: 176,
                      height: 50,
                      onPressed: () => _edit(list),
                    ),
                    const SizedBox(width: 22),
                    AppButton(
                      text: 'Create New Order',
                      width: 190,
                      height: 50,
                      onPressed: () => replacePage(context, const NewOrderPage()),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Panel(
                    padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
                    child: Column(
                      children: [
                        const TableHead(
                          labels: ['Order ID', 'Service', 'Date', 'Total', 'Status', ''],
                          flex: _flex,
                        ),
                        Expanded(
                          child: list.isEmpty
                              ? const Center(child: Text("You don't have any order yet"))
                              : ListView.builder(
                                  itemCount: list.length,
                                  itemBuilder: (context, i) {
                                    final o = list[i];
                                    return RowCard(
                                      index: i,
                                      flex: _flex,
                                      icon: Icons.local_laundry_service,
                                      selected: o.id == _selectedId,
                                      onTap: () => setState(() {
                                        _selectedId = o.id == _selectedId ? null : o.id;
                                      }),
                                      cells: [
                                        Cell(o.id, bold: true),
                                        Cell(o.items.map((e) => e.serviceName).join(', ')),
                                        Cell(formatDate(o.date)),
                                        Cell(formatRupiah(o.total)),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: StatusChip(o.status),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () => replacePage(
                                              context,
                                              o.paid ? PaymentPage(order: o) : CheckoutPage(order: o),
                                            ),
                                            child: Text(o.paid ? 'See Detail' : 'Pay Now'),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
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
