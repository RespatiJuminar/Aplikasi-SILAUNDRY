import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/dialogs.dart';
import '../widgets/shell.dart';
import 'new_user_page.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  String _query = '';
  String? _selectedId;

  static const _flex = [2, 3, 4, 3, 2];

  List<Customer> get _filtered {
    final q = _query.toLowerCase();
    return appState.customers
        .where((c) =>
            c.username.toLowerCase().contains(q) ||
            c.name.toLowerCase().contains(q) ||
            c.phone.contains(q))
        .toList();
  }

  Customer? get _selected {
    for (final c in appState.customers) {
      if (c.id == _selectedId) return c;
    }
    return null;
  }

  void _edit() {
    final c = _selected;
    if (c == null) {
      showMessage(context, 'Select a user from the list first');
      return;
    }
    showEditUserDialog(context, c);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Customers',
      current: NavItem.users,
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
                      text: 'Add User',
                      width: 176,
                      height: 50,
                      onPressed: () => replacePage(context, const NewUserPage()),
                    ),
                    const SizedBox(width: 22),
                    AppButton(
                      text: 'Delete User',
                      color: AppColors.danger,
                      width: 176,
                      height: 50,
                      onPressed: () {
                        if (appState.customers.isEmpty) {
                          showMessage(context, 'There are no users to delete');
                          return;
                        }
                        showDeleteUserDialog(context, preselected: _selected);
                      },
                    ),
                    const SizedBox(width: 22),
                    AppButton(
                      text: 'Edit User',
                      width: 176,
                      height: 50,
                      onPressed: _edit,
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
                          labels: ['Username', 'Name', 'Address', 'Phone', 'Date of Birth'],
                          flex: _flex,
                        ),
                        Expanded(
                          child: list.isEmpty
                              ? const Center(child: Text('No users found'))
                              : ListView.builder(
                                  itemCount: list.length,
                                  itemBuilder: (context, i) {
                                    final c = list[i];
                                    return RowCard(
                                      index: i,
                                      flex: _flex,
                                      selected: c.id == _selectedId,
                                      onTap: () => setState(() {
                                        _selectedId = c.id == _selectedId ? null : c.id;
                                      }),
                                      cells: [
                                        Cell(c.username, bold: true),
                                        Cell(c.name),
                                        Cell(c.address),
                                        Cell(c.phone),
                                        Cell(c.dob),
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
