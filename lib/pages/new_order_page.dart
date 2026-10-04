import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/shell.dart';
import 'orders_page.dart';

class NewOrderPage extends StatefulWidget {
  const NewOrderPage({super.key});

  @override
  State<NewOrderPage> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends State<NewOrderPage> {
  final _qty = TextEditingController();
  final _detail = TextEditingController();
  String? _customerId;
  String? _serviceId;
  final List<OrderItem> _cart = [];

  int get _total => _cart.fold(0, (sum, i) => sum + i.subtotal);

  @override
  void dispose() {
    _qty.dispose();
    _detail.dispose();
    super.dispose();
  }

  void _addToCart() {
    if (_customerId == null) {
      showMessage(context, 'Choose a customer first');
      return;
    }
    if (_serviceId == null) {
      showMessage(context, 'Choose a service first');
      return;
    }
    final qty = double.tryParse(_qty.text.trim().replaceAll(',', '.'));
    if (qty == null || qty <= 0) {
      showMessage(context, 'Quantity (kg) must be greater than 0');
      return;
    }
    final service = appState.services.firstWhere((s) => s.id == _serviceId);
    setState(() {
      _cart.add(OrderItem(
        serviceId: service.id,
        serviceName: service.name,
        pricePerKg: service.pricePerKg,
        qty: qty,
        detail: _detail.text.trim(),
      ));
      _qty.clear();
      _detail.clear();
    });
  }

  void _checkout() {
    if (_cart.isEmpty) {
      showMessage(context, 'The cart is empty');
      return;
    }
    final customer = appState.customers.firstWhere((c) => c.id == _customerId);
    final order = appState.createOrder(customer: customer, items: _cart);
    showMessage(context, 'Order ${order.id} created (${formatRupiah(order.total)})');
    replacePage(context, const OrdersPage());
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'New Order',
      current: NavItem.orders,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Panel(
                padding: const EdgeInsets.fromLTRB(40, 32, 40, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Create Order', style: AppText.heading),
                    const SizedBox(height: 20),
                    AppDropdown<String>(
                      label: 'Customer Name',
                      value: _customerId,
                      hint: 'Choose customer',
                      items: [
                        for (final c in appState.customers)
                          DropdownMenuItem(value: c.id, child: Text('${c.name} (${c.username})')),
                      ],
                      onChanged: (v) => setState(() => _customerId = v),
                    ),
                    const SizedBox(height: 10),
                    AppDropdown<String>(
                      label: 'Services',
                      value: _serviceId,
                      hint: 'Choose service',
                      items: [
                        for (final s in appState.services)
                          DropdownMenuItem(
                            value: s.id,
                            child: Text('${s.name} - ${formatRupiah(s.pricePerKg)}/kg'),
                          ),
                      ],
                      onChanged: (v) => setState(() => _serviceId = v),
                    ),
                    const SizedBox(height: 10),
                    AppTextField(
                      label: 'Quantity (kg)',
                      hint: 'e.g. 2.5',
                      controller: _qty,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 10),
                    AppTextField(
                      label: 'Services Detail',
                      controller: _detail,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppButton(
                        text: 'Add to Cart',
                        width: 176,
                        height: 48,
                        radius: 12,
                        onPressed: _addToCart,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              flex: 5,
              child: Panel(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(8, 6, 8, 12),
                      child: Text('Cart', style: AppText.heading),
                    ),
                    if (_cart.isEmpty)
                      const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text('Cart is empty', style: TextStyle(color: AppColors.muted)),
                        ),
                      )
                    else
                      for (var i = 0; i < _cart.length; i++)
                        _CartRow(
                          item: _cart[i],
                          onRemove: () => setState(() => _cart.removeAt(i)),
                        ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        formatRupiah(_total),
                        style: const TextStyle(fontSize: 30, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppButton(
                        text: 'Process to payment',
                        width: 220,
                        height: 48,
                        radius: 12,
                        onPressed: _checkout,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.item, required this.onRemove});

  final OrderItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 10, 6, 10),
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
                Cell(item.serviceName, bold: true),
                Text(
                  '${formatQty(item.qty)} kg x ${formatRupiah(item.pricePerKg)}',
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                if (item.detail.isNotEmpty)
                  Text(
                    item.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
              ],
            ),
          ),
          Text(
            formatRupiah(item.subtotal),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 18, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}
