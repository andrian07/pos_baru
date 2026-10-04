import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/currency.dart';
import '../widgets/app_nav.dart';
import '../widgets/app_sidebar.dart';
import 'login_screen.dart';

const _pageSizeOptions = [10, 25, 50];
const _metodeList = ['Tunai', 'Transfer', 'E-Wallet'];
const _kasirList = ['Andrian', 'Rizky', 'Sari'];

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

String _metodeFor(int index) => _metodeList[index % _metodeList.length];
String _kasirFor(int index) => _kasirList[index % _kasirList.length];

class ReportScreen extends StatefulWidget {
  final AppUser user;
  const ReportScreen({super.key, required this.user});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedTab = 'Penjualan';
  String _searchQuery = '';
  int _page = 0;
  int _pageSize = 10;
  final Set<String> _selectedIds = {};

  List<AppTransaction> get _filtered {
    final q = _searchQuery.toLowerCase();
    return transactionCatalog.where((t) {
      final matchesSearch =
          q.isEmpty ||
          t.id.toLowerCase().contains(q) ||
          t.customerName.toLowerCase().contains(q) ||
          t.item.toLowerCase().contains(q);
      return matchesSearch;
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

    final totalPenjualan = filtered.fold<int>(0, (s, t) => s + t.total);
    final labaKotor = (totalPenjualan * 0.2).round();
    final uniqueCustomers = filtered.map((t) => t.customerName).toSet().length;
    final totalQty = filtered.fold<int>(0, (s, t) => s + t.qty);
    final rataRata = filtered.isEmpty ? 0 : (totalPenjualan / filtered.length).round();

    final metodeCounts = <String, int>{};
    for (var i = 0; i < filtered.length; i++) {
      final m = _metodeFor(transactionCatalog.indexOf(filtered[i]));
      metodeCounts[m] = (metodeCounts[m] ?? 0) + 1;
    }
    String pct(String key) {
      if (filtered.isEmpty) return '0%';
      final c = metodeCounts[key] ?? 0;
      return '${(c / filtered.length * 100).round()}%';
    }

    final summary = _ReportSummary(
      totalTransaksi: filtered.length,
      totalPenjualan: totalPenjualan,
      labaKotor: labaKotor,
      jumlahPelanggan: uniqueCustomers,
      rataRata: rataRata,
      totalQty: totalQty,
      pctTunai: pct('Tunai'),
      pctTransfer: pct('Transfer'),
      pctEwallet: pct('E-Wallet'),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F9),
      body: Row(
        children: [
          AppSidebar(
            items: appNavItems,
            selectedIndex: 5,
            onSelect: (i) => handleAppNavSelect(context, i, widget.user),
            onLogout: _handleLogout,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReportTopBar(user: widget.user, onAction: _notAvailable),
                  const SizedBox(height: 20),
                  _ReportTabs(
                    selected: _selectedTab,
                    onSelect: (c) => setState(() => _selectedTab = c),
                  ),
                  const SizedBox(height: 16),
                  _FilterPanel(
                    searchQuery: _searchQuery,
                    onSearchChanged: (v) => setState(() {
                      _searchQuery = v;
                      _page = 0;
                    }),
                    onAction: _notAvailable,
                  ),
                  const SizedBox(height: 20),
                  _ReportStatsRow(summary: summary),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 1100;
                      final content = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TransactionListCard(
                            transactions: pageItems,
                            total: filtered.length,
                            page: page,
                            pageCount: pageCount,
                            pageSize: _pageSize,
                            selectedIds: _selectedIds,
                            onToggleSelect: (id) => setState(() {
                              if (_selectedIds.contains(id)) {
                                _selectedIds.remove(id);
                              } else {
                                _selectedIds.add(id);
                              }
                            }),
                            onPageChange: (p) => setState(() => _page = p),
                            onPageSizeChange: (s) => setState(() {
                              _pageSize = s;
                              _page = 0;
                            }),
                            onAction: _notAvailable,
                          ),
                        ],
                      );
                      final sidebar = _ReportSidePanel(
                        summary: summary,
                        onAction: _notAvailable,
                      );

                      if (!isWide) {
                        return Column(
                          children: [
                            content,
                            const SizedBox(height: 20),
                            sidebar,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: content),
                          const SizedBox(width: 20),
                          SizedBox(width: 320, child: sidebar),
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

class _ReportSummary {
  final int totalTransaksi;
  final int totalPenjualan;
  final int labaKotor;
  final int jumlahPelanggan;
  final int rataRata;
  final int totalQty;
  final String pctTunai;
  final String pctTransfer;
  final String pctEwallet;
  const _ReportSummary({
    required this.totalTransaksi,
    required this.totalPenjualan,
    required this.labaKotor,
    required this.jumlahPelanggan,
    required this.rataRata,
    required this.totalQty,
    required this.pctTunai,
    required this.pctTransfer,
    required this.pctEwallet,
  });
}

class _ReportTopBar extends StatelessWidget {
  final AppUser user;
  final ValueChanged<String> onAction;
  const _ReportTopBar({required this.user, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;

        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Laporan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text(
              'Cetak dan export laporan penjualan, transaksi, produk, pelanggan dan lainnya',
              style: TextStyle(fontSize: 12.5, color: Colors.black54),
            ),
          ],
        );

        final bellButton = Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: const Stack(
            children: [
              Center(child: Icon(Icons.notifications_none_rounded, size: 20)),
              Positioned(
                right: 10,
                top: 10,
                child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
              ),
            ],
          ),
        );

        final avatarPill = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF0066FF),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Colors.black38,
              ),
            ],
          ),
        );

        final exportButton = PopupMenuButton<String>(
          onSelected: onAction,
          offset: const Offset(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'Export ke PDF',
              child: _ExportMenuTile(
                icon: Icons.picture_as_pdf_rounded,
                color: Color(0xFFE53935),
                title: 'Export ke PDF',
                subtitle: 'Laporan dalam format PDF',
              ),
            ),
            const PopupMenuItem(
              value: 'Export ke Excel',
              child: _ExportMenuTile(
                icon: Icons.grid_on_rounded,
                color: Color(0xFF22C55E),
                title: 'Export ke Excel',
                subtitle: 'Laporan dalam format Excel (XLSX)',
              ),
            ),
            const PopupMenuItem(
              value: 'Cetak Langsung',
              child: _ExportMenuTile(
                icon: Icons.print_rounded,
                color: Color(0xFF2F6BFF),
                title: 'Cetak Langsung',
                subtitle: 'Cetak ke printer',
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFF2F6BFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.file_download_outlined, color: Colors.white, size: 17),
                SizedBox(width: 8),
                Text(
                  'Export',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
        );

        final printButton = OutlinedButton.icon(
          onPressed: () => onAction('Cetak'),
          icon: const Icon(Icons.print_outlined, size: 17),
          label: const Text('Cetak'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        final rightCluster = Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [bellButton, avatarPill, exportButton, printButton],
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: title),
              const SizedBox(width: 20),
              rightCluster,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            const SizedBox(height: 14),
            rightCluster,
          ],
        );
      },
    );
  }
}

class _ExportMenuTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _ExportMenuTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReportTab {
  final IconData icon;
  final String label;
  const _ReportTab(this.icon, this.label);
}

class _ReportTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _ReportTabs({required this.selected, required this.onSelect});

  static const _tabs = [
    _ReportTab(Icons.shopping_cart_rounded, 'Penjualan'),
    _ReportTab(Icons.inventory_2_rounded, 'Produk'),
    _ReportTab(Icons.people_alt_rounded, 'Pelanggan'),
    _ReportTab(Icons.smartphone_rounded, 'Pulsa & Data'),
    _ReportTab(Icons.bolt_rounded, 'PLN & PDAM'),
    _ReportTab(Icons.sports_esports_rounded, 'Voucher Game'),
    _ReportTab(Icons.account_balance_wallet_rounded, 'Pembayaran'),
    _ReportTab(Icons.insert_drive_file_rounded, 'Lainnya'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final t in _tabs) ...[
            _TabChip(
              icon: t.icon,
              label: t.label,
              isSelected: t.label == selected,
              onTap: () => onSelect(t.label),
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _TabChip({
    required this.icon,
    required this.label,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.black54,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onAction;
  const _FilterPanel({
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _FilterPill(
                icon: Icons.calendar_today_rounded,
                label: '01 Okt 2026 - 04 Okt 2026',
                onTap: () => onAction('Pilih tanggal'),
              ),
              _FilterPill(
                icon: Icons.store_rounded,
                label: 'Semua Cabang',
                onTap: () => onAction('Pilih cabang'),
              ),
              _FilterPill(
                icon: Icons.badge_rounded,
                label: 'Semua Kasir',
                onTap: () => onAction('Pilih kasir'),
              ),
              _FilterPill(
                icon: Icons.payments_rounded,
                label: 'Semua Metode',
                onTap: () => onAction('Pilih metode'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;

              final tipePill = _FilterPill(
                icon: Icons.category_rounded,
                label: 'Semua Tipe',
                onTap: () => onAction('Pilih tipe'),
              );

              final searchField = Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
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
                          hintText: 'Cari nomor transaksi, pelanggan, atau produk...',
                          hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );

              final terapkanButton = ElevatedButton(
                onPressed: () => onAction('Terapkan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F6BFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Terapkan'),
              );

              final resetButton = OutlinedButton.icon(
                onPressed: () => onAction('Reset'),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );

              if (isWide) {
                return Row(
                  children: [
                    SizedBox(width: 180, child: tipePill),
                    const SizedBox(width: 12),
                    Expanded(child: searchField),
                    const SizedBox(width: 12),
                    terapkanButton,
                    const SizedBox(width: 12),
                    resetButton,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  tipePill,
                  const SizedBox(height: 12),
                  searchField,
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: terapkanButton),
                      const SizedBox(width: 12),
                      Expanded(child: resetButton),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _FilterPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F8FB),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF2F6BFF)),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 12.5)),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCardData {
  final String title;
  final String value;
  final String delta;
  final IconData icon;
  final Color color;
  const _StatCardData(
    this.title,
    this.value,
    this.delta,
    this.icon,
    this.color,
  );
}

class _ReportStatsRow extends StatelessWidget {
  final _ReportSummary summary;
  const _ReportStatsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCardData(
        'Total Transaksi',
        summary.totalTransaksi.toString(),
        '12%',
        Icons.shopping_cart_rounded,
        const Color(0xFF2F6BFF),
      ),
      _StatCardData(
        'Total Penjualan',
        formatRupiah(summary.totalPenjualan),
        '18%',
        Icons.attach_money_rounded,
        const Color(0xFF22C55E),
      ),
      _StatCardData(
        'Total Laba Kotor',
        formatRupiah(summary.labaKotor),
        '15%',
        Icons.monetization_on_rounded,
        const Color(0xFFFFB020),
      ),
      _StatCardData(
        'Jumlah Pelanggan',
        summary.jumlahPelanggan.toString(),
        '8%',
        Icons.people_alt_rounded,
        const Color(0xFF8B5CF6),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 900
            ? 4
            : (constraints.maxWidth >= 560 ? 2 : 1);
        final cardWidth = (constraints.maxWidth - (cols - 1) * 16) / cols;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final c in cards)
              SizedBox(width: cardWidth, child: _ReportStatCard(data: c)),
          ],
        );
      },
    );
  }
}

class _ReportStatCard extends StatelessWidget {
  final _StatCardData data;
  const _ReportStatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_upward_rounded,
                  size: 11,
                  color: Color(0xFF16A34A),
                ),
                Text(
                  data.delta,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF16A34A),
                    fontWeight: FontWeight.w600,
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

class _TransactionListCard extends StatelessWidget {
  final List<AppTransaction> transactions;
  final int total;
  final int page;
  final int pageCount;
  final int pageSize;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggleSelect;
  final ValueChanged<int> onPageChange;
  final ValueChanged<int> onPageSizeChange;
  final ValueChanged<String> onAction;

  const _TransactionListCard({
    required this.transactions,
    required this.total,
    required this.page,
    required this.pageCount,
    required this.pageSize,
    required this.selectedIds,
    required this.onToggleSelect,
    required this.onPageChange,
    required this.onPageSizeChange,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              const Text(
                'Daftar Transaksi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Tampilkan', style: TextStyle(fontSize: 12.5)),
                  const SizedBox(width: 8),
                  PopupMenuButton<int>(
                    initialValue: pageSize,
                    onSelected: onPageSizeChange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    itemBuilder: (context) => [
                      for (final s in _pageSizeOptions)
                        PopupMenuItem(value: s, child: Text('$s data')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$pageSize data', style: const TextStyle(fontSize: 12.5)),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _ViewToggle(onAction: onAction),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 980,
              child: Column(
                children: [
                  const _ReportTableHeader(),
                  if (transactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Tidak ada transaksi',
                        style: TextStyle(color: Colors.black45),
                      ),
                    )
                  else
                    for (var i = 0; i < transactions.length; i++)
                      _ReportTableRow(
                        no: page * pageSize + i + 1,
                        transaction: transactions[i],
                        metode: _metodeFor(transactionCatalog.indexOf(transactions[i])),
                        kasir: _kasirFor(transactionCatalog.indexOf(transactions[i])),
                        selected: selectedIds.contains(transactions[i].id),
                        onToggle: () => onToggleSelect(transactions[i].id),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _PaginationFooter(
            total: total,
            page: page,
            pageCount: pageCount,
            pageSize: pageSize,
            onPageChange: onPageChange,
          ),
        ],
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final ValueChanged<String> onAction;
  const _ViewToggle({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2F6BFF),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(7),
              ),
            ),
            child: const Icon(Icons.view_list_rounded, size: 16, color: Colors.white),
          ),
          InkWell(
            onTap: () => onAction('Tampilan grid'),
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(7)),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.grid_view_rounded, size: 16, color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }
}

const _reportHeaderStyle = TextStyle(
  fontSize: 11.5,
  color: Colors.black45,
  fontWeight: FontWeight.w600,
);

class _ReportTableHeader extends StatelessWidget {
  const _ReportTableHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const SizedBox(width: 28, child: Icon(Icons.crop_square_rounded, size: 16, color: Colors.black26)),
          const SizedBox(width: 32, child: Text('No.', style: _reportHeaderStyle)),
          Expanded(flex: 3, child: const Text('No. Transaksi', style: _reportHeaderStyle)),
          Expanded(flex: 2, child: const Text('Tanggal', style: _reportHeaderStyle)),
          Expanded(flex: 3, child: const Text('Pelanggan', style: _reportHeaderStyle)),
          Expanded(flex: 2, child: const Text('Jenis', style: _reportHeaderStyle)),
          Expanded(flex: 3, child: const Text('Produk / Layanan', style: _reportHeaderStyle)),
          Expanded(flex: 2, child: const Text('Total', style: _reportHeaderStyle)),
          Expanded(flex: 2, child: const Text('Metode', style: _reportHeaderStyle)),
          Expanded(flex: 2, child: const Text('Kasir', style: _reportHeaderStyle)),
          Expanded(flex: 2, child: const Text('Status', style: _reportHeaderStyle)),
        ],
      ),
    );
  }
}

class _ReportTableRow extends StatelessWidget {
  final int no;
  final AppTransaction transaction;
  final String metode;
  final String kasir;
  final bool selected;
  final VoidCallback onToggle;

  const _ReportTableRow({
    required this.no,
    required this.transaction,
    required this.metode,
    required this.kasir,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _categoryMeta[transaction.category]!;
    final isSuccess = transaction.status == 'Berhasil';

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
            width: 28,
            child: Checkbox(
              value: selected,
              onChanged: (_) => onToggle(),
              visualDensity: VisualDensity.compact,
            ),
          ),
          SizedBox(
            width: 32,
            child: Text('$no', style: const TextStyle(fontSize: 12.5)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              transaction.id,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
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
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: meta.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(meta.icon, size: 12, color: Colors.white),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    transaction.category,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
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
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(metode, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Text(kasir, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (isSuccess ? const Color(0xFF22C55E) : const Color(0xFFFFB020))
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                transaction.status,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isSuccess ? const Color(0xFF16A34A) : const Color(0xFFB45309),
                ),
              ),
            ),
          ),
        ],
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
              color: active ? Colors.transparent : Colors.black.withValues(alpha: 0.1),
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

class _ReportSidePanel extends StatelessWidget {
  final _ReportSummary summary;
  final ValueChanged<String> onAction;
  const _ReportSidePanel({required this.summary, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryCard(summary: summary),
        const SizedBox(height: 20),
        _QuickActionsCard(onAction: onAction),
        const SizedBox(height: 20),
        const _InfoCard(),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final _ReportSummary summary;
  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Jumlah Transaksi', summary.totalTransaksi.toString()),
      ('Total Penjualan', formatRupiah(summary.totalPenjualan)),
      ('Total Laba Kotor', formatRupiah(summary.labaKotor)),
      ('Rata-rata Transaksi', formatRupiah(summary.rataRata)),
      ('Jumlah Produk Terjual', summary.totalQty.toString()),
      ('Pelanggan Unik', summary.jumlahPelanggan.toString()),
      ('Transaksi Tunai', summary.pctTunai),
      ('Transaksi Transfer', summary.pctTransfer),
      ('Transaksi E-Wallet', summary.pctEwallet),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Laporan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  rows[i].$1,
                  style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                ),
                Text(
                  rows[i].$2,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  final ValueChanged<String> onAction;
  const _QuickActionsCard({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aksi Cepat',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.picture_as_pdf_rounded,
                  label: 'Export ke PDF',
                  color: const Color(0xFFE53935),
                  filled: true,
                  onTap: () => onAction('Export ke PDF'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.grid_on_rounded,
                  label: 'Export ke Excel',
                  color: const Color(0xFF22C55E),
                  filled: true,
                  onTap: () => onAction('Export ke Excel'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.print_outlined,
                  label: 'Cetak Laporan',
                  color: Colors.black87,
                  filled: false,
                  onTap: () => onAction('Cetak Laporan'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.view_column_rounded,
                  label: 'Atur Kolom',
                  color: Colors.black87,
                  filled: false,
                  onTap: () => onAction('Atur Kolom'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? color.withValues(alpha: 0.1) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: filled
                ? null
                : Border.all(color: Colors.black.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_rounded, color: Color(0xFF2F6BFF), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Informasi',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Laporan dapat di export dalam format PDF atau Excel sesuai dengan filter yang dipilih.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
