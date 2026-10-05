import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'shell.dart';

/// Daftar layanan laundry. Customer hanya bisa melihat (tidak ada tombol tambah).
class ServiceListPage extends StatefulWidget {
  const ServiceListPage({super.key});

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  String _query = '';
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Service List',
      current: NavItem.services,
      child: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final q = _query.toLowerCase();
          final list = appState.services
              .where((s) => s.name.toLowerCase().contains(q))
              .toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1000
                  ? 4
                  : constraints.maxWidth >= 720
                      ? 3
                      : 2;
              final perPage = columns * 2;
              final totalPages = list.isEmpty ? 1 : (list.length / perPage).ceil();
              final page = _page > totalPages - 1 ? totalPages - 1 : _page;
              final visible = list.skip(page * perPage).take(perPage).toList();

              return Padding(
                padding: const EdgeInsets.fromLTRB(40, 14, 40, 18),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SearchField(
                        onChanged: (v) => setState(() {
                          _query = v;
                          _page = 0;
                        }),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: visible.isEmpty
                          ? const Center(child: Text('No services found'))
                          : GridView.builder(
                              itemCount: visible.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 28,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.78,
                              ),
                              itemBuilder: (context, i) => _ServiceCard(service: visible[i]),
                            ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Text('${page + 1} of $totalPages Page'),
                          const Spacer(),
                          AppButton(
                            text: 'Previous',
                            height: 30,
                            width: 100,
                            radius: 30,
                            onPressed: page > 0 ? () => setState(() => _page = page - 1) : null,
                          ),
                          const SizedBox(width: 20),
                          AppButton(
                            text: 'Next',
                            height: 30,
                            width: 100,
                            radius: 30,
                            onPressed: page < totalPages - 1
                                ? () => setState(() => _page = page + 1)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final LaundryService service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.local_laundry_service, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 14),
          Text(
            service.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Estimate: ${service.days} day(s)',
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${formatRupiah(service.pricePerKg)} / kg',
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
