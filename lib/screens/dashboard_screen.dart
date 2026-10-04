import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../widgets/app_nav.dart';
import '../widgets/app_sidebar.dart';
import 'customer_screen.dart';
import 'login_screen.dart';
import 'pln_pdam_dialog.dart';
import 'product_screen.dart';
import 'pulsa_dialog.dart';
import 'sales_screen.dart';
import 'voucher_game_dialog.dart';

class DashboardScreen extends StatefulWidget {
  final AppUser user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> _handleLogout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _handleQuickAction(String label) {
    switch (label) {
      case 'Penjualan POS':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => SalesScreen(user: widget.user)),
        );
      case 'Pulsa & Paket Data':
        showDialog<void>(context: context, builder: (_) => const PulsaDialog());
      case 'PLN':
        showDialog<void>(
          context: context,
          builder: (_) => const PlnPdamDialog(initialTab: 0),
        );
      case 'PDAM':
        showDialog<void>(
          context: context,
          builder: (_) => const PlnPdamDialog(initialTab: 1),
        );
      case 'Voucher Game':
        showDialog<void>(
          context: context,
          builder: (_) => const VoucherGameDialog(),
        );
      case 'Produk':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ProductScreen(user: widget.user)),
        );
      case 'Pelanggan':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => CustomerScreen(user: widget.user)),
        );
      default:
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$label belum tersedia')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F9),
      body: Row(
        children: [
          AppSidebar(
            items: appNavItems,
            selectedIndex: 0,
            onSelect: (i) => handleAppNavSelect(context, i, widget.user),
            onLogout: _handleLogout,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopBar(user: widget.user),
                  const SizedBox(height: 20),
                  const _TopStatsRow(),
                  const SizedBox(height: 20),
                  _QuickActionsRow(onActionTap: _handleQuickAction),
                  const SizedBox(height: 20),
                  const _TwoColumnRow(
                    left: _SalesChartCard(),
                    right: _ServiceBreakdownCard(),
                  ),
                  const SizedBox(height: 20),
                  const _TwoColumnRow(
                    left: _RecentOrdersCard(),
                    right: _TopProductsCard(),
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

class _TopBar extends StatelessWidget {
  final AppUser user;
  const _TopBar({required this.user});

  static const _months = [
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
  static const _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  Widget _pillBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr =
        '${_days[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]} ${now.year}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final searchBar = Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.black38, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Cari produk, barcode, atau pelanggan...',
              style: TextStyle(color: Colors.black38, fontSize: 13),
            ),
          ),
          Icon(Icons.qr_code_scanner, color: Colors.black38, size: 20),
        ],
      ),
    );

    final dateTimePill = _pillBox(
      child: Row(
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

    final avatarPill = _pillBox(
      child: Row(
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
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: Colors.black38,
          ),
        ],
      ),
    );

    final rightCluster = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dateTimePill,
        const SizedBox(width: 12),
        bellButton,
        const SizedBox(width: 12),
        avatarPill,
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 640) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: searchBar),
              const SizedBox(width: 16),
              rightCluster,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            searchBar,
            const SizedBox(height: 16),
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

class _StatCardData {
  final String title;
  final String value;
  final String delta;
  final IconData icon;
  final List<Color> gradient;
  const _StatCardData(
    this.title,
    this.value,
    this.delta,
    this.icon,
    this.gradient,
  );
}

class _TopStatsRow extends StatelessWidget {
  const _TopStatsRow();

  static const _cards = [
    _StatCardData(
      'Total Penjualan',
      'Rp 2.350.000',
      '12% dari kemarin',
      Icons.point_of_sale_rounded,
      [Color(0xFF3B9EFF), Color(0xFF0A66FF)],
    ),
    _StatCardData(
      'Jumlah Transaksi',
      '36',
      '8% dari kemarin',
      Icons.receipt_long_rounded,
      [Color(0xFF34D399), Color(0xFF059669)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;
        final children = [
          _StatCard(data: _cards[0]),
          _StatCard(data: _cards[1]),
          const _SaldoTenantCard(),
        ];

        if (!isWide) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                children[i],
              ],
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: children[0]),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: children[1]),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: children[2]),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final _StatCardData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: data.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, color: Colors.white, size: 18),
              ),
              Icon(
                Icons.show_chart_rounded,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 13,
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  data.delta,
                  style: const TextStyle(color: Colors.white, fontSize: 11.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SaldoTenantCard extends StatelessWidget {
  const _SaldoTenantCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F8F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Color(0xFF14B8A6),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Saldo Tenant',
                  style: TextStyle(fontSize: 12.5, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rp 1.250.000',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: const Color(0xFF2F6BFF),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Top Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickAction(this.icon, this.label, this.color);
}

class _QuickActionsRow extends StatelessWidget {
  final ValueChanged<String> onActionTap;
  const _QuickActionsRow({required this.onActionTap});

  static const _actions = [
    _QuickAction(
      Icons.shopping_cart_rounded,
      'Penjualan POS',
      Color(0xFFFF7A3D),
    ),
    _QuickAction(
      Icons.smartphone_rounded,
      'Pulsa & Paket Data',
      Color(0xFFFF5C93),
    ),
    _QuickAction(Icons.bolt_rounded, 'PLN', Color(0xFFFFB020)),
    _QuickAction(Icons.water_drop_rounded, 'PDAM', Color(0xFF29B6F6)),
    _QuickAction(
      Icons.sports_esports_rounded,
      'Voucher Game',
      Color(0xFF8B5CF6),
    ),
    _QuickAction(Icons.inventory_2_rounded, 'Produk', Color(0xFF60A5FA)),
    _QuickAction(Icons.people_alt_rounded, 'Pelanggan', Color(0xFF34D399)),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 640
            ? 7
            : (constraints.maxWidth >= 420 ? 4 : 3);
        final itemWidth = (constraints.maxWidth - (cols - 1) * 12) / cols;
        return Wrap(
          spacing: 12,
          runSpacing: 16,
          children: [
            for (final a in _actions)
              SizedBox(
                width: itemWidth,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onActionTap(a.label),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: a.color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(a.icon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TwoColumnRow extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _TwoColumnRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) {
          return Column(children: [left, const SizedBox(height: 20), right]);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: left),
            const SizedBox(width: 20),
            Expanded(flex: 2, child: right),
          ],
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF2F6BFF)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Hari Ini', style: TextStyle(fontSize: 12.5)),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16),
        ],
      ),
    );
  }
}

class _SalesChartCard extends StatelessWidget {
  const _SalesChartCard();

  static const _points = [
    FlSpot(8, 300),
    FlSpot(10, 480),
    FlSpot(12, 300),
    FlSpot(13, 520),
    FlSpot(14, 560),
    FlSpot(16, 850),
    FlSpot(18, 620),
    FlSpot(20, 260),
    FlSpot(22, 420),
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Grafik Penjualan',
      icon: Icons.bar_chart_rounded,
      trailing: const _PeriodDropdown(),
      child: SizedBox(
        height: 260,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 1000,
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: 250,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.black.withValues(alpha: 0.06),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 250,
                  reservedSize: 52,
                  getTitlesWidget: (value, meta) => Text(
                    value == 0
                        ? '0'
                        : '${(value / 1000).toStringAsFixed(value >= 1000 ? 0 : 2).replaceFirst('0.', '.')}${value >= 1000 ? 'M' : 'K'}'
                              .replaceAll('.00', ''),
                    style: const TextStyle(fontSize: 10, color: Colors.black45),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 2,
                  getTitlesWidget: (value, meta) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${value.toInt().toString().padLeft(2, '0')}:00',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => const Color(0xFF0A66FF),
                getTooltipItems: (spots) => spots
                    .map(
                      (s) => LineTooltipItem(
                        'Rp ${s.y.toInt() * 1000}\n${s.x.toInt().toString().padLeft(2, '0')}:00',
                        const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    )
                    .toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: _points,
                isCurved: true,
                color: const Color(0xFF0A66FF),
                barWidth: 3,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0A66FF).withValues(alpha: 0.25),
                      const Color(0xFF0A66FF).withValues(alpha: 0.0),
                    ],
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

class _ServiceShare {
  final String label;
  final double percent;
  final Color color;
  const _ServiceShare(this.label, this.percent, this.color);
}

class _ServiceBreakdownCard extends StatelessWidget {
  const _ServiceBreakdownCard();

  static const _shares = [
    _ServiceShare('Penjualan POS', 45, Color(0xFF2F6BFF)),
    _ServiceShare('Pulsa & Paket Data', 20, Color(0xFFFF5C93)),
    _ServiceShare('PLN', 15, Color(0xFFFFB020)),
    _ServiceShare('PDAM', 8, Color(0xFF29B6F6)),
    _ServiceShare('Voucher Game', 7, Color(0xFF8B5CF6)),
    _ServiceShare('Produk', 5, Color(0xFFCBD5E1)),
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Transaksi Berdasarkan Layanan',
      icon: Icons.pie_chart_rounded,
      trailing: const _PeriodDropdown(),
      child: Column(
        children: [
          SizedBox(
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: [
                      for (final s in _shares)
                        PieChartSectionData(
                          value: s.percent,
                          color: s.color,
                          radius: 26,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(fontSize: 11, color: Colors.black45),
                    ),
                    Text(
                      'Rp 2.350.000',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _shares.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _shares[i].color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _shares[i].label,
                    style: const TextStyle(fontSize: 12.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${_shares[i].percent.toInt()}%',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Order {
  final String id;
  final String time;
  final String service;
  final String customer;
  final String total;
  const _Order(this.id, this.time, this.service, this.customer, this.total);
}

class _RecentOrdersCard extends StatelessWidget {
  const _RecentOrdersCard();

  static const _orders = [
    _Order('#TRX000123', '21:15', 'Penjualan POS', 'Umum', 'Rp 75.500'),
    _Order(
      '#TRX000122',
      '20:48',
      'Pulsa & Paket Data',
      '0812xxxxx',
      'Rp 50.000',
    ),
    _Order('#TRX000121', '20:30', 'PLN', '0712xxxxx', 'Rp 100.000'),
    _Order('#TRX000120', '20:12', 'PDAM', '0623xxxxx', 'Rp 42.500'),
    _Order('#TRX000119', '19:45', 'Voucher Game', '0812xxxxx', 'Rp 150.000'),
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Transaksi Terbaru',
      icon: Icons.receipt_long_outlined,
      trailing: const Text(
        'Lihat Semua',
        style: TextStyle(
          color: Color(0xFF2F6BFF),
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Column(
        children: [
          const _OrderRow(
            id: 'No. Transaksi',
            time: 'Waktu',
            service: 'Layanan',
            customer: 'Pelanggan',
            total: 'Total',
            isHeader: true,
          ),
          for (final o in _orders)
            _OrderRow(
              id: o.id,
              time: o.time,
              service: o.service,
              customer: o.customer,
              total: o.total,
            ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final String id;
  final String time;
  final String service;
  final String customer;
  final String total;
  final bool isHeader;

  const _OrderRow({
    required this.id,
    required this.time,
    required this.service,
    required this.customer,
    required this.total,
    this.isHeader = false,
  });

  static const _doneColor = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: isHeader ? 11.5 : 13,
      color: isHeader ? Colors.black45 : Colors.black87,
      fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: isHeader
          ? null
          : BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
              ),
            ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              id,
              style: labelStyle.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(flex: 2, child: Text(time, style: labelStyle)),
          Expanded(
            flex: 3,
            child: Text(
              service,
              style: labelStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              customer,
              style: labelStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              total,
              style: labelStyle.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: isHeader
                ? const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _doneColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Selesai',
                        style: TextStyle(
                          color: _doneColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
          ),
          if (!isHeader)
            const Icon(Icons.chevron_right, size: 18, color: Colors.black26),
        ],
      ),
    );
  }
}

class _Product {
  final String name;
  final String sold;
  final String price;
  final double progress;
  const _Product(this.name, this.sold, this.price, this.progress);
}

class _TopProductsCard extends StatelessWidget {
  const _TopProductsCard();

  static const _products = [
    _Product('Nasi Goreng', '32 terjual', 'Rp 25.000', 1.0),
    _Product('Es Teh Manis', '28 terjual', 'Rp 5.000', 0.85),
    _Product('Coca Cola 350ml', '24 terjual', 'Rp 8.000', 0.7),
    _Product('Indomie Goreng', '18 terjual', 'Rp 4.500', 0.5),
    _Product('Kopi Good Day', '16 terjual', 'Rp 10.000', 0.45),
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Produk Terlaris',
      icon: Icons.star_rounded,
      trailing: const _PeriodDropdown(),
      child: Column(
        children: [
          for (var i = 0; i < _products.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF7A1A),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.fastfood_outlined,
                    size: 18,
                    color: Colors.black38,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _products[i].name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _products[i].sold,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _products[i].progress,
                          minHeight: 5,
                          backgroundColor: const Color(0xFFF2F4F9),
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF2F6BFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _products[i].price,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
