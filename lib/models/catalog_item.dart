import 'product.dart';

class CatalogItem {
  final String name;
  final String category;
  final String asset;
  final int price;
  final String stockLabel;
  final bool isDigital;

  const CatalogItem({
    required this.name,
    required this.category,
    required this.asset,
    required this.price,
    required this.stockLabel,
    this.isDigital = false,
  });
}

const _virtualItems = [
  CatalogItem(
    name: 'Pulsa Telkomsel 10K',
    category: 'Pulsa',
    asset: 'asset/operator/01_Telkomsel.png',
    price: 10500,
    stockLabel: '∞',
    isDigital: true,
  ),
  CatalogItem(
    name: 'Pulsa Indosat 25K',
    category: 'Pulsa',
    asset: 'asset/operator/02_Indosat.png',
    price: 25500,
    stockLabel: '∞',
    isDigital: true,
  ),
  CatalogItem(
    name: 'Pulsa XL 50K',
    category: 'Pulsa',
    asset: 'asset/operator/03_XL.png',
    price: 50500,
    stockLabel: '∞',
    isDigital: true,
  ),
  CatalogItem(
    name: 'Pulsa Tri 20K',
    category: 'Pulsa',
    asset: 'asset/operator/04_Tri.png',
    price: 20500,
    stockLabel: '∞',
    isDigital: true,
  ),
  CatalogItem(
    name: 'Paket Data XL 10GB',
    category: 'Paket Data',
    asset: 'asset/operator/10_XL_Paket_Data.png',
    price: 55000,
    stockLabel: '∞',
    isDigital: true,
  ),
  CatalogItem(
    name: 'Paket Data Telkomsel 5GB',
    category: 'Paket Data',
    asset: 'asset/operator/08_Telkomsel_Paket_Data.png',
    price: 45000,
    stockLabel: '∞',
    isDigital: true,
  ),
  CatalogItem(
    name: 'Paket Data Indosat 8GB',
    category: 'Paket Data',
    asset: 'asset/operator/09_Indosat_Paket_Data.png',
    price: 50000,
    stockLabel: '∞',
    isDigital: true,
  ),
  CatalogItem(
    name: 'Token PLN 20K',
    category: 'Token PLN',
    asset: 'asset/operator/29_PLN_Token_Listrik.png',
    price: 20500,
    stockLabel: '∞',
    isDigital: true,
  ),
  CatalogItem(
    name: 'Token PLN 50K',
    category: 'Token PLN',
    asset: 'asset/operator/29_PLN_Token_Listrik.png',
    price: 50500,
    stockLabel: '∞',
    isDigital: true,
  ),
  CatalogItem(
    name: 'Token PLN 100K',
    category: 'Token PLN',
    asset: 'asset/operator/29_PLN_Token_Listrik.png',
    price: 100500,
    stockLabel: '∞',
    isDigital: true,
  ),
  CatalogItem(
    name: 'Tagihan PLN Pascabayar',
    category: 'Token PLN',
    asset: 'asset/operator/30_PLN_Tagihan.png',
    price: 2500,
    stockLabel: '∞',
    isDigital: true,
  ),
  CatalogItem(
    name: 'Tagihan PDAM',
    category: 'PDAM',
    asset: 'asset/operator/31_PDAM.png',
    price: 2500,
    stockLabel: '∞',
    isDigital: true,
  ),
  CatalogItem(
    name: 'Diamond Mobile Legends 86',
    category: 'Voucher Game',
    asset: 'asset/game/01_Mobile_Legends.png',
    price: 23000,
    stockLabel: '∞',
    isDigital: true,
  ),
  CatalogItem(
    name: 'PlayStation Store 100K',
    category: 'Voucher Game',
    asset: 'asset/game/08_PlayStation_Store.png',
    price: 100000,
    stockLabel: '∞',
    isDigital: true,
  ),
  CatalogItem(
    name: 'Steam Wallet 50K',
    category: 'Voucher Game',
    asset: 'asset/game/07_Steam.png',
    price: 45000,
    stockLabel: '∞',
    isDigital: true,
  ),
  CatalogItem(
    name: 'Xbox Gift Card 100K',
    category: 'Voucher Game',
    asset: 'asset/game/10_Xbox.png',
    price: 100000,
    stockLabel: '∞',
    isDigital: true,
  ),
  CatalogItem(
    name: 'Razer Gold 100K',
    category: 'Voucher Game',
    asset: 'asset/game/15_Razer_Gold.png',
    price: 100000,
    stockLabel: '∞',
    isDigital: true,
  ),
];

List<CatalogItem> _buildCatalog() {
  final physical = [
    for (final p in productCatalog)
      CatalogItem(
        name: p.name,
        category: p.category,
        asset: p.asset,
        price: p.price,
        stockLabel: '${p.stock}',
      ),
  ];
  return [...physical, ..._virtualItems];
}

final List<CatalogItem> fullCatalog = _buildCatalog();

const List<String> catalogCategories = [
  'Semua',
  'Makanan',
  'Minuman',
  'Snack',
  'Rokok',
  'ATK',
  'Elektronik',
  'Perlengkapan',
  'Pulsa',
  'Paket Data',
  'Token PLN',
  'PDAM',
  'Voucher Game',
];
