import 'package:flutter/material.dart';

import '../utils/currency.dart';
import '../widgets/dialog_summary_tiles.dart';

class _UtilityTab {
  final String label;
  final IconData icon;
  final Color color;
  final String asset;
  final String fieldLabel;
  final String fieldHint;
  final String validLabel;
  final List<int> nominals;
  const _UtilityTab(
    this.label,
    this.icon,
    this.color,
    this.asset,
    this.fieldLabel,
    this.fieldHint,
    this.validLabel,
    this.nominals,
  );
}

const _tabs = [
  _UtilityTab(
    'PLN',
    Icons.bolt_rounded,
    Color(0xFFFFB020),
    'asset/operator/29_PLN_Token_Listrik.png',
    'Nomor Meter / ID Pelanggan',
    '08xxxxxxxxxx atau nomor meter',
    'Nomor meter valid - PLN Prabayar',
    [20000, 50000, 100000, 200000, 500000, 1000000],
  ),
  _UtilityTab(
    'PDAM',
    Icons.water_drop_rounded,
    Color(0xFF29B6F6),
    'asset/operator/31_PDAM.png',
    'Nomor Meter / ID Pelanggan',
    'Nomor pelanggan PDAM',
    'Nomor pelanggan valid - PDAM',
    [50000, 100000, 150000, 200000, 300000, 500000],
  ),
];

const _adminFee = 2500;

enum _PlnType { prabayar, pascabayar }

const _plnPrabayarAsset = 'asset/operator/29_PLN_Token_Listrik.png';
const _plnPascabayarAsset = 'asset/operator/30_PLN_Tagihan.png';

class PlnPdamDialog extends StatefulWidget {
  final int initialTab;
  const PlnPdamDialog({super.key, this.initialTab = 0});

  @override
  State<PlnPdamDialog> createState() => _PlnPdamDialogState();
}

class _PlnPdamDialogState extends State<PlnPdamDialog> {
  late int _selectedTab = widget.initialTab;
  final _idController = TextEditingController();
  final _idFocusNode = FocusNode();
  int? _selectedNominal;
  _PlnType _plnType = _PlnType.prabayar;
  int? _billAmount;

  bool get _isPln => _selectedTab == 0;
  bool get _isPascabayar => _isPln && _plnType == _PlnType.pascabayar;

  @override
  void dispose() {
    _idController.dispose();
    _idFocusNode.dispose();
    super.dispose();
  }

  _UtilityTab get _tab => _tabs[_selectedTab];
  String get _currentAsset {
    if (!_isPln) return _tab.asset;
    return _plnType == _PlnType.prabayar
        ? _plnPrabayarAsset
        : _plnPascabayarAsset;
  }

  bool get _isValid =>
      _idController.text.replaceAll(RegExp(r'\D'), '').length >= 8;

  String get _headerTitle {
    if (!_isPln) return 'PDAM - Tagihan Air';
    return _plnType == _PlnType.prabayar
        ? 'PLN - Token Listrik'
        : 'PLN - Tagihan Listrik';
  }

  String get _headerSubtitle {
    if (!_isPln) return 'Bayar tagihan air PDAM dengan cepat dan mudah';
    return _plnType == _PlnType.prabayar
        ? 'Beli token listrik PLN untuk semua wilayah dengan cepat dan mudah'
        : 'Bayar tagihan listrik PLN pascabayar dengan cepat dan mudah';
  }

  void _checkBill() {
    if (!_isPascabayar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fitur cek meter belum tersedia')),
      );
      return;
    }
    if (!_isValid) return;
    final idDigits = _idController.text.replaceAll(RegExp(r'\D'), '');
    setState(() => _billAmount = 50000 + (idDigits.hashCode.abs() % 150000));
  }

  @override
  Widget build(BuildContext context) {
    final harga = _isPascabayar ? (_billAmount ?? 0) : (_selectedNominal ?? 0);
    final hasProduct = _isPascabayar
        ? _billAmount != null
        : _selectedNominal != null;
    final admin = hasProduct ? _adminFee : 0;
    final total = harga + admin;
    final canProceed = _isValid && hasProduct;

    final leftColumn = _buildLeftColumn();
    final rightColumn = _buildSummaryPanel(
      harga,
      admin,
      total,
      canProceed,
      hasProduct,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 760),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FA),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _tab.color,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_tab.icon, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _headerTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _headerSubtitle,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 700) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                        child: Column(
                          children: [
                            leftColumn,
                            const SizedBox(height: 20),
                            rightColumn,
                          ],
                        ),
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 16, 0, 24),
                            child: leftColumn,
                          ),
                        ),
                        SizedBox(
                          width: 320,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 24, 24),
                            child: SingleChildScrollView(child: rightColumn),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < _tabs.length; i++) ...[
              Expanded(
                child: _ServiceTabButton(
                  tab: _tabs[i],
                  selected: i == _selectedTab,
                  onTap: () => setState(() {
                    _selectedTab = i;
                    _selectedNominal = null;
                    _billAmount = null;
                  }),
                ),
              ),
              if (i != _tabs.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
        if (_isPln) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _PlnTypeToggle(
                  label: 'Prabayar',
                  icon: Icons.sim_card_rounded,
                  selected: _plnType == _PlnType.prabayar,
                  onTap: () => setState(() {
                    _plnType = _PlnType.prabayar;
                    _billAmount = null;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PlnTypeToggle(
                  label: 'Pascabayar',
                  icon: Icons.receipt_long_rounded,
                  selected: _plnType == _PlnType.pascabayar,
                  onTap: () => setState(() {
                    _plnType = _PlnType.pascabayar;
                    _selectedNominal = null;
                  }),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Text(
          _tab.fieldLabel,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _tab.color.withValues(alpha: 0.5),
                    width: 1.4,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _idController,
                        focusNode: _idFocusNode,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: _tab.fieldHint,
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: (_) => setState(() => _billAmount = null),
                      ),
                    ),
                    if (_idController.text.isNotEmpty)
                      InkWell(
                        onTap: () => setState(() => _idController.clear()),
                        child: const Icon(
                          Icons.cancel_rounded,
                          size: 18,
                          color: Colors.black26,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
              ),
              child: const Icon(
                Icons.people_alt_outlined,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isValid ? const Color(0xFFE9FBF0) : const Color(0xFFF2F4F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Image.asset(_currentAsset, fit: BoxFit.contain),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _tab.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                        if (_isValid) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Terdeteksi Otomatis',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF16A34A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isValid
                          ? (_isPascabayar
                                ? 'Nomor pelanggan valid - PLN Pascabayar'
                                : _tab.validLabel)
                          : 'Masukkan ${_tab.fieldLabel.toLowerCase()} yang valid',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: _isValid ? _checkBill : null,
                icon: const Icon(Icons.search_rounded, size: 16),
                label: Text(_isPascabayar ? 'Cek Tagihan' : 'Cek Meter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2F6BFF),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: const Color(0xFF2F6BFF).withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_isPascabayar)
          _buildBillResult()
        else ...[
          Text(
            _tab.label == 'PLN'
                ? 'Pilih Nominal Token'
                : 'Pilih Nominal Pembayaran',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tab.nominals.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.1,
            ),
            itemBuilder: (context, i) {
              final nominal = _tab.nominals[i];
              return _NominalTile(
                nominal: nominal,
                color: _tab.color,
                icon: _tab.icon,
                selected: _selectedNominal == nominal,
                onTap: () => setState(() => _selectedNominal = nominal),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildBillResult() {
    if (_billAmount == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 28, color: Colors.black26),
            const SizedBox(height: 8),
            Text(
              _isValid
                  ? "Tekan 'Cek Tagihan' untuk melihat jumlah tagihan"
                  : 'Masukkan nomor pelanggan terlebih dahulu',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: Colors.black45),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFB020).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB020),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tagihan Listrik PLN',
                  style: TextStyle(fontSize: 12.5, color: Colors.black54),
                ),
                Text(
                  formatRupiah(_billAmount!),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPanel(
    int harga,
    int admin,
    int total,
    bool canProceed,
    bool hasProduct,
  ) {
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  size: 16,
                  color: Color(0xFF2F6BFF),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Ringkasan Transaksi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SummaryTile(
            icon: _tab.icon,
            label: 'Jenis Layanan',
            value: _headerTitle,
          ),
          const SizedBox(height: 12),
          SummaryTile(
            icon: Icons.badge_outlined,
            label: 'Nomor Meter',
            value: _idController.text.isEmpty ? '-' : _idController.text,
            trailing: _idController.text.isEmpty
                ? null
                : TextButton(
                    onPressed: () => _idFocusNode.requestFocus(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text('Ubah', style: TextStyle(fontSize: 12.5)),
                  ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => setState(() {
              _selectedNominal = null;
              _billAmount = null;
            }),
            child: SummaryTile(
              icon: _tab.icon,
              label: 'Produk',
              value: !hasProduct
                  ? '-'
                  : _isPascabayar
                  ? 'Tagihan PLN ${formatRupiah(_billAmount!)}'
                  : 'Token ${_tab.label} ${formatRupiah(_selectedNominal!)}',
              trailing: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.black38,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.black.withValues(alpha: 0.08)),
          const SizedBox(height: 8),
          PriceRow(
            label: _isPascabayar
                ? 'Harga Tagihan'
                : (_tab.label == 'PLN' ? 'Harga Token' : 'Harga Tagihan'),
            value: formatRupiah(harga),
          ),
          const SizedBox(height: 8),
          PriceRow(label: 'Biaya Admin', value: formatRupiah(admin)),
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
                  'Total Pembayaran',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F8F4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 16,
                    color: Color(0xFF14B8A6),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Saldo Tenant',
                        style: TextStyle(fontSize: 10.5, color: Colors.black54),
                      ),
                      Text(
                        'Rp 1.250.000',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
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
                  onPressed: canProceed
                      ? () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Melanjutkan pembayaran ${_tab.label} ${formatRupiah(harga)} - ${_idController.text}',
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text(
                    'Lanjut Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6BFF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.black12,
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

class _PlnTypeToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _PlnTypeToggle({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFEFF4FF) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? const Color(0xFF2F6BFF)
                  : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? const Color(0xFF2F6BFF) : Colors.black45,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? const Color(0xFF2F6BFF) : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTabButton extends StatelessWidget {
  final _UtilityTab tab;
  final bool selected;
  final VoidCallback onTap;
  const _ServiceTabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? tab.color : const Color(0xFFF2F4F9),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                tab.icon,
                size: 18,
                color: selected ? Colors.white : Colors.black54,
              ),
              const SizedBox(width: 8),
              Text(
                tab.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NominalTile extends StatelessWidget {
  final int nominal;
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NominalTile({
    required this.nominal,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color : Colors.black.withValues(alpha: 0.08),
              width: selected ? 2 : 1,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatRupiah(nominal),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Token: ${formatRupiah(nominal)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black45,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (selected)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
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
