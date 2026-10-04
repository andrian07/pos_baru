import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/currency.dart';
import '../widgets/app_nav.dart';
import '../widgets/app_sidebar.dart';
import 'login_screen.dart';

const _pageSize = 8;

class CustomerScreen extends StatefulWidget {
  final AppUser user;
  const CustomerScreen({super.key, required this.user});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  String _searchQuery = '';
  int _page = 0;

  List<Customer> get _filtered {
    if (_searchQuery.isEmpty) return customerCatalog;
    final q = _searchQuery.toLowerCase();
    return customerCatalog
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.phone.contains(q) ||
              c.code.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _handleLogout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _notAvailable(String label) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label belum tersedia')));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final pageCount = (filtered.length / _pageSize).ceil().clamp(1, 9999);
    final page = _page.clamp(0, pageCount - 1);
    final pageItems = filtered.skip(page * _pageSize).take(_pageSize).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F9),
      body: Row(
        children: [
          AppSidebar(
            items: appNavItems,
            selectedIndex: 3,
            onSelect: (i) => handleAppNavSelect(context, i, widget.user),
            onLogout: _handleLogout,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CustomerTopBar(
                    user: widget.user,
                    onSearchChanged: (v) => setState(() {
                      _searchQuery = v;
                      _page = 0;
                    }),
                  ),
                  const SizedBox(height: 20),
                  const _CustomerStatsRow(),
                  const SizedBox(height: 20),
                  _Toolbar(onAction: _notAvailable),
                  const SizedBox(height: 16),
                  _CustomerTable(customers: pageItems),
                  const SizedBox(height: 12),
                  _PaginationFooter(
                    total: filtered.length,
                    page: page,
                    pageCount: pageCount,
                    pageSize: _pageSize,
                    onPageChange: (p) => setState(() => _page = p),
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

class _CustomerTopBar extends StatelessWidget {
  final AppUser user;
  final ValueChanged<String> onSearchChanged;
  const _CustomerTopBar({required this.user, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Pelanggan',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          'Kelola data pelanggan, transaksi dan saldo pelanggan',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12.5, color: Colors.black54),
        ),
      ],
    );

    final searchBar = Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.black38, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Cari nama, nomor telepon, atau kode pelanggan...',
                hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );

    final rightCluster = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: const Stack(
            children: [
              Center(child: Icon(Icons.notifications_none_rounded, size: 20)),
              Positioned(
                right: 9,
                top: 9,
                child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF0066FF),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Text(
              user.role,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ],
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 760) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: title),
              const SizedBox(width: 20),
              SizedBox(width: 320, child: searchBar),
              const SizedBox(width: 20),
              rightCluster,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            const SizedBox(height: 12),
            searchBar,
            const SizedBox(height: 12),
            rightCluster,
          ],
        );
      },
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final String delta;
  final bool positive;
  final IconData icon;
  final Color color;
  const _StatData(
    this.label,
    this.value,
    this.delta,
    this.positive,
    this.icon,
    this.color,
  );
}

class _CustomerStatsRow extends StatelessWidget {
  const _CustomerStatsRow();

  static const _stats = [
    _StatData(
      'Total Pelanggan',
      '1.248',
      '+12%',
      true,
      Icons.people_alt_rounded,
      Color(0xFF2F6BFF),
    ),
    _StatData(
      'Pelanggan Aktif',
      '980',
      '+8%',
      true,
      Icons.person_outline_rounded,
      Color(0xFF22C55E),
    ),
    _StatData(
      'Pelanggan Baru',
      '45',
      '+25%',
      true,
      Icons.person_add_alt_1_rounded,
      Color(0xFFFF7A1A),
    ),
    _StatData(
      'Pelanggan Nonaktif',
      '223',
      '-5%',
      false,
      Icons.person_off_outlined,
      Color(0xFF8B5CF6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 640
            ? 4
            : (constraints.maxWidth >= 420 ? 2 : 1);
        final cardWidth = (constraints.maxWidth - (cols - 1) * 16) / cols;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final s in _stats)
              SizedBox(
                width: cardWidth,
                child: _StatCard(data: s),
              ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.label,
                  style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                ),
                Text(
                  data.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color:
                  (data.positive
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFE53935))
                      .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data.delta,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: data.positive
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFE53935),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  final ValueChanged<String> onAction;
  const _Toolbar({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => onAction('Tambah Pelanggan'),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Tambah Pelanggan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2F6BFF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => onAction('Import'),
          icon: const Icon(Icons.file_upload_outlined, size: 16),
          label: const Text('Import'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => onAction('Export'),
          icon: const Icon(Icons.file_download_outlined, size: 16),
          label: const Text('Export'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomerTable extends StatelessWidget {
  final List<Customer> customers;
  const _CustomerTable({required this.customers});

  static const _headerStyle = TextStyle(
    fontSize: 11.5,
    color: Colors.black45,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 920,
          child: Column(
            children: [
              const Row(
                children: [
                  SizedBox(width: 32, child: Text('No', style: _headerStyle)),
                  Expanded(flex: 2, child: Text('Kode', style: _headerStyle)),
                  Expanded(
                    flex: 4,
                    child: Text('Nama Pelanggan', style: _headerStyle),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('No. Telepon', style: _headerStyle),
                  ),
                  Expanded(flex: 4, child: Text('Email', style: _headerStyle)),
                  Expanded(flex: 2, child: Text('Tipe', style: _headerStyle)),
                  Expanded(flex: 3, child: Text('Saldo', style: _headerStyle)),
                  Expanded(
                    flex: 2,
                    child: Text('Transaksi', style: _headerStyle),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('Terakhir', style: _headerStyle),
                  ),
                  Expanded(flex: 2, child: Text('Status', style: _headerStyle)),
                  SizedBox(width: 70, child: Text('Aksi', style: _headerStyle)),
                ],
              ),
              for (var i = 0; i < customers.length; i++)
                _CustomerRow(index: i, customer: customers[i]),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerRow extends StatelessWidget {
  final int index;
  final Customer customer;
  const _CustomerRow({required this.index, required this.customer});

  @override
  Widget build(BuildContext context) {
    final isMember = customer.type == 'Member';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('${index + 1}', style: const TextStyle(fontSize: 12.5)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              customer.code,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF2F6BFF),
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(customer.phone, style: const TextStyle(fontSize: 12.5)),
          ),
          Expanded(
            flex: 4,
            child: Text(
              customer.email,
              style: const TextStyle(fontSize: 12.5),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (isMember ? const Color(0xFF2F6BFF) : Colors.black45)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                customer.type,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isMember ? const Color(0xFF2F6BFF) : Colors.black54,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              formatRupiah(customer.balance),
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${customer.totalTransactions}',
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              customer.lastTransaction,
              style: const TextStyle(fontSize: 11.5, color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color:
                    (customer.active
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFE53935))
                        .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                customer.active ? 'Aktif' : 'Nonaktif',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: customer.active
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFE53935),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Row(
              children: [
                _RowActionButton(
                  icon: Icons.edit_outlined,
                  color: const Color(0xFF2F6BFF),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit pelanggan belum tersedia'),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                _RowActionButton(
                  icon: Icons.delete_outline_rounded,
                  color: const Color(0xFFE53935),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Hapus pelanggan belum tersedia'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RowActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _RowActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final int total;
  final int page;
  final int pageCount;
  final int pageSize;
  final ValueChanged<int> onPageChange;

  const _PaginationFooter({
    required this.total,
    required this.page,
    required this.pageCount,
    required this.pageSize,
    required this.onPageChange,
  });

  Widget _pageButton({
    required Widget child,
    VoidCallback? onTap,
    bool active = false,
  }) {
    return Material(
      color: active ? const Color(0xFF2F6BFF) : Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active
                  ? Colors.transparent
                  : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final start = total == 0 ? 0 : page * pageSize + 1;
    final end = ((page + 1) * pageSize).clamp(0, total);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        Text(
          'Menampilkan $start-$end dari $total data',
          style: const TextStyle(fontSize: 12.5, color: Colors.black54),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _pageButton(
              child: const Icon(Icons.chevron_left_rounded, size: 16),
              onTap: page > 0 ? () => onPageChange(page - 1) : null,
            ),
            const SizedBox(width: 6),
            for (var i = 0; i < pageCount; i++) ...[
              _pageButton(
                active: i == page,
                onTap: () => onPageChange(i),
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: i == page ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            _pageButton(
              child: const Icon(Icons.chevron_right_rounded, size: 16),
              onTap: page < pageCount - 1 ? () => onPageChange(page + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}
