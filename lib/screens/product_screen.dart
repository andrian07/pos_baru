import 'package:flutter/material.dart';

import '../models/catalog_item.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/currency.dart';
import '../widgets/app_nav.dart';
import '../widgets/app_sidebar.dart';
import 'login_screen.dart';

const _pageSize = 15;

class ProductScreen extends StatefulWidget {
  final AppUser user;
  const ProductScreen({super.key, required this.user});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  int _page = 0;
  bool _gridView = true;

  List<CatalogItem> get _filtered {
    return fullCatalog.where((p) {
      final matchesCategory =
          _selectedCategory == 'Semua' || p.category == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  int _countFor(String category) {
    if (category == 'Semua') return fullCatalog.length;
    return fullCatalog.where((p) => p.category == category).length;
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
            selectedIndex: 2,
            onSelect: (i) => handleAppNavSelect(context, i, widget.user),
            onLogout: _handleLogout,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProductTopBar(
                    user: widget.user,
                    onSearchChanged: (v) => setState(() {
                      _searchQuery = v;
                      _page = 0;
                    }),
                  ),
                  const SizedBox(height: 16),
                  _CategoryChipsRow(
                    selected: _selectedCategory,
                    countFor: _countFor,
                    onSelect: (c) => setState(() {
                      _selectedCategory = c;
                      _page = 0;
                    }),
                  ),
                  const SizedBox(height: 16),
                  _Toolbar(
                    gridView: _gridView,
                    onToggleView: (grid) => setState(() => _gridView = grid),
                    onAction: _notAvailable,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: pageItems.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak ada produk',
                              style: TextStyle(color: Colors.black45),
                            ),
                          )
                        : SingleChildScrollView(
                            child: _gridView
                                ? _ProductGrid(items: pageItems)
                                : _ProductList(items: pageItems),
                          ),
                  ),
                  const SizedBox(height: 12),
                  _PaginationRow(
                    total: filtered.length,
                    page: page,
                    pageCount: pageCount,
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

class _ProductTopBar extends StatelessWidget {
  final AppUser user;
  final ValueChanged<String> onSearchChanged;
  const _ProductTopBar({required this.user, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Produk',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          'Kelola data produk, kategori, stok dan harga penjualan',
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
                hintText: 'Cari produk, barcode, atau kategori...',
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

class _CategoryInfo {
  final String label;
  final IconData icon;
  final Color color;
  const _CategoryInfo(this.label, this.icon, this.color);
}

const _categoryMeta = [
  _CategoryInfo('Semua', Icons.apps_rounded, Color(0xFF2F6BFF)),
  _CategoryInfo('Makanan', Icons.restaurant_rounded, Color(0xFFFF7A3D)),
  _CategoryInfo('Minuman', Icons.local_cafe_rounded, Color(0xFF29B6F6)),
  _CategoryInfo('Snack', Icons.icecream_rounded, Color(0xFFFFB020)),
  _CategoryInfo('Rokok', Icons.smoking_rooms_rounded, Color(0xFF64748B)),
  _CategoryInfo('ATK', Icons.edit_rounded, Color(0xFF2F6BFF)),
  _CategoryInfo('Elektronik', Icons.devices_rounded, Color(0xFF8B5CF6)),
  _CategoryInfo('Perlengkapan', Icons.shopping_bag_rounded, Color(0xFFFF5C93)),
  _CategoryInfo('Pulsa', Icons.phone_android_rounded, Color(0xFFE4002B)),
  _CategoryInfo('Paket Data', Icons.public_rounded, Color(0xFF1C64F2)),
  _CategoryInfo('Token PLN', Icons.bolt_rounded, Color(0xFFFFB020)),
  _CategoryInfo('PDAM', Icons.water_drop_rounded, Color(0xFF29B6F6)),
  _CategoryInfo(
    'Voucher Game',
    Icons.sports_esports_rounded,
    Color(0xFF8B5CF6),
  ),
];

class _CategoryChipsRow extends StatelessWidget {
  final String selected;
  final int Function(String) countFor;
  final ValueChanged<String> onSelect;
  const _CategoryChipsRow({
    required this.selected,
    required this.countFor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final c in _categoryMeta) ...[
            _CategoryChip(
              info: c,
              count: countFor(c.label),
              isSelected: c.label == selected,
              onTap: () => onSelect(c.label),
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final _CategoryInfo info;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.info,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFF2F6BFF) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : info.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  info.icon,
                  size: 15,
                  color: isSelected ? Colors.white : info.color,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    info.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    '$count produk',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.black45,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  final bool gridView;
  final ValueChanged<bool> onToggleView;
  final ValueChanged<String> onAction;
  const _Toolbar({
    required this.gridView,
    required this.onToggleView,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => onAction('Tambah Produk'),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Tambah Produk'),
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
        OutlinedButton.icon(
          onPressed: () => onAction('Kategori'),
          icon: const Icon(Icons.category_outlined, size: 16),
          label: const Text('Kategori'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ViewToggleButton(
              icon: Icons.grid_view_rounded,
              selected: gridView,
              onTap: () => onToggleView(true),
            ),
            const SizedBox(width: 6),
            _ViewToggleButton(
              icon: Icons.view_list_rounded,
              selected: !gridView,
              onTap: () => onToggleView(false),
            ),
          ],
        ),
      ],
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ViewToggleButton({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF2F6BFF) : Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: selected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final List<CatalogItem> items;
  const _ProductGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 900
            ? 5
            : (constraints.maxWidth >= 640
                  ? 4
                  : (constraints.maxWidth >= 420 ? 3 : 2));
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, i) => _ProductCard(item: items[i]),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final CatalogItem item;
  const _ProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF2F4F9),
                padding: item.isDigital
                    ? const EdgeInsets.all(14)
                    : EdgeInsets.zero,
                child: Image.asset(
                  item.asset,
                  fit: item.isDigital ? BoxFit.contain : BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          Text(
            item.category,
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  formatRupiah(item.price),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F6BFF),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Stok: ${item.stockLabel}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF16A34A),
                    fontWeight: FontWeight.w600,
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

class _ProductList extends StatelessWidget {
  final List<CatalogItem> items;
  const _ProductList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: i == 0
                  ? null
                  : BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 40,
                      height: 40,
                      color: const Color(0xFFF2F4F9),
                      padding: items[i].isDigital
                          ? const EdgeInsets.all(6)
                          : EdgeInsets.zero,
                      child: Image.asset(
                        items[i].asset,
                        fit: items[i].isDigital ? BoxFit.contain : BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[i].name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          items[i].category,
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
                      formatRupiah(items[i].price),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    'Stok: ${items[i].stockLabel}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF16A34A),
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

class _PaginationRow extends StatelessWidget {
  final int total;
  final int page;
  final int pageCount;
  final ValueChanged<int> onPageChange;

  const _PaginationRow({
    required this.total,
    required this.page,
    required this.pageCount,
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
          width: 34,
          height: 34,
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
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        Text(
          'Total $total Produk',
          style: const TextStyle(fontSize: 12.5, color: Colors.black54),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _pageButton(
              child: const Icon(Icons.chevron_left_rounded, size: 18),
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
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: i == page ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            _pageButton(
              child: const Icon(Icons.chevron_right_rounded, size: 18),
              onTap: page < pageCount - 1 ? () => onPageChange(page + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}
