import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'dialogs.dart';
import 'shell.dart';
import 'new_order_page.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _query = '';
  String? _selectedId;

  static const _flex = [2, 3, 3, 3, 3, 2];

  List<LaundryOrder> get _filtered {
    final q = _query.toLowerCase();
    return appState.orders
        .where((o) =>
            o.id.toLowerCase().contains(q) ||
            o.customerName.toLowerCase().contains(q) ||
            o.status.label.toLowerCase().contains(q))
        .toList();
  }

  LaundryOrder? get _selected {
    for (final o in appState.orders) {
      if (o.id == _selectedId) return o;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Order',
      current: NavItem.orders,
      child: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final list = _filtered;
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
            child: Column(
              children: [
                Row(
                  children: [
                    SearchField(onChanged: (v) => setState(() => _query = v)),
                    const Spacer(),
                    AppButton(
                      text: 'Edit Order',
                      color: AppColors.danger,
                      width: 176,
                      height: 50,
                      onPressed: () {
                        final o = _selected;
                        if (o == null) {
                          showMessage(context, 'Select an order from the list first');
                          return;
                        }
                        showEditOrderDialog(context, o);
                      },
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
                          labels: ['Order ID', 'Customer', 'Date', 'Total', 'Status', ''],
                          flex: _flex,
                        ),
                        Expanded(
                          child: list.isEmpty
                              ? const Center(child: Text('No orders found'))
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
                                        Cell(o.customerName),
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
                                              OrderDetailPage(order: o),
                                            ),
                                            child: const Text('See Detail'),
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
