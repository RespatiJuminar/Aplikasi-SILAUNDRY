import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'shell.dart';
import 'new_order_page.dart';
import 'orders_page.dart';

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
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const _CategoryPanel(),
                      const SizedBox(height: 22),
                      const _RecentOrderPanel(),
                    ],
                  ),
                ),
                const SizedBox(width: 22),
                const SizedBox(width: 300, child: _SummaryColumn()),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryPanel extends StatelessWidget {
  const _CategoryPanel();

  @override
  Widget build(BuildContext context) {
    void toNewOrder() => replacePage(context, const NewOrderPage());
    return Panel(
      padding: const EdgeInsets.all(28),
      radius: 20,
      child: Row(
        children: [
          Expanded(child: _CategoryTile(Icons.checkroom, 'Clothes', toNewOrder)),
          const SizedBox(width: 16),
          Expanded(child: _CategoryTile(Icons.dry_cleaning, 'Pants', toNewOrder)),
          const SizedBox(width: 16),
          Expanded(child: _CategoryTile(Icons.local_laundry_service, 'Jackets', toNewOrder)),
          const SizedBox(width: 16),
          Expanded(
            child: _CategoryTile(
              Icons.grid_view_rounded,
              'See More',
              () => replacePage(context, const NewOrderPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 136,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 46),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentOrderPanel extends StatelessWidget {
  const _RecentOrderPanel();

  @override
  Widget build(BuildContext context) {
    final recent = appState.orders.take(4).toList();
    return Panel(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 14),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 14),
            child: Text(
              'Recent Order',
              style: AppText.heading.copyWith(fontSize: 24),
            ),
          ),
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No orders yet')),
            )
          else
            for (var i = 0; i < recent.length; i++) _RecentRow(index: i, order: recent[i]),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              text: 'See All',
              height: 30,
              width: 110,
              radius: 6,
              onPressed: () => replacePage(context, const OrdersPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.index, required this.order});

  final int index;
  final LaundryOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_laundry_service, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Cell(order.id, bold: true),
                Cell(order.customerName),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Cell(formatDate(order.date)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: StatusChip(order.status),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Cell(formatRupiah(order.total), bold: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  const _SummaryColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoCard(
          title: 'BALANCE',
          icon: Icons.account_balance_wallet,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatRupiah(appState.balance),
                    style: const TextStyle(
                      fontSize: 30,
                      color: AppColors.cardHeader,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${appState.ordersThisWeek} orders this week',
                  style: const TextStyle(fontSize: 16, color: AppColors.cardHeader),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        _InfoCard(
          title: 'REPORT',
          icon: Icons.fact_check_outlined,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              children: [
                _ReportLine('Total Order', appState.orders.length),
                _ReportLine('Received', appState.countByStatus(OrderStatus.received)),
                _ReportLine('On Progress', appState.countByStatus(OrderStatus.onProgress)),
                _ReportLine('Completed', appState.countByStatus(OrderStatus.completed)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 70,
            color: AppColors.cardHeader,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 22)),
                const Spacer(),
                Icon(icon, color: Colors.white, size: 38),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _ReportLine extends StatelessWidget {
  const _ReportLine(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 18, color: AppColors.cardHeader)),
          const Spacer(),
          Text('$value', style: const TextStyle(fontSize: 18, color: AppColors.cardHeader)),
        ],
      ),
    );
  }
}
