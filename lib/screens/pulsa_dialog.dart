import 'package:flutter/material.dart';

import '../utils/currency.dart';
import '../widgets/dialog_summary_tiles.dart';

class _Operator {
  final String name;
  final Color color;
  final List<String> prefixes;
  // One logo asset per tab, in the same order as [_tabs]: Pulsa, Paket Data,
  // Nelpon & SMS, Combo.
  final List<String> assetsByTab;
  const _Operator(this.name, this.color, this.prefixes, this.assetsByTab);

  String assetFor(int tabIndex) => assetsByTab[tabIndex];
}

const _operators = [
  _Operator(
    'Telkomsel',
    Color(0xFFE4002B),
    ['811', '812', '813', '821', '822', '823', '852', '853'],
    [
      'asset/operator/01_Telkomsel.png',
      'asset/operator/08_Telkomsel_Paket_Data.png',
      'asset/operator/15_Telkomsel_Nelpon_SMS.png',
      'asset/operator/22_Telkomsel_Combo.png',
    ],
  ),
  _Operator(
    'Indosat',
    Color(0xFFFFC72C),
    ['814', '815', '816', '855', '856', '857', '858'],
    [
      'asset/operator/02_Indosat.png',
      'asset/operator/09_Indosat_Paket_Data.png',
      'asset/operator/16_Indosat_Nelpon_SMS.png',
      'asset/operator/23_Indosat_Combo.png',
    ],
  ),
  _Operator(
    'XL',
    Color(0xFF1C64F2),
    ['817', '818', '819', '859', '877', '878'],
    [
      'asset/operator/03_XL.png',
      'asset/operator/10_XL_Paket_Data.png',
      'asset/operator/17_XL_Nelpon_SMS.png',
      'asset/operator/24_XL_Combo.png',
    ],
  ),
  _Operator(
    'Tri',
    Color(0xFF1A1A2E),
    ['895', '896', '897', '898', '899'],
    [
      'asset/operator/04_Tri.png',
      'asset/operator/11_Tri_Paket_Data.png',
      'asset/operator/18_Tri_Nelpon_SMS.png',
      'asset/operator/25_Tri_Combo.png',
    ],
  ),
  _Operator(
    'Smartfren',
    Color(0xFFE6007E),
    ['881', '882', '883', '884', '885', '886', '887', '888', '889'],
    [
      'asset/operator/05_Smartfren.png',
      'asset/operator/12_Smartfren_Paket_Data.png',
      'asset/operator/19_Smartfren_Nelpon_SMS.png',
      'asset/operator/26_Smartfren_Combo.png',
    ],
  ),
  _Operator(
    'Axis',
    Color(0xFFFFD400),
    ['831', '832', '833', '838'],
    [
      'asset/operator/06_Axis.png',
      'asset/operator/13_Axis_Paket_Data.png',
      'asset/operator/20_Axis_Nelpon_SMS.png',
      'asset/operator/27_Axis_Combo.png',
    ],
  ),
  _Operator(
    'by.U',
    Color(0xFF6D28D9),
    ['851'],
    [
      'asset/operator/07_by_U.png',
      'asset/operator/14_by_U_Paket_Data.png',
      'asset/operator/21_by_U_Nelpon_SMS.png',
      'asset/operator/28_by_U_Combo.png',
    ],
  ),
];

_Operator? _detectOperator(String phone) {
  var digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('62')) digits = '0${digits.substring(2)}';
  if (!digits.startsWith('0') || digits.length < 4) return null;
  final prefix3 = digits.substring(1, 4);
  for (final op in _operators) {
    if (op.prefixes.contains(prefix3)) return op;
  }
  return null;
}

class _PulsaTab {
  final String label;
  final IconData icon;
  const _PulsaTab(this.label, this.icon);
}

const _tabs = [
  _PulsaTab('Pulsa', Icons.phone_android_rounded),
  _PulsaTab('Paket Data', Icons.public_rounded),
  _PulsaTab('Nelpon & SMS', Icons.sms_rounded),
  _PulsaTab('Combo', Icons.layers_rounded),
];

const _nominals = [
  5000,
  10000,
  20000,
  25000,
  50000,
  100000,
  150000,
  200000,
  300000,
];

class PulsaDialog extends StatefulWidget {
  const PulsaDialog({super.key});

  @override
  State<PulsaDialog> createState() => _PulsaDialogState();
}

class _PulsaDialogState extends State<PulsaDialog> {
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  int _selectedTab = 0;
  int? _selectedNominal;
  _Operator? _manualOperator;

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _pickOperator(_Operator? op) {
    setState(() => _manualOperator = op);
  }

  @override
  Widget build(BuildContext context) {
    final detected = _detectOperator(_phoneController.text);
    final operator = _manualOperator ?? detected;
    final isManual = _manualOperator != null;
    final canProceed =
        _selectedTab == 0 && operator != null && _selectedNominal != null;

    final leftColumn = _buildLeftColumn(operator, isManual);
    final rightColumn = _TransactionSummaryPanel(
      phone: _phoneController.text,
      operator: operator,
      tabIndex: _selectedTab,
      nominal: _selectedTab == 0 ? _selectedNominal : null,
      canProceed: canProceed,
      onEditPhone: () => _phoneFocusNode.requestFocus(),
      onEditOperator: () => _showOperatorMenu(context),
      onEditProduct: () => setState(() => _selectedNominal = null),
      onCancel: () => Navigator.of(context).pop(),
      onProceed: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Melanjutkan pembayaran Pulsa ${formatRupiah(_selectedNominal!)} - ${_phoneController.text}',
            ),
          ),
        );
      },
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
                        color: const Color(0xFFFF5C93),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.phone_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pulsa & Paket Data',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Beli pulsa, paket data, nelpon, SMS dan layanan operator',
                            style: TextStyle(
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

  void _showOperatorMenu(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    RelativeRect position = const RelativeRect.fromLTRB(100, 200, 100, 100);
    if (box != null && overlay != null) {
      final offset = box.localToGlobal(Offset.zero, ancestor: overlay);
      position = RelativeRect.fromLTRB(
        offset.dx + 40,
        offset.dy + 40,
        offset.dx,
        offset.dy,
      );
    }

    final selected = await showMenu<_Operator?>(
      context: context,
      position: position,
      items: [
        const PopupMenuItem<_Operator?>(
          value: null,
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: Color(0xFF2F6BFF),
              ),
              SizedBox(width: 10),
              Text('Deteksi Otomatis'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        for (final op in _operators)
          PopupMenuItem<_Operator?>(
            value: op,
            child: Row(
              children: [
                BrandLogo(asset: op.assetFor(_selectedTab), size: 26),
                const SizedBox(width: 10),
                Text(op.name),
              ],
            ),
          ),
      ],
    );
    _pickOperator(selected);
  }

  Widget _buildLeftColumn(_Operator? operator, bool isManual) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nomor Tujuan',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
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
                    color: const Color(0xFF2F6BFF).withValues(alpha: 0.4),
                    width: 1.4,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        focusNode: _phoneFocusNode,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '08xxxxxxxxxx',
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    if (_phoneController.text.isNotEmpty)
                      InkWell(
                        onTap: () => setState(() => _phoneController.clear()),
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
            color: operator == null
                ? const Color(0xFFF2F4F9)
                : const Color(0xFFE9FBF0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              operator == null
                  ? Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sim_card_outlined,
                        size: 18,
                        color: Colors.black45,
                      ),
                    )
                  : BrandLogo(asset: operator.assetFor(_selectedTab), size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          operator?.name ?? 'Operator belum terdeteksi',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                        if (operator != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (isManual
                                          ? const Color(0xFF2F6BFF)
                                          : const Color(0xFF22C55E))
                                      .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isManual
                                  ? 'Dipilih Manual'
                                  : 'Terdeteksi Otomatis',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isManual
                                    ? const Color(0xFF2F6BFF)
                                    : const Color(0xFF16A34A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isManual
                          ? 'Operator dipilih secara manual'
                          : (operator == null
                                ? 'Masukkan nomor atau pilih operator manual'
                                : _detectedPrefixLabel()),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _showOperatorMenu(context),
                icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                label: const Text('Ganti Operator'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2F6BFF),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: const Color(0xFF2F6BFF).withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (var i = 0; i < _tabs.length; i++) ...[
              Expanded(
                child: _TabButton(
                  tab: _tabs[i],
                  selected: i == _selectedTab,
                  onTap: () => setState(() => _selectedTab = i),
                ),
              ),
              if (i != _tabs.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 16),
        if (_selectedTab != 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'Fitur ${_tabs[_selectedTab].label} belum tersedia',
                style: const TextStyle(color: Colors.black45, fontSize: 13),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _nominals.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.4,
            ),
            itemBuilder: (context, i) {
              final nominal = _nominals[i];
              return _NominalTile(
                nominal: nominal,
                color: operator?.color ?? const Color(0xFF2F6BFF),
                selected: _selectedNominal == nominal,
                onTap: () => setState(() => _selectedNominal = nominal),
              );
            },
          ),
      ],
    );
  }

  String _detectedPrefixLabel() {
    var digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('62')) digits = '0${digits.substring(2)}';
    if (digits.length < 4) return '';
    return 'Terdeteksi dari prefix ${digits.substring(0, 4)}';
  }
}

class _TransactionSummaryPanel extends StatelessWidget {
  final String phone;
  final _Operator? operator;
  final int tabIndex;
  final int? nominal;
  final bool canProceed;
  final VoidCallback onEditPhone;
  final VoidCallback onEditOperator;
  final VoidCallback onEditProduct;
  final VoidCallback onCancel;
  final VoidCallback onProceed;

  const _TransactionSummaryPanel({
    required this.phone,
    required this.operator,
    required this.tabIndex,
    required this.nominal,
    required this.canProceed,
    required this.onEditPhone,
    required this.onEditOperator,
    required this.onEditProduct,
    required this.onCancel,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    final harga = nominal ?? 0;
    const diskon = 0;
    final total = harga - diskon;

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
            icon: Icons.sim_card_outlined,
            label: 'Nomor Tujuan',
            value: phone.isEmpty ? '-' : phone,
            trailing: phone.isEmpty
                ? null
                : TextButton(
                    onPressed: onEditPhone,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text('Ubah', style: TextStyle(fontSize: 12.5)),
                  ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onEditOperator,
            child: SummaryTile(
              icon: Icons.sim_card_rounded,
              label: 'Operator',
              value: operator?.name ?? '-',
              logoAsset: operator?.assetFor(tabIndex),
              trailing: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.black38,
              ),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onEditProduct,
            child: SummaryTile(
              icon: Icons.phone_android_rounded,
              label: 'Produk',
              value: nominal == null ? '-' : 'Pulsa ${formatRupiah(nominal!)}',
              trailing: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.black38,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.black.withValues(alpha: 0.08)),
          const SizedBox(height: 8),
          PriceRow(label: 'Harga Produk', value: formatRupiah(harga)),
          const SizedBox(height: 8),
          const PriceRow(label: 'Diskon', value: 'Rp 0'),
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
                  onPressed: onCancel,
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
                  onPressed: canProceed ? onProceed : null,
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

class _TabButton extends StatelessWidget {
  final _PulsaTab tab;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF2F6BFF) : const Color(0xFFF2F4F9),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                tab.icon,
                size: 18,
                color: selected ? Colors.white : Colors.black54,
              ),
              const SizedBox(height: 4),
              Text(
                tab.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
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
  final bool selected;
  final VoidCallback onTap;

  const _NominalTile({
    required this.nominal,
    required this.color,
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
              color: selected
                  ? const Color(0xFF2F6BFF)
                  : Colors.black.withValues(alpha: 0.08),
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
                    child: const Icon(
                      Icons.phone_android_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      formatRupiah(nominal),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
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
                    decoration: const BoxDecoration(
                      color: Color(0xFF2F6BFF),
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: Colors.white, width: 2),
                      ),
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
