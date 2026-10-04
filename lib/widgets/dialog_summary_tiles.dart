import 'package:flutter/material.dart';

/// Circular logo chip used in PPOB-style dialogs (operator/game/service icon).
class BrandLogo extends StatelessWidget {
  final String asset;
  final double size;
  const BrandLogo({super.key, required this.asset, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.14),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }
}

/// A single labelled row in a "Ringkasan Transaksi" summary panel.
class SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? logoAsset;
  final Widget? trailing;

  const SummaryTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.logoAsset,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        logoAsset != null
            ? BrandLogo(asset: logoAsset!, size: 30)
            : Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: Colors.black45),
              ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.black45),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// A label/value price line (e.g. "Harga Produk" / "Rp 1.500").
class PriceRow extends StatelessWidget {
  final String label;
  final String value;
  const PriceRow({super.key, required this.label, required this.value});

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
