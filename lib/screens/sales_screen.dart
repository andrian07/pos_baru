import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/currency.dart';
import '../widgets/app_nav.dart';
import '../widgets/app_sidebar.dart';
import 'login_screen.dart';

class _CartLine {
  final Product product;
  int qty;
  _CartLine(this.product, this.qty);
  int get subtotal => product.price * qty;
}

class _Category {
  final String label;
  final IconData icon;
  final Color color;
  const _Category(this.label, this.icon, this.color);
}

const _categories = [
  _Category('Semua', Icons.apps_rounded, Color(0xFF2F6BFF)),
  _Category('Makanan', Icons.restaurant_rounded, Color(0xFFFF7A3D)),
  _Category('Minuman', Icons.local_cafe_rounded, Color(0xFF29B6F6)),
  _Category('Snack', Icons.icecream_rounded, Color(0xFFFFB020)),
  _Category('Rokok', Icons.smoking_rooms_rounded, Color(0xFF64748B)),
  _Category('ATK', Icons.edit_rounded, Color(0xFF2F6BFF)),
  _Category('Elektronik', Icons.devices_rounded, Color(0xFF8B5CF6)),
  _Category('Perlengkapan', Icons.shopping_bag_rounded, Color(0xFFFF5C93)),
  _Category('Lainnya', Icons.more_horiz_rounded, Color(0xFF94A3B8)),
];

const _pageSize = 12;
const _taxRate = 0.11;

class SalesScreen extends StatefulWidget {
  final AppUser user;
  const SalesScreen({super.key, required this.user});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  int _page = 0;

  final _cart = <String, _CartLine>{};
  final _customerController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _customerController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    return productCatalog.where((p) {
      final matchesCategory =
          _selectedCategory == 'Semua' || p.category == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  int get _subtotal => _cart.values.fold(0, (sum, l) => sum + l.subtotal);
  int get _tax => (_subtotal * _taxRate).round();
  int get _total => _subtotal + _tax;

  void _addToCart(Product product) {
    setState(() {
      final existing = _cart[product.id];
      if (existing != null) {
        existing.qty++;
      } else {
        _cart[product.id] = _CartLine(product, 1);
      }
    });
  }

  void _incrementQty(String productId) {
    setState(() => _cart[productId]?.qty++);
  }

  void _decrementQty(String productId) {
    setState(() {
      final line = _cart[productId];
      if (line == null) return;
      if (line.qty <= 1) {
        _cart.remove(productId);
      } else {
        line.qty--;
      }
    });
  }

  void _removeFromCart(String productId) {
    setState(() => _cart.remove(productId));
  }

  void _clearCart() {
    setState(() => _cart.clear());
  }

  Future<void> _handleLogout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;
    final pageCount = (filtered.length / _pageSize).ceil().clamp(1, 9999);
    final page = _page.clamp(0, pageCount - 1);
    final pageItems = filtered.skip(page * _pageSize).take(_pageSize).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F9),
      body: Row(
        children: [
          AppSidebar(
            items: appNavItems,
            selectedIndex: 1,
            onSelect: (i) => handleAppNavSelect(context, i, widget.user),
            onLogout: _handleLogout,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SalesTopBar(
                    user: widget.user,
                    onSearchChanged: (v) => setState(() {
                      _searchQuery = v;
                      _page = 0;
                    }),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cartPanel = _CartPanel(
                          cart: _cart.values.toList(),
                          customerController: _customerController,
                          noteController: _noteController,
                          subtotal: _subtotal,
                          tax: _tax,
                          total: _total,
                          onIncrement: _incrementQty,
                          onDecrement: _decrementQty,
                          onRemove: _removeFromCart,
                          onClearAll: _cart.isEmpty ? null : _clearCart,
                        );

                        final catalog = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CategoryChipsRow(
                              selected: _selectedCategory,
                              onSelect: (c) => setState(() {
                                _selectedCategory = c;
                                _page = 0;
                              }),
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
                                  : _ProductGrid(
                                      products: pageItems,
                                      onAdd: _addToCart,
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
                        );

                        if (constraints.maxWidth >= 760) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: catalog),
                              const SizedBox(width: 20),
                              SizedBox(width: 380, child: cartPanel),
                            ],
                          );
                        }

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 520, child: catalog),
                              const SizedBox(height: 20),
                              SizedBox(height: 520, child: cartPanel),
                            ],
                          ),
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
  }
}

class _SalesTopBar extends StatelessWidget {
  final AppUser user;
  final ValueChanged<String> onSearchChanged;
  const _SalesTopBar({required this.user, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final dateStr =
        '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    Widget pillBox(Widget child) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: child,
    );

    final title = const Text(
      'Penjualan POS',
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );

    final searchBar = Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                hintText: 'Cari produk atau scan barcode...',
                hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const Icon(Icons.qr_code_scanner, color: Colors.black38, size: 20),
        ],
      ),
    );

    final rightCluster = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        pillBox(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: Color(0xFF2F6BFF),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  Text(
                    timeStr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
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
        ),
        const SizedBox(width: 12),
        pillBox(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 18,
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
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 700) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              title,
              const SizedBox(width: 20),
              Expanded(child: searchBar),
              const SizedBox(width: 16),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: rightCluster,
            ),
          ],
        );
      },
    );
  }
}

class _CategoryChipsRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _CategoryChipsRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final c in _categories) ...[
            _CategoryChip(
              category: c,
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
  final _Category category;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.category,
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
              if (category.label != 'Semua') ...[
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : category.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category.icon,
                    size: 13,
                    color: isSelected ? Colors.white : category.color,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                category.label,
                style: TextStyle(
                  fontSize: 12.5,
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

class _ProductGrid extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onAdd;
  const _ProductGrid({required this.products, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 640
            ? 4
            : (constraints.maxWidth >= 420 ? 3 : 2);
        return GridView.builder(
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, i) => _ProductCard(
            product: products[i],
            onAdd: () => onAdd(products[i]),
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;
  const _ProductCard({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF2F4F9),
                    child: Image.asset(product.asset, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatRupiah(product.price),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F6BFF),
                ),
              ),
              Text(
                'Stok: ${product.stock}',
                style: const TextStyle(fontSize: 11, color: Colors.black45),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              color: const Color(0xFF2F6BFF),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onAdd,
                child: const Padding(
                  padding: EdgeInsets.all(7),
                  child: Icon(Icons.add_rounded, color: Colors.white, size: 18),
                ),
              ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total $total Produk',
          style: const TextStyle(fontSize: 12.5, color: Colors.black54),
        ),
        Row(
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

class _CartPanel extends StatelessWidget {
  final List<_CartLine> cart;
  final TextEditingController customerController;
  final TextEditingController noteController;
  final int subtotal;
  final int tax;
  final int total;
  final ValueChanged<String> onIncrement;
  final ValueChanged<String> onDecrement;
  final ValueChanged<String> onRemove;
  final VoidCallback? onClearAll;

  const _CartPanel({
    required this.cart,
    required this.customerController,
    required this.noteController,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onClearAll,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Keranjang Belanja (${cart.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              TextButton.icon(
                onPressed: onClearAll,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color: Color(0xFFE53935),
                ),
                label: const Text(
                  'Hapus Semua',
                  style: TextStyle(color: Color(0xFFE53935), fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: cart.isEmpty
                ? const Center(
                    child: Text(
                      'Keranjang masih kosong',
                      style: TextStyle(color: Colors.black38, fontSize: 12.5),
                    ),
                  )
                : ListView.separated(
                    itemCount: cart.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _CartLineTile(
                      line: cart[i],
                      onIncrement: () => onIncrement(cart[i].product.id),
                      onDecrement: () => onDecrement(cart[i].product.id),
                      onRemove: () => onRemove(cart[i].product.id),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pelanggan (Opsional)',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 16, color: Colors.black38),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: customerController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Cari pelanggan...',
                            hintStyle: TextStyle(
                              fontSize: 12.5,
                              color: Colors.black38,
                            ),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 18,
                  color: Color(0xFF2F6BFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Catatan (Opsional)',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: TextField(
              controller: noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Tambahkan catatan...',
                hintStyle: TextStyle(fontSize: 12.5, color: Colors.black38),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            label: 'Subtotal (${cart.length} item)',
            value: formatRupiah(subtotal),
          ),
          const SizedBox(height: 6),
          const _SummaryRow(label: 'Diskon', value: 'Rp 0'),
          const SizedBox(height: 6),
          _SummaryRow(label: 'Pajak (PPN 11%)', value: formatRupiah(tax)),
          const SizedBox(height: 14),
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
                  'Total',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  formatRupiah(total),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A66FF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onClearAll,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: Color(0xFFE53935),
                  ),
                  label: const Text(
                    'Batal',
                    style: TextStyle(color: Color(0xFFE53935)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE53935)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: cart.isEmpty
                      ? null
                      : () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pembayaran belum tersedia'),
                          ),
                        ),
                  icon: const Icon(Icons.credit_card_rounded, size: 16),
                  label: const Text('Pembayaran (F8)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6BFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _CartLineTile extends StatelessWidget {
  final _CartLine line;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartLineTile({
    required this.line,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: const Color(0xFFF2F4F9),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, size: 14, color: Colors.black54),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            line.product.asset,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      line.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onRemove,
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Color(0xFFE53935),
                    ),
                  ),
                ],
              ),
              Text(
                formatRupiah(line.product.price),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF2F6BFF),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _stepperButton(Icons.remove_rounded, onDecrement),
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${line.qty}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _stepperButton(Icons.add_rounded, onIncrement),
                  const Spacer(),
                  Text(
                    formatRupiah(line.subtotal),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
