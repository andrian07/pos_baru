import 'package:flutter/material.dart';

import '../models/game.dart';
import '../models/game_catalog.dart';
import '../utils/currency.dart';
import '../widgets/dialog_summary_tiles.dart';

const _adminFee = 500;

class VoucherGameDialog extends StatefulWidget {
  const VoucherGameDialog({super.key});

  @override
  State<VoucherGameDialog> createState() => _VoucherGameDialogState();
}

class _VoucherGameDialogState extends State<VoucherGameDialog> {
  int _selectedGameIndex = 0;
  final _idController = TextEditingController();
  final _idFocusNode = FocusNode();
  GamePackage? _selectedPackage;
  String? _playerName;

  GameInfo get _game => gameCatalog[_selectedGameIndex];
  bool get _isValid => _idController.text.trim().length >= 4;

  @override
  void dispose() {
    _idController.dispose();
    _idFocusNode.dispose();
    super.dispose();
  }

  void _selectGame(int i) {
    setState(() {
      _selectedGameIndex = i;
      _selectedPackage = null;
      _playerName = null;
      _idController.clear();
    });
  }

  void _checkId() {
    if (!_isValid) return;
    final digits = _idController.text.replaceAll(RegExp(r'\D'), '');
    final suffix = digits.length >= 4
        ? digits.substring(digits.length - 4)
        : digits;
    setState(() => _playerName = 'Player$suffix');
  }

  @override
  Widget build(BuildContext context) {
    final harga = _selectedPackage?.price ?? 0;
    final admin = _selectedPackage == null ? 0 : _adminFee;
    final total = harga + admin;
    final canProceed =
        _isValid && _playerName != null && _selectedPackage != null;

    final gameList = _GameList(
      games: gameCatalog,
      selectedIndex: _selectedGameIndex,
      onSelect: _selectGame,
    );
    final content = _buildContent();
    final summary = _buildSummaryPanel(harga, admin, total, canProceed);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180, maxHeight: 800),
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
                        color: const Color(0xFF8B5CF6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.sports_esports_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voucher Game',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Top up game dan voucher digital favorit',
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
                    if (constraints.maxWidth < 900) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                        child: Column(
                          children: [
                            SizedBox(height: 64, child: gameList),
                            const SizedBox(height: 16),
                            content,
                            const SizedBox(height: 20),
                            summary,
                          ],
                        ),
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 0, 24),
                          child: SizedBox(width: 180, child: gameList),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 0, 24),
                            child: content,
                          ),
                        ),
                        SizedBox(
                          width: 320,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 24, 24),
                            child: SingleChildScrollView(child: summary),
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

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 110,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [_game.color, _game.color.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Image.asset(_game.asset, fit: BoxFit.contain),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _game.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Top up ${_game.unit} ${_game.name} dengan cepat dan mudah',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'User ID / Zone ID',
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
                    color: _game.color.withValues(alpha: 0.4),
                    width: 1.4,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _idController,
                        focusNode: _idFocusNode,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'User ID (Zone ID)',
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: (_) => setState(() => _playerName = null),
                      ),
                    ),
                    if (_idController.text.isNotEmpty)
                      InkWell(
                        onTap: () => setState(() {
                          _idController.clear();
                          _playerName = null;
                        }),
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
            OutlinedButton.icon(
              onPressed: _isValid ? _checkId : null,
              icon: const Icon(Icons.search_rounded, size: 16),
              label: const Text('Cek ID'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2F6BFF),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                side: BorderSide(
                  color: const Color(0xFF2F6BFF).withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_playerName != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE9FBF0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                BrandLogo(asset: _game.asset, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _playerName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
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
                              'ID Valid',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF16A34A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${_idController.text}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _idFocusNode.requestFocus(),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Ubah', style: TextStyle(fontSize: 12.5)),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2F6BFF),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: Colors.black38),
              SizedBox(width: 6),
              Text(
                'Pastikan User ID dan Zone ID sudah benar.',
                style: TextStyle(fontSize: 11.5, color: Colors.black45),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        const Text(
          'Pilih Nominal',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _game.packages.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.9,
          ),
          itemBuilder: (context, i) {
            final pkg = _game.packages[i];
            return _PackageTile(
              package: pkg,
              color: _game.color,
              selected: _selectedPackage == pkg,
              onTap: () => setState(() => _selectedPackage = pkg),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryPanel(int harga, int admin, int total, bool canProceed) {
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
            icon: Icons.sports_esports_outlined,
            label: 'Game',
            value: _game.name,
            logoAsset: _game.asset,
          ),
          const SizedBox(height: 12),
          SummaryTile(
            icon: Icons.badge_outlined,
            label: 'User ID',
            value: _idController.text.isEmpty
                ? '-'
                : _playerName != null
                ? '${_idController.text} ($_playerName)'
                : _idController.text,
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
            onTap: () => setState(() => _selectedPackage = null),
            child: SummaryTile(
              icon: Icons.diamond_outlined,
              label: 'Produk',
              value: _selectedPackage == null
                  ? '-'
                  : '${_selectedPackage!.amount} ${_selectedPackage!.unit}',
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
                                'Melanjutkan pembayaran ${_selectedPackage!.amount} ${_selectedPackage!.unit} ${_game.name} - $_playerName',
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

class _GameList extends StatelessWidget {
  final List<GameInfo> games;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  const _GameList({
    required this.games,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isVertical = constraints.maxHeight > constraints.maxWidth;
        final items = [
          for (var i = 0; i < games.length; i++)
            _GameListItem(
              game: games[i],
              selected: i == selectedIndex,
              onTap: () => onSelect(i),
              horizontal: !isVertical,
            ),
        ];

        if (isVertical) {
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (context, i) => items[i],
          );
        }

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, i) => items[i],
        );
      },
    );
  }
}

class _GameListItem extends StatelessWidget {
  final GameInfo game;
  final bool selected;
  final bool horizontal;
  final VoidCallback onTap;
  const _GameListItem({
    required this.game,
    required this.selected,
    required this.onTap,
    required this.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: selected ? const Color(0xFF2F6BFF) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  game.asset,
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                game.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return horizontal ? child : SizedBox(width: double.infinity, child: child);
  }
}

class _PackageTile extends StatelessWidget {
  final GamePackage package;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _PackageTile({
    required this.package,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
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
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.diamond_rounded, size: 18, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${package.amount} ${package.unit}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          formatRupiah(package.price),
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
