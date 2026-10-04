import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/currency.dart';
import '../widgets/app_nav.dart';
import '../widgets/app_sidebar.dart';
import 'login_screen.dart';

const _pageSize = 10;

class _CategoryMeta {
  final IconData icon;
  final Color color;
  const _CategoryMeta(this.icon, this.color);
}

const _categoryMeta = {
  'PLN': _CategoryMeta(Icons.bolt_rounded, Color(0xFFFFB020)),
  'Pulsa': _CategoryMeta(Icons.phone_android_rounded, Color(0xFFE4002B)),
  'Produk': _CategoryMeta(Icons.shopping_bag_rounded, Color(0xFF2F6BFF)),
  'Game': _CategoryMeta(Icons.sports_esports_rounded, Color(0xFF8B5CF6)),
  'PDAM': _CategoryMeta(Icons.water_drop_rounded, Color(0xFF29B6F6)),
};

class HistoryScreen extends StatefulWidget {
  final AppUser user;
  const HistoryScreen({super.key, required this.user});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  int _page = 0;
  String? _selectedId;

  List<AppTransaction> get _filtered {
    return transactionCatalog.where((t) {
      final matchesCategory =
          _selectedCategory == 'Semua' || t.category == _selectedCategory;
      final q = _searchQuery.toLowerCase();
      final matchesSearch =
          q.isEmpty ||
          t.id.toLowerCase().contains(q) ||
          t.customerName.toLowerCase().contains(q) ||
          t.item.toLowerCase().contains(q);
      return matchesCategory && matchesSearch;
    }).toList();
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
    final selected =
        transactionCatalog
            .where((t) => t.id == _selectedId)
            .toList()
            .firstOrNull ??
        (pageItems.isNotEmpty ? pageItems.first : null);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F9),
      body: Row(
        children: [
          AppSidebar(
            items: appNavItems,
            selectedIndex: 4,
            onSelect: (i) => handleAppNavSelect(context, i, widget.user),
            onLogout: _handleLogout,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HistoryTopBar(
                    user: widget.user,
                    onSearchChanged: (v) => setState(() {
                      _searchQuery = v;
                      _page = 0;
                    }),
                    onAction: _notAvailable,
                  ),
                  const SizedBox(height: 20),
                  const _StatsRow(),
                  const SizedBox(height: 20),
                  _CategoryTabs(
                    selected: _selectedCategory,
                    onSelect: (c) => setState(() {
                      _selectedCategory = c;
                      _page = 0;
                    }),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final table = Column(
                        children: [
                          _TransactionTable(
                            transactions: pageItems,
                            selectedId: selected?.id,
                            onSelect: (id) => setState(() => _selectedId = id),
                          ),
                          const SizedBox(height: 12),
                          _PaginationFooter(
                            total: filtered.length,
                            page: page,
                            pageCount: pageCount,
                            pageSize: _pageSize,
                            onPageChange: (p) => setState(() => _page = p),
                          ),
                        ],
                      );
                      final detail = selected == null
                          ? const SizedBox.shrink()
                          : _DetailPanel(
                              transaction: selected,
                              onClose: () => setState(() => _selectedId = null),
                              onAction: _notAvailable,
                            );

                      if (constraints.maxWidth < 760) {
                        return Column(
                          children: [
                            table,
                            if (selected != null) ...[
                              const SizedBox(height: 20),
                              detail,
                            ],
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: table),
                          if (selected != null) ...[
                            const SizedBox(width: 20),
                            SizedBox(width: 360, child: detail),
                          ],
                        ],
                      );
                    },
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

class _HistoryTopBar extends StatelessWidget {
  final AppUser user;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onAction;
  const _HistoryTopBar({
    required this.user,
    required this.onSearchChanged,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        final title = const Text(
          'Riwayat Transaksi',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                    hintText: 'Cari no transaksi, nama pelanggan, produk...',
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
                  Center(
                    child: Icon(Icons.notifications_none_rounded, size: 20),
                  ),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  user.role,
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ],
        );

        final toolRow = Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 15,
                    color: Color(0xFF2F6BFF),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '01 Okt 2026 - 04 Okt 2026',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => onAction('Filter'),
              icon: const Icon(Icons.filter_list_rounded, size: 16),
              label: const Text('Filter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F6BFF),
                foregroundColor: Colors.white,
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

        if (isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 20),
                  SizedBox(width: 320, child: searchBar),
                  const SizedBox(width: 20),
                  rightCluster,
                ],
              ),
              const SizedBox(height: 14),
              Align(alignment: Alignment.centerRight, child: toolRow),
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
            const SizedBox(height: 12),
            toolRow,
          ],
        );
      },
    );
  }
}

class _StatInfo {
  final String label;
  final String value;
  final String? delta;
  final String? subtitle;
  final IconData icon;
  final Color color;
  const _StatInfo(
    this.label,
    this.value,
    this.delta,
    this.subtitle,
    this.icon,
    this.color,
  );
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  static const _stats = [
    _StatInfo(
      'Total Transaksi',
      '1.248',
      '+12%',
      'Dari periode sebelumnya',
      Icons.shopping_cart_rounded,
      Color(0xFF2F6BFF),
    ),
    _StatInfo(
      'Total Penjualan',
      'Rp 12.350.000',
      '+18%',
      null,
      Icons.payments_rounded,
      Color(0xFF22C55E),
    ),
    _StatInfo(
      'Pulsa & Paket Data',
      'Rp 4.250.000',
      null,
      '320 transaksi',
      Icons.phone_android_rounded,
      Color(0xFF8B5CF6),
    ),
    _StatInfo(
      'PLN & PDAM',
      'Rp 3.750.000',
      null,
      '180 transaksi',
      Icons.bolt_rounded,
      Color(0xFFFFB020),
    ),
    _StatInfo(
      'Voucher Game',
      'Rp 4.350.000',
      null,
      '210 transaksi',
      Icons.sports_esports_rounded,
      Color(0xFFFF5C93),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 1100
            ? 5
            : (constraints.maxWidth >= 700
                  ? 3
                  : (constraints.maxWidth >= 420 ? 2 : 1));
        final cardWidth = (constraints.maxWidth - (cols - 1) * 14) / cols;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
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
  final _StatInfo data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.label,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  data.value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (data.delta != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data.delta!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF16A34A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (data.subtitle != null)
                  Text(
                    data.subtitle!,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Colors.black45,
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

class _CategoryTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _CategoryTabs({required this.selected, required this.onSelect});

  static const _tabs = [
    ('Semua', '1.248'),
    ('Produk', '398'),
    ('Pulsa', '320'),
    ('PLN', '180'),
    ('PDAM', '120'),
    ('Game', '210'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final t in _tabs) ...[
            _Tab(
              label: t.$1,
              count: t.$2,
              isSelected: t.$1 == selected,
              onTap: () => onSelect(t.$1),
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final String count;
  final bool isSelected;
  final VoidCallback onTap;
  const _Tab({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFF2F6BFF) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : const Color(0xFFF2F4F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTable extends StatelessWidget {
  final List<AppTransaction> transactions;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  const _TransactionTable({
    required this.transactions,
    required this.selectedId,
    required this.onSelect,
  });

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
          width: 860,
          child: Column(
            children: [
              const Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text('No. Transaksi', style: _headerStyle),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('Tanggal / Waktu', style: _headerStyle),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('Pelanggan', style: _headerStyle),
                  ),
                  Expanded(flex: 2, child: Text('Jenis', style: _headerStyle)),
                  Expanded(
                    flex: 3,
                    child: Text('Produk / Layanan', style: _headerStyle),
                  ),
                  Expanded(flex: 2, child: Text('Total', style: _headerStyle)),
                  Expanded(flex: 2, child: Text('Status', style: _headerStyle)),
                ],
              ),
              if (transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Tidak ada transaksi',
                    style: TextStyle(color: Colors.black45),
                  ),
                )
              else
                for (final t in transactions)
                  _TransactionRow(
                    transaction: t,
                    selected: t.id == selectedId,
                    onTap: () => onSelect(t.id),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final AppTransaction transaction;
  final bool selected;
  final VoidCallback onTap;
  const _TransactionRow({
    required this.transaction,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _categoryMeta[transaction.category]!;
    final isSuccess = transaction.status == 'Berhasil';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF4FF) : null,
          border: Border(
            top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                transaction.id,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                transaction.dateTime,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: const Color(0xFF2F6BFF),
                    child: Text(
                      transaction.customerName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      transaction.customerName,
                      style: const TextStyle(fontSize: 12.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: meta.color,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(meta.icon, size: 13, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    transaction.category,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                transaction.item,
                style: const TextStyle(fontSize: 12.5),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                formatRupiah(transaction.total),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      (isSuccess
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFFFB020))
                          .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  transaction.status,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isSuccess
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFB45309),
                  ),
                ),
              ),
            ),
          ],
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
          'Menampilkan $start-$end dari $total transaksi',
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

class _DetailPanel extends StatelessWidget {
  final AppTransaction transaction;
  final VoidCallback onClose;
  final ValueChanged<String> onAction;
  const _DetailPanel({
    required this.transaction,
    required this.onClose,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _categoryMeta[transaction.category]!;
    final isSuccess = transaction.status == 'Berhasil';
    final subtotal = transaction.price * transaction.qty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Detail Transaksi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              InkWell(
                onTap: onClose,
                child: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: meta.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(meta.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      transaction.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    Text(
                      transaction.dateTime,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      (isSuccess
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFFFB020))
                          .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  transaction.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSuccess
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Informasi Pelanggan',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF2F6BFF),
                child: Text(
                  transaction.customerName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      transaction.customerName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${transaction.customerType} (${transaction.customerCode})',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      transaction.customerPhone,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Detail Produk / Layanan',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        transaction.item,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        transaction.itemSubtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    'x${transaction.qty}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    formatRupiah(subtotal),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontSize: 12.5, color: Colors.black54),
              ),
              Text(
                formatRupiah(subtotal),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Biaya Admin',
                style: TextStyle(fontSize: 12.5, color: Colors.black54),
              ),
              Text(
                formatRupiah(transaction.adminFee),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  formatRupiah(transaction.total),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A66FF),
                  ),
                ),
              ],
            ),
          ),
          if (transaction.balanceBefore > 0 ||
              transaction.balanceAfter > 0) ...[
            const SizedBox(height: 18),
            const Text(
              'Informasi Pembayaran',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const _InfoRow(label: 'Metode Pembayaran', value: 'Saldo Tenant'),
            const SizedBox(height: 4),
            _InfoRow(
              label: 'Saldo Sebelum',
              value: formatRupiah(transaction.balanceBefore),
            ),
            const SizedBox(height: 4),
            _InfoRow(
              label: 'Saldo Sesudah',
              value: formatRupiah(transaction.balanceAfter),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onAction('Cetak Struk'),
                  icon: const Icon(Icons.print_outlined, size: 15),
                  label: const Text('Cetak', style: TextStyle(fontSize: 12.5)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onAction('Kirim Struk'),
                  icon: const Icon(Icons.send_outlined, size: 15),
                  label: const Text('Kirim', style: TextStyle(fontSize: 12.5)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onAction('Batalkan transaksi'),
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: Color(0xFFE53935),
                  ),
                  label: const Text(
                    'Batal',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFFE53935)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE53935)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
