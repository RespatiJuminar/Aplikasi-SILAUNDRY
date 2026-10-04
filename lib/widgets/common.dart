import 'package:flutter/material.dart';
import '../data/models.dart';
import '../theme.dart';

// ---------------- Helper format & validasi ----------------

String _two(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime d) => '${_two(d.day)}-${_two(d.month)}-${d.year}';

String formatRupiah(num value) {
  final s = value.round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp. $b';
}

String formatQty(double q) =>
    q == q.roundToDouble() ? q.toStringAsFixed(0) : q.toString();

String? requiredField(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Required' : null;

String? phoneField(String? v) {
  if (v == null || v.trim().isEmpty) return 'Required';
  if (!RegExp(r'^[0-9+]{8,15}$').hasMatch(v.trim())) {
    return 'Phone must be 8-15 digits';
  }
  return null;
}

String? passwordField(String? v) {
  if (v == null || v.isEmpty) return 'Required';
  if (v.length < 10 || v.length > 32) return 'Password length must be 10-32';
  return null;
}

Color statusColor(OrderStatus s) {
  switch (s) {
    case OrderStatus.received:
      return const Color(0xFF8E8E93);
    case OrderStatus.onProgress:
      return const Color(0xFFF59E0B);
    case OrderStatus.completed:
      return const Color(0xFF16A34A);
  }
}

void showMessage(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(SnackBar(
    content: Text(message),
    behavior: SnackBarBehavior.floating,
    width: 380,
  ));
}

// ---------------- Input ----------------

/// Text field dengan label di atas. `outlined: true` dipakai di halaman
/// login/register, sedangkan default (abu-abu) dipakai di form dashboard.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.icon,
    this.password = false,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.keyboardType,
    this.outlined = false,
    this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final IconData? icon;
  final bool password;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool outlined;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _hide = true;

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.outlined ? 14 : 8),
      borderSide: widget.outlined || width > 1
          ? BorderSide(color: color, width: width)
          : BorderSide.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    final normal = widget.outlined ? const Color(0xFFDDDDDD) : Colors.transparent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 2),
            child: Text(
              widget.label!,
              style: AppText.label.copyWith(
                color: widget.outlined ? const Color(0xFF666666) : AppColors.text,
              ),
            ),
          ),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.password && _hide,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          maxLines: widget.password ? 1 : widget.maxLines,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onFieldSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: Color(0xFFB5B5B5)),
            filled: true,
            fillColor: widget.outlined ? Colors.white : AppColors.field,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: widget.outlined ? 15 : 12,
            ),
            prefixIcon: widget.icon == null
                ? null
                : Icon(widget.icon, size: 20, color: const Color(0xFF666666)),
            suffixIcon: widget.password
                ? IconButton(
                    icon: Icon(
                      _hide ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: const Color(0xFF444444),
                    ),
                    onPressed: () => setState(() => _hide = !_hide),
                  )
                : null,
            border: _border(normal),
            enabledBorder: _border(normal),
            focusedBorder: _border(AppColors.primary, width: 1.6),
            errorBorder: _border(Colors.red, width: 1.2),
            focusedErrorBorder: _border(Colors.red, width: 1.6),
          ),
        ),
      ],
    );
  }
}

/// Dropdown bergaya abu-abu seperti di desain (Services, Customer Name, dll).
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.label,
    this.value,
    this.hint = 'Select',
  });

  final String? label;
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 2),
            child: Text(label!, style: AppText.label),
          ),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: Text(hint, style: const TextStyle(color: Color(0xFFB5B5B5))),
              items: items,
              onChanged: onChanged,
              borderRadius: BorderRadius.circular(8),
              dropdownColor: Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.detailBlue),
            ),
          ),
        ),
      ],
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.onChanged, this.width = 290});

  final ValueChanged<String> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 38,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: const TextStyle(color: Color(0xFFB5B5B5)),
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: AppColors.panel,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF9A9A9A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF9A9A9A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ---------------- Tombol ----------------

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.primary,
    this.width,
    this.height = 44,
    this.radius = 14,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final double? width;
  final double height;
  final double radius;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          textStyle: const TextStyle(fontSize: 16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 6)],
            Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

// ---------------- Panel & tabel ----------------

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 22,
    this.color = AppColors.panel,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

/// Baris judul kolom di atas daftar (User / Order).
class TableHead extends StatelessWidget {
  const TableHead({super.key, required this.labels, required this.flex});

  final List<String> labels;
  final List<int> flex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Row(
        children: [
          const SizedBox(width: 64),
          for (var i = 0; i < labels.length; i++)
            Expanded(
              flex: flex[i],
              child: Text(
                labels[i],
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Satu baris data dengan kotak biru di kiri, sesuai desain.
class RowCard extends StatelessWidget {
  const RowCard({
    super.key,
    required this.index,
    required this.cells,
    required this.flex,
    this.icon = Icons.person,
    this.selected = false,
    this.onTap,
  });

  final int index;
  final List<Widget> cells;
  final List<int> flex;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 66,
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: index.isEven ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
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
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 16),
              for (var i = 0; i < cells.length; i++)
                Expanded(flex: flex[i], child: cells[i]),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final c = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Teks sel tabel satu baris dengan ellipsis.
class Cell extends StatelessWidget {
  const Cell(this.text, {super.key, this.bold = false});

  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: AppColors.text,
      ),
    );
  }
}
