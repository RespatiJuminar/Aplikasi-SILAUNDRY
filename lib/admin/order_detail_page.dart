import 'package:flutter/material.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'shell.dart';
import 'orders_page.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.order});

  final LaundryOrder order;

  static const _flex = [2, 2, 2, 3, 2];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(current: NavItem.orders),
          Container(
            width: 330,
            color: AppColors.detailBlue,
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                const Text(
                  'Product\nDetails',
                  style: TextStyle(
                    fontSize: 58,
                    height: 1.05,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  order.id,
                  style: TextStyle(fontSize: 18, color: Colors.white.withAlpha(210)),
                ),
                const Spacer(),
                _BackButton(onTap: () => replacePage(context, const OrdersPage())),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 30, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _InfoField('Nama', order.customerName)),
                      const SizedBox(width: 30),
                      Expanded(child: _InfoField('Alamat', order.customerAddress)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _InfoField('No Hp', order.customerPhone)),
                      const SizedBox(width: 30),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 26),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: StatusChip(order.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Panel(
                    padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
                    child: Column(
                      children: [
                        const TableHead(
                          labels: [
                            'Order ID',
                            'Service ID',
                            'User ID',
                            'Transaction Date',
                            'Total Product',
                          ],
                          flex: _flex,
                        ),
                        for (var i = 0; i < order.items.length; i++)
                          RowCard(
                            index: i,
                            flex: _flex,
                            icon: Icons.local_laundry_service,
                            cells: [
                              Cell(order.id, bold: true),
                              Cell(order.items[i].serviceId),
                              Cell(order.customerId),
                              Cell(formatDate(order.date)),
                              Cell('${formatQty(order.items[i].qty)} kg'),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Note', style: TextStyle(fontSize: 18)),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(minHeight: 130),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.panel,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(order.note.isEmpty ? '-' : order.note),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(fontSize: 30, color: AppColors.detailBlue),
                            ),
                            const SizedBox(height: 6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                formatRupiah(order.total),
                                style: const TextStyle(
                                  fontSize: 38,
                                  color: AppColors.detailBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value.isEmpty ? '-' : value, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 180,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.detailBlue,
                child: Icon(Icons.chevron_left, color: Colors.white),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Back',
                    style: TextStyle(color: AppColors.detailBlue, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(width: 32),
            ],
          ),
        ),
      ),
    );
  }
}
