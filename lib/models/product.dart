class Product {
  final String id;
  final String name;
  final String category;
  final String asset;
  final int price;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.asset,
    required this.price,
    required this.stock,
  });
}

int _stockFor(String name) => 20 + (name.hashCode.abs() % 130);

Product _p(String file, String name, String category, int price) {
  return Product(
    id: file,
    name: name,
    category: category,
    asset: 'asset/product/$file',
    price: price,
    stock: _stockFor(name),
  );
}

final List<Product> productCatalog = [
  // Makanan
  _p('01_01_Nasi_Goreng.png', 'Nasi Goreng', 'Makanan', 25000),
  _p('01_02_Mie_Goreng.png', 'Mie Goreng', 'Makanan', 22000),
  _p('01_03_Ayam_Geprek.png', 'Ayam Geprek', 'Makanan', 28000),
  _p('01_04_Soto_Ayam.png', 'Soto Ayam', 'Makanan', 20000),
  _p('01_05_Bakso.png', 'Bakso', 'Makanan', 18000),
  _p('01_06_Mie_Ayam.png', 'Mie Ayam', 'Makanan', 20000),
  _p('01_07_Nasi_Kuning.png', 'Nasi Kuning', 'Makanan', 17000),
  _p('01_08_Nasi_Uduk.png', 'Nasi Uduk', 'Makanan', 15000),
  _p('01_09_Lontong_Sayur.png', 'Lontong Sayur', 'Makanan', 15000),
  _p('01_10_Gado_Gado.png', 'Gado Gado', 'Makanan', 18000),
  _p('01_11_Sate_Ayam.png', 'Sate Ayam', 'Makanan', 25000),

  // Minuman
  _p('02_01_Es_Teh_Manis.png', 'Es Teh Manis', 'Minuman', 5000),
  _p('02_02_Es_Jeruk.png', 'Es Jeruk', 'Minuman', 7000),
  _p('02_03_Es_Kopi_Susu.png', 'Es Kopi Susu', 'Minuman', 12000),
  _p('02_04_Kopi_Hitam.png', 'Kopi Hitam', 'Minuman', 8000),
  _p('02_05_Kopi_Good_Day.png', 'Kopi Good Day', 'Minuman', 10000),
  _p('02_06_Teh_Hangat.png', 'Teh Hangat', 'Minuman', 4000),
  _p('02_07_Air_Mineral.png', 'Air Mineral', 'Minuman', 4000),
  _p('02_08_Coca_Cola.png', 'Coca Cola', 'Minuman', 8000),
  _p('02_09_Sprite.png', 'Sprite', 'Minuman', 8000),
  _p('02_10_Fanta.png', 'Fanta', 'Minuman', 8000),
  _p('02_11_Fanta_2.png', 'Fanta Strawberry', 'Minuman', 8000),

  // Snack
  _p('03_01_Indomie_Goreng.png', 'Indomie Goreng', 'Snack', 4500),
  _p('03_02_Indomie_Kuah.png', 'Indomie Kuah', 'Snack', 4000),
  _p('03_03_Mie_Sedaap.png', 'Mie Sedaap', 'Snack', 3500),
  _p('03_04_Supermi.png', 'Supermi', 'Snack', 3500),
  _p('03_05_Chitato.png', 'Chitato', 'Snack', 12000),
  _p('03_06_Lays.png', 'Lays', 'Snack', 13000),
  _p('03_07_Pringles.png', 'Pringles', 'Snack', 25000),
  _p('03_08_Taro.png', 'Taro', 'Snack', 8000),
  _p('03_09_Oreo.png', 'Oreo', 'Snack', 9000),
  _p('03_10_Pocky.png', 'Pocky', 'Snack', 10000),
  _p('03_11_Good_Time.png', 'Good Time', 'Snack', 8500),

  // Rokok
  _p('04_01_Roma_Kelapa.png', 'Roma Kelapa', 'Rokok', 8000),
  _p('04_02_Marlboro.png', 'Marlboro', 'Rokok', 32000),
  _p('04_03_Sampoerna_A.png', 'Sampoerna A', 'Rokok', 30000),
  _p('04_04_Djarum_Super.png', 'Djarum Super', 'Rokok', 28000),
  _p('04_05_Gudang_Garam.png', 'Gudang Garam', 'Rokok', 27000),
  _p('04_06_Dunhill.png', 'Dunhill', 'Rokok', 30000),
  _p('04_07_Camel.png', 'Camel', 'Rokok', 33000),
  _p('04_08_Esse.png', 'Esse', 'Rokok', 32000),
  _p('04_09_LA_Bold.png', 'LA Bold', 'Rokok', 25000),
  _p('04_10_Mild.png', 'Mild', 'Rokok', 26000),
  _p('04_11_Surya.png', 'Surya', 'Rokok', 24000),

  // ATK
  _p('05_01_Clas_Mild.png', 'Clas Mild', 'Rokok', 24000),
  _p('05_02_Pulpen_Pilot.png', 'Pulpen Pilot', 'ATK', 3000),
  _p('05_03_Pulpen_Standard.png', 'Pulpen Standard', 'ATK', 2000),
  _p('05_04_Pensil.png', 'Pensil', 'ATK', 2000),
  _p('05_05_Penghapus.png', 'Penghapus', 'ATK', 1500),
  _p('05_06_Spidol.png', 'Spidol', 'ATK', 5000),
  _p('05_07_Tip_Ex.png', 'Tip-Ex', 'ATK', 6000),
  _p('05_08_Stapler.png', 'Stapler', 'ATK', 15000),
  _p('05_09_Isi_Staples.png', 'Isi Staples', 'ATK', 5000),
  _p('05_10_Buku_Tulis.png', 'Buku Tulis', 'ATK', 4000),
  _p('05_11_Kertas_A4.png', 'Kertas A4', 'ATK', 50000),

  // Elektronik
  _p('06_01_Lakban.png', 'Lakban', 'ATK', 7000),
  _p('06_02_Gunting.png', 'Gunting', 'ATK', 8000),
  _p('06_03_Penggaris.png', 'Penggaris', 'ATK', 3000),
  _p('06_04_Charger.png', 'Charger', 'Elektronik', 35000),
  _p('06_05_Kabel_Data.png', 'Kabel Data', 'Elektronik', 25000),
  _p('06_06_Power_Bank.png', 'Power Bank', 'Elektronik', 150000),
  _p('06_07_Headset.png', 'Headset', 'Elektronik', 45000),
  _p('06_08_Flashdisk.png', 'Flashdisk', 'Elektronik', 60000),
  _p('06_09_Baterai_AA.png', 'Baterai AA', 'Elektronik', 15000),
  _p('06_10_Baterai_AAA.png', 'Baterai AAA', 'Elektronik', 15000),
  _p('06_11_Mouse_Wireless.png', 'Mouse Wireless', 'Elektronik', 75000),

  // Perlengkapan
  _p('07_01_Keyboard.png', 'Keyboard', 'Elektronik', 120000),
  _p('07_02_Speaker.png', 'Speaker', 'Elektronik', 85000),
  _p('07_03_Lampu_LED.png', 'Lampu LED', 'Perlengkapan', 25000),
  _p('07_04_Kipas_Mini.png', 'Kipas Mini', 'Perlengkapan', 35000),
  _p('07_05_TWS.png', 'TWS', 'Elektronik', 180000),
  _p('07_06_Sabun_Mandi.png', 'Sabun Mandi', 'Perlengkapan', 8000),
  _p('07_07_Sampo.png', 'Sampo', 'Perlengkapan', 20000),
  _p('07_08_Pasta_Gigi.png', 'Pasta Gigi', 'Perlengkapan', 12000),
  _p('07_09_Sikat_Gigi.png', 'Sikat Gigi', 'Perlengkapan', 5000),
  _p('07_10_Shampoo_Sunsilk.png', 'Shampoo Sunsilk', 'Perlengkapan', 22000),
  _p('07_11_Deterjen.png', 'Deterjen', 'Perlengkapan', 15000),
];
