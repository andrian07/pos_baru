import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../widgets/app_nav.dart';
import '../widgets/app_sidebar.dart';
import 'login_screen.dart';

const _primary = Color(0xFF2F6BFF);
const _bg = Color(0xFFF2F4F9);

class _SettingsTab {
  final IconData icon;
  final String label;
  const _SettingsTab(this.icon, this.label);
}

const _tabs = [
  _SettingsTab(Icons.storefront_rounded, 'Profil Toko'),
  _SettingsTab(Icons.people_alt_rounded, 'Pengguna'),
  _SettingsTab(Icons.devices_rounded, 'Perangkat'),
  _SettingsTab(Icons.print_rounded, 'Printer'),
  _SettingsTab(Icons.payments_rounded, 'Pembayaran'),
  _SettingsTab(Icons.inventory_2_rounded, 'Produk & Layanan'),
  _SettingsTab(Icons.sim_card_rounded, 'PPOB'),
  _SettingsTab(Icons.receipt_long_rounded, 'Pajak & Biaya'),
  _SettingsTab(Icons.lock_rounded, 'Keamanan'),
  _SettingsTab(Icons.notifications_rounded, 'Notifikasi'),
  _SettingsTab(Icons.backup_rounded, 'Backup & Restore'),
  _SettingsTab(Icons.tune_rounded, 'Preferensi'),
];

class SettingsScreen extends StatefulWidget {
  final AppUser user;
  const SettingsScreen({super.key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTab = 'Profil Toko';

  final _storeNameCtrl = TextEditingController(text: 'Cahaya Abadi');
  final _storeAddressCtrl = TextEditingController(
    text: 'Jl. Merdeka No. 123, Pontianak\nKalimantan Barat',
  );
  final _storePhoneCtrl = TextEditingController(text: '0812 3456 7890');
  final _storeEmailCtrl = TextEditingController(text: 'cahayaabadi@mail.com');
  final _footerCtrl = TextEditingController(
    text: 'Terima kasih\nAtas kunjungan Anda\nCahaya Abadi',
  );

  bool _showLogo = true;
  bool _showNama = true;
  bool _showAlamat = true;
  bool _showTelepon = true;
  bool _showTerimaKasih = true;

  String _currency = 'Rupiah (Rp)';
  String _dateFormat = '04 Oktober 2026';
  String _timeFormat = '24 Jam (14:30)';
  String _language = 'Bahasa Indonesia';
  String _timezone = 'Asia/Jakarta (WIB)';

  bool _scanBarcode = true;
  bool _showStockAtTransaction = true;
  bool _allowNoStock = false;
  bool _autoPrintReceipt = true;
  bool _confirmPrice = false;
  bool _openDrawer = true;
  String _defaultPaymentMethod = 'Tunai';

  bool _ppnActive = true;
  final _ppnPercentCtrl = TextEditingController(text: '11');
  final _taxNameCtrl = TextEditingController(text: 'PPN');
  bool _serviceFeeActive = false;
  final _serviceFeePercentCtrl = TextEditingController(text: '0');
  String _rounding = 'Tidak Ada';

  bool _ppobPulsa = true;
  bool _ppobPaketData = true;
  bool _ppobPln = true;
  bool _ppobPdam = true;
  bool _ppobVoucherGame = true;
  bool _ppobLainnya = true;

  String _sessionTimeout = '2 Jam';
  final _minPasswordCtrl = TextEditingController(text: '6');
  bool _logActivity = true;
  bool _restrictIp = false;
  final _pinKasirCtrl = TextEditingController(text: '123456');

  bool _notifTransaksi = true;
  bool _notifStok = true;
  bool _notifSaldo = true;
  bool _notifGagal = true;

  bool _payTunai = true;
  bool _payTransfer = true;
  bool _payQris = true;
  bool _payEwallet = true;
  bool _payKartu = false;
  bool _paySaldoTenant = true;

  bool _svcProdukPos = true;
  bool _svcPulsaData = true;
  bool _svcPln = true;
  bool _svcPdam = true;
  bool _svcVoucherGame = true;
  bool _svcLayananLain = true;

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _storeAddressCtrl.dispose();
    _storePhoneCtrl.dispose();
    _storeEmailCtrl.dispose();
    _footerCtrl.dispose();
    _ppnPercentCtrl.dispose();
    _taxNameCtrl.dispose();
    _serviceFeePercentCtrl.dispose();
    _minPasswordCtrl.dispose();
    _pinKasirCtrl.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          AppSidebar(
            items: appNavItems,
            selectedIndex: 6,
            onSelect: (i) => handleAppNavSelect(context, i, widget.user),
            onLogout: _handleLogout,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsTopBar(user: widget.user),
                  const SizedBox(height: 20),
                  _SettingsTabs(
                    selected: _selectedTab,
                    onSelect: (t) => setState(() => _selectedTab = t),
                  ),
                  const SizedBox(height: 20),
                  _buildTabContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'Profil Toko':
        return _buildProfilToko();
      case 'Pengguna':
        return _PenggunaTab(onAction: _notAvailable);
      case 'Perangkat':
        return _PerangkatTab(onAction: _notAvailable);
      case 'Printer':
        return _PrinterTab(onAction: _notAvailable);
      case 'Pembayaran':
        return _buildPembayaran();
      case 'Produk & Layanan':
        return _buildProdukLayanan();
      case 'PPOB':
        return SizedBox(width: double.infinity, child: _buildPpobCard());
      case 'Pajak & Biaya':
        return SizedBox(width: double.infinity, child: _buildPajakCard());
      case 'Keamanan':
        return _buildKeamananTab();
      case 'Notifikasi':
        return _buildNotifikasi();
      case 'Backup & Restore':
        return SizedBox(width: double.infinity, child: _buildBackupCard());
      case 'Preferensi':
        return SizedBox(width: double.infinity, child: _buildPengaturanUmumCard());
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProfilToko() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1100;
            final profileCard = _SectionCard(
              title: 'Profil Toko',
              subtitle: 'Informasi dasar toko yang akan digunakan pada struk dan laporan',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF17C7F2), Color(0xFF0066FF)],
                            ),
                          ),
                          child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 36),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () => _notAvailable('Ubah Logo'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Ubah Logo'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _FieldBox(
                    label: 'Nama Toko',
                    controller: _storeNameCtrl,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  _FieldBox(
                    label: 'Alamat Toko',
                    controller: _storeAddressCtrl,
                    maxLines: 2,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  _FieldBox(
                    label: 'Telepon',
                    controller: _storePhoneCtrl,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  _FieldBox(label: 'Email', controller: _storeEmailCtrl),
                ],
              ),
            );

            final strukCard = _SectionCard(
              title: 'Tampilan Struk',
              subtitle: 'Atur informasi yang tampil pada struk',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ToggleRow(
                    icon: Icons.image_outlined,
                    label: 'Tampilkan Logo Toko',
                    value: _showLogo,
                    onChanged: (v) => setState(() => _showLogo = v),
                  ),
                  _ToggleRow(
                    icon: Icons.storefront_outlined,
                    label: 'Tampilkan Nama Toko',
                    value: _showNama,
                    onChanged: (v) => setState(() => _showNama = v),
                  ),
                  _ToggleRow(
                    icon: Icons.location_on_outlined,
                    label: 'Tampilkan Alamat',
                    value: _showAlamat,
                    onChanged: (v) => setState(() => _showAlamat = v),
                  ),
                  _ToggleRow(
                    icon: Icons.phone_outlined,
                    label: 'Tampilkan Nomor Telepon',
                    value: _showTelepon,
                    onChanged: (v) => setState(() => _showTelepon = v),
                  ),
                  _ToggleRow(
                    icon: Icons.favorite_border_rounded,
                    label: 'Tampilkan Terima Kasih',
                    value: _showTerimaKasih,
                    onChanged: (v) => setState(() => _showTerimaKasih = v),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Pesan Footer Struk',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _footerCtrl,
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      filled: true,
                      fillColor: const Color(0xFFF7F8FB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                      ),
                    ),
                  ),
                ],
              ),
            );

            final preview = _ReceiptPreview(
              storeName: _storeNameCtrl.text,
              storeAddress: _storeAddressCtrl.text,
              storePhone: _storePhoneCtrl.text,
              footerMessage: _footerCtrl.text,
              showLogo: _showLogo,
              showNama: _showNama,
              showAlamat: _showAlamat,
              showTelepon: _showTelepon,
              showTerimaKasih: _showTerimaKasih,
            );

            if (!isWide) {
              return Column(
                children: [
                  profileCard,
                  const SizedBox(height: 20),
                  strukCard,
                  const SizedBox(height: 20),
                  preview,
                ],
              );
            }

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: profileCard),
                  const SizedBox(width: 20),
                  Expanded(flex: 4, child: strukCard),
                  const SizedBox(width: 20),
                  SizedBox(width: 260, child: preview),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth >= 1000 ? 3 : (constraints.maxWidth >= 620 ? 2 : 1);
            final width = (constraints.maxWidth - (cols - 1) * 20) / cols;
            final cards = [
              _buildPengaturanUmumCard(),
              _buildPengaturanKasirCard(),
              _buildPajakCard(),
              _buildPpobCard(),
              _buildKeamananCard(),
              _buildBackupCard(),
            ];
            return Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [for (final c in cards) SizedBox(width: width, child: c)],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPengaturanUmumCard() {
    return _SectionCard(
      title: 'Pengaturan Umum',
      subtitle: 'Atur preferensi dasar aplikasi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DropdownField(
            label: 'Mata Uang',
            value: _currency,
            options: const ['Rupiah (Rp)', 'US Dollar (\$)'],
            onChanged: (v) => setState(() => _currency = v),
          ),
          const SizedBox(height: 12),
          _DropdownField(
            label: 'Format Tanggal',
            value: _dateFormat,
            options: const ['04 Oktober 2026', '04/10/2026', '2026-10-04'],
            onChanged: (v) => setState(() => _dateFormat = v),
          ),
          const SizedBox(height: 12),
          _DropdownField(
            label: 'Format Waktu',
            value: _timeFormat,
            options: const ['24 Jam (14:30)', '12 Jam (02:30 PM)'],
            onChanged: (v) => setState(() => _timeFormat = v),
          ),
          const SizedBox(height: 12),
          _DropdownField(
            label: 'Bahasa',
            value: _language,
            options: const ['Bahasa Indonesia', 'English'],
            onChanged: (v) => setState(() => _language = v),
          ),
          const SizedBox(height: 12),
          _DropdownField(
            label: 'Zona Waktu',
            value: _timezone,
            options: const ['Asia/Jakarta (WIB)', 'Asia/Makassar (WITA)', 'Asia/Jayapura (WIT)'],
            onChanged: (v) => setState(() => _timezone = v),
          ),
        ],
      ),
    );
  }

  Widget _buildPengaturanKasirCard() {
    return _SectionCard(
      title: 'Pengaturan Kasir',
      subtitle: 'Atur preferensi transaksi di kasir',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ToggleRow(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Gunakan Scan Barcode',
            value: _scanBarcode,
            onChanged: (v) => setState(() => _scanBarcode = v),
          ),
          _ToggleRow(
            icon: Icons.inventory_outlined,
            label: 'Tampilkan Stok Saat Transaksi',
            value: _showStockAtTransaction,
            onChanged: (v) => setState(() => _showStockAtTransaction = v),
          ),
          _ToggleRow(
            icon: Icons.remove_shopping_cart_outlined,
            label: 'Boleh Transaksi Tanpa Stok',
            value: _allowNoStock,
            onChanged: (v) => setState(() => _allowNoStock = v),
          ),
          _ToggleRow(
            icon: Icons.receipt_outlined,
            label: 'Cetak Struk Otomatis',
            value: _autoPrintReceipt,
            onChanged: (v) => setState(() => _autoPrintReceipt = v),
          ),
          _ToggleRow(
            icon: Icons.price_check_rounded,
            label: 'Minta Konfirmasi Harga',
            value: _confirmPrice,
            onChanged: (v) => setState(() => _confirmPrice = v),
          ),
          _ToggleRow(
            icon: Icons.point_of_sale_rounded,
            label: 'Buka Laci Uang Saat Cetak',
            value: _openDrawer,
            onChanged: (v) => setState(() => _openDrawer = v),
          ),
          const SizedBox(height: 4),
          _DropdownField(
            label: 'Default Metode Pembayaran',
            value: _defaultPaymentMethod,
            options: const ['Tunai', 'Transfer', 'QRIS', 'E-Wallet'],
            onChanged: (v) => setState(() => _defaultPaymentMethod = v),
          ),
        ],
      ),
    );
  }

  Widget _buildPajakCard() {
    return _SectionCard(
      title: 'Pajak & Biaya',
      subtitle: 'Atur pajak dan biaya tambahan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ToggleRow(
            icon: Icons.account_balance_rounded,
            label: 'Aktifkan Pajak (PPN)',
            value: _ppnActive,
            onChanged: (v) => setState(() => _ppnActive = v),
          ),
          const SizedBox(height: 10),
          _FieldBox(
            label: 'Persentase PPN',
            controller: _ppnPercentCtrl,
            suffix: '%',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _FieldBox(label: 'Nama Pajak', controller: _taxNameCtrl),
          const SizedBox(height: 14),
          _ToggleRow(
            icon: Icons.design_services_outlined,
            label: 'Aktifkan Biaya Layanan',
            value: _serviceFeeActive,
            onChanged: (v) => setState(() => _serviceFeeActive = v),
          ),
          const SizedBox(height: 10),
          _FieldBox(
            label: 'Biaya Layanan',
            controller: _serviceFeePercentCtrl,
            suffix: '%',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _DropdownField(
            label: 'Pembulatan Total',
            value: _rounding,
            options: const ['Tidak Ada', 'Ke Atas Rp 100', 'Ke Bawah Rp 100', 'Terdekat Rp 500'],
            onChanged: (v) => setState(() => _rounding = v),
          ),
        ],
      ),
    );
  }

  Widget _buildPpobCard() {
    return _SectionCard(
      title: 'Pengaturan PPOB',
      subtitle: 'Atur layanan pulsa, paket data, PLN, PDAM dan lainnya',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ToggleRow(
            icon: Icons.sim_card_outlined,
            label: 'Aktifkan Penjualan Pulsa',
            value: _ppobPulsa,
            onChanged: (v) => setState(() => _ppobPulsa = v),
          ),
          _ToggleRow(
            icon: Icons.wifi_tethering_rounded,
            label: 'Aktifkan Paket Data',
            value: _ppobPaketData,
            onChanged: (v) => setState(() => _ppobPaketData = v),
          ),
          _ToggleRow(
            icon: Icons.bolt_outlined,
            label: 'Aktifkan PLN & Token',
            value: _ppobPln,
            onChanged: (v) => setState(() => _ppobPln = v),
          ),
          _ToggleRow(
            icon: Icons.water_drop_outlined,
            label: 'Aktifkan PDAM',
            value: _ppobPdam,
            onChanged: (v) => setState(() => _ppobPdam = v),
          ),
          _ToggleRow(
            icon: Icons.sports_esports_outlined,
            label: 'Aktifkan Voucher Game',
            value: _ppobVoucherGame,
            onChanged: (v) => setState(() => _ppobVoucherGame = v),
          ),
          _ToggleRow(
            icon: Icons.apps_rounded,
            label: 'Aktifkan Layanan Lainnya',
            value: _ppobLainnya,
            onChanged: (v) => setState(() => _ppobLainnya = v),
          ),
        ],
      ),
    );
  }

  Widget _buildKeamananCard() {
    return _SectionCard(
      title: 'Keamanan',
      subtitle: 'Atur keamanan dan akses aplikasi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DropdownField(
            label: 'Sesi Otomatis Logout',
            value: _sessionTimeout,
            options: const ['30 Menit', '1 Jam', '2 Jam', '4 Jam', 'Tidak Pernah'],
            onChanged: (v) => setState(() => _sessionTimeout = v),
          ),
          const SizedBox(height: 12),
          _FieldBox(
            label: 'Min. Panjang Password',
            controller: _minPasswordCtrl,
            suffix: 'karakter',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          _ToggleRow(
            icon: Icons.fact_check_outlined,
            label: 'Aktifkan Log Aktivitas',
            value: _logActivity,
            onChanged: (v) => setState(() => _logActivity = v),
          ),
          _ToggleRow(
            icon: Icons.vpn_lock_rounded,
            label: 'Batasi Akses per IP',
            value: _restrictIp,
            onChanged: (v) => setState(() => _restrictIp = v),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupCard() {
    return _SectionCard(
      title: 'Backup & Restore',
      subtitle: 'Kelola data backup dan restore',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 16, color: Colors.black45),
              const SizedBox(width: 8),
              const Text('Backup Terakhir', style: TextStyle(fontSize: 12.5, color: Colors.black54)),
              const Spacer(),
              Text(
                '04 Okt 2026 02:15',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Berhasil',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _notAvailable('Backup Sekarang'),
                  icon: const Icon(Icons.cloud_upload_rounded, size: 16),
                  label: const Text('Backup Sekarang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _notAvailable('Restore Data'),
                  icon: const Icon(Icons.restore_rounded, size: 16),
                  label: const Text('Restore Data'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_rounded, color: _primary, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Backup akan menyimpan data produk, pelanggan, transaksi, dan pengaturan sistem.',
                    style: TextStyle(fontSize: 11.5, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeamananTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;
        final keamananCard = _buildKeamananCard();
        final pinCard = _SectionCard(
          title: 'PIN Kasir',
          subtitle: 'PIN untuk otorisasi transaksi khusus oleh kasir',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldBox(
                label: 'PIN Kasir',
                controller: _pinKasirCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _notAvailable('Simpan PIN'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Simpan PIN'),
                ),
              ),
            ],
          ),
        );

        if (!isWide) {
          return Column(
            children: [keamananCard, const SizedBox(height: 20), pinCard],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: keamananCard),
            const SizedBox(width: 20),
            Expanded(child: pinCard),
          ],
        );
      },
    );
  }

  Widget _buildNotifikasi() {
    return _SectionCard(
      title: 'Notifikasi',
      subtitle: 'Atur notifikasi yang ingin Anda terima',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ToggleRow(
            icon: Icons.receipt_long_rounded,
            label: 'Notifikasi Transaksi Baru',
            value: _notifTransaksi,
            onChanged: (v) => setState(() => _notifTransaksi = v),
          ),
          _ToggleRow(
            icon: Icons.inventory_2_outlined,
            label: 'Notifikasi Stok Menipis',
            value: _notifStok,
            onChanged: (v) => setState(() => _notifStok = v),
          ),
          _ToggleRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Notifikasi Saldo Tenant Rendah',
            value: _notifSaldo,
            onChanged: (v) => setState(() => _notifSaldo = v),
          ),
          _ToggleRow(
            icon: Icons.error_outline_rounded,
            label: 'Notifikasi Transaksi Gagal',
            value: _notifGagal,
            onChanged: (v) => setState(() => _notifGagal = v),
          ),
        ],
      ),
    );
  }

  Widget _buildPembayaran() {
    return _SectionCard(
      title: 'Metode Pembayaran',
      subtitle: 'Aktifkan metode pembayaran yang dapat digunakan di kasir',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ToggleRow(
            icon: Icons.payments_rounded,
            label: 'Tunai',
            value: _payTunai,
            onChanged: (v) => setState(() => _payTunai = v),
          ),
          _ToggleRow(
            icon: Icons.account_balance_rounded,
            label: 'Transfer Bank',
            value: _payTransfer,
            onChanged: (v) => setState(() => _payTransfer = v),
          ),
          _ToggleRow(
            icon: Icons.qr_code_rounded,
            label: 'QRIS',
            value: _payQris,
            onChanged: (v) => setState(() => _payQris = v),
          ),
          _ToggleRow(
            icon: Icons.account_balance_wallet_rounded,
            label: 'E-Wallet',
            value: _payEwallet,
            onChanged: (v) => setState(() => _payEwallet = v),
          ),
          _ToggleRow(
            icon: Icons.credit_card_rounded,
            label: 'Kartu Debit / Kredit',
            value: _payKartu,
            onChanged: (v) => setState(() => _payKartu = v),
          ),
          _ToggleRow(
            icon: Icons.savings_rounded,
            label: 'Saldo Tenant',
            value: _paySaldoTenant,
            onChanged: (v) => setState(() => _paySaldoTenant = v),
          ),
        ],
      ),
    );
  }

  Widget _buildProdukLayanan() {
    return _SectionCard(
      title: 'Produk & Layanan Aktif',
      subtitle: 'Pilih produk dan layanan yang tersedia di aplikasi kasir',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ToggleRow(
            icon: Icons.shopping_bag_outlined,
            label: 'Produk POS',
            value: _svcProdukPos,
            onChanged: (v) => setState(() => _svcProdukPos = v),
          ),
          _ToggleRow(
            icon: Icons.phone_android_rounded,
            label: 'Pulsa & Paket Data',
            value: _svcPulsaData,
            onChanged: (v) => setState(() => _svcPulsaData = v),
          ),
          _ToggleRow(
            icon: Icons.bolt_rounded,
            label: 'PLN',
            value: _svcPln,
            onChanged: (v) => setState(() => _svcPln = v),
          ),
          _ToggleRow(
            icon: Icons.water_drop_rounded,
            label: 'PDAM',
            value: _svcPdam,
            onChanged: (v) => setState(() => _svcPdam = v),
          ),
          _ToggleRow(
            icon: Icons.sports_esports_rounded,
            label: 'Voucher Game',
            value: _svcVoucherGame,
            onChanged: (v) => setState(() => _svcVoucherGame = v),
          ),
          _ToggleRow(
            icon: Icons.miscellaneous_services_rounded,
            label: 'Layanan PPOB Lainnya',
            value: _svcLayananLain,
            onChanged: (v) => setState(() => _svcLayananLain = v),
          ),
        ],
      ),
    );
  }
}

class _SettingsTopBar extends StatelessWidget {
  final AppUser user;
  const _SettingsTopBar({required this.user});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;

        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Pengaturan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text(
              'Kelola konfigurasi sistem, toko, perangkat, pengguna dan preferensi aplikasi',
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
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  Text(
                    user.role,
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.black38),
            ],
          ),
        );

        final rightCluster = Row(
          mainAxisSize: MainAxisSize.min,
          children: [bellButton, const SizedBox(width: 12), avatarPill],
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: title), const SizedBox(width: 20), rightCluster],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [title, const SizedBox(height: 14), rightCluster],
        );
      },
    );
  }
}

class _SettingsTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _SettingsTabs({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final t in _tabs) ...[
            Material(
              color: t.label == selected ? _primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onSelect(t.label),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: t.label == selected
                          ? Colors.transparent
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        t.icon,
                        size: 16,
                        color: t.label == selected ? Colors.white : Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: t.label == selected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
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
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Colors.black45)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _FieldBox extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final String? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  const _FieldBox({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixText: suffix,
            suffixStyle: const TextStyle(fontSize: 12, color: Colors.black45),
            filled: true,
            fillColor: const Color(0xFFF7F8FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        PopupMenuButton<String>(
          initialValue: value,
          onSelected: onChanged,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          itemBuilder: (context) => [
            for (final o in options) PopupMenuItem(value: o, child: Text(o)),
          ],
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.black38),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black45),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: _primary,
          ),
        ],
      ),
    );
  }
}

class _ReceiptPreview extends StatelessWidget {
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final String footerMessage;
  final bool showLogo;
  final bool showNama;
  final bool showAlamat;
  final bool showTelepon;
  final bool showTerimaKasih;

  const _ReceiptPreview({
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    required this.footerMessage,
    required this.showLogo,
    required this.showNama,
    required this.showAlamat,
    required this.showTelepon,
    required this.showTerimaKasih,
  });

  @override
  Widget build(BuildContext context) {
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
          Center(
            child: Column(
              children: [
                if (showLogo)
                  Container(
                    width: 42,
                    height: 42,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF17C7F2), Color(0xFF0066FF)],
                      ),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                  ),
                if (showNama)
                  Text(
                    storeName.isEmpty ? 'Nama Toko' : storeName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                if (showAlamat)
                  Text(
                    storeAddress.replaceAll('\n', ', '),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10.5, color: Colors.black54),
                  ),
                if (showTelepon)
                  Text(
                    'Telp. $storePhone',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10.5, color: Colors.black54),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _DashedLine(),
          const SizedBox(height: 10),
          const _ReceiptLine(label: 'No.', value: 'TRX202610040001'),
          const _ReceiptLine(label: 'Tanggal', value: '04-10-2026 14:30'),
          const _ReceiptLine(label: 'Kasir', value: 'Andrian'),
          const SizedBox(height: 10),
          const _DashedLine(),
          const SizedBox(height: 10),
          const _ReceiptItemLine(name: 'Indomie Goreng', qty: 2, total: '24.000'),
          const _ReceiptItemLine(name: 'Token PLN 100K', qty: 1, total: '100.000'),
          const SizedBox(height: 10),
          const _DashedLine(),
          const SizedBox(height: 10),
          const _ReceiptLine(label: 'Total', value: 'Rp 124.000', bold: true),
          const _ReceiptLine(label: 'Tunai', value: 'Rp 150.000'),
          const _ReceiptLine(label: 'Kembali', value: 'Rp 26.000'),
          if (showTerimaKasih) ...[
            const SizedBox(height: 10),
            const _DashedLine(),
            const SizedBox(height: 10),
            Center(
              child: Text(
                footerMessage.isEmpty ? 'Terima kasih' : footerMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10.5, color: Colors.black54),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = (constraints.maxWidth / 6).floor();
          return Row(
            children: [
              for (var i = 0; i < count; i++) ...[
                Container(width: 3, height: 1, color: Colors.black26),
                const SizedBox(width: 3),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _ReceiptLine({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 13 : 11,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style.copyWith(color: bold ? Colors.black : Colors.black54)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _ReceiptItemLine extends StatelessWidget {
  final String name;
  final int qty;
  final String total;
  const _ReceiptItemLine({required this.name, required this.qty, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(name, style: const TextStyle(fontSize: 11))),
          Text('$qty', style: const TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(width: 10),
          Text(total, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class _AppUserRow {
  final String name;
  final String role;
  final bool active;
  const _AppUserRow(this.name, this.role, this.active);
}

const _dummyUsers = [
  _AppUserRow('Andrian Chen', 'Admin', true),
  _AppUserRow('Rizky Pratama', 'Kasir', true),
  _AppUserRow('Sari Wulandari', 'Kasir', true),
  _AppUserRow('Budi Santoso', 'Kasir', false),
];

class _PenggunaTab extends StatelessWidget {
  final ValueChanged<String> onAction;
  const _PenggunaTab({required this.onAction});

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Pengguna', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text(
                      'Kelola kasir, admin, role dan hak akses pengguna',
                      style: TextStyle(fontSize: 11.5, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => onAction('Tambah Pengguna'),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                label: const Text('Tambah Pengguna'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < _dummyUsers.length; i++) ...[
            if (i > 0)
              Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: _primary,
                    child: Text(
                      _dummyUsers[i].name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _dummyUsers[i].name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _dummyUsers[i].role,
                          style: const TextStyle(fontSize: 11.5, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (_dummyUsers[i].active
                              ? const Color(0xFF22C55E)
                              : const Color(0xFF9CA3AF))
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _dummyUsers[i].active ? 'Aktif' : 'Nonaktif',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _dummyUsers[i].active
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () => onAction('Edit ${_dummyUsers[i].name}'),
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.black54),
                  ),
                  IconButton(
                    onPressed: () => onAction(
                      _dummyUsers[i].active
                          ? 'Nonaktifkan ${_dummyUsers[i].name}'
                          : 'Aktifkan ${_dummyUsers[i].name}',
                    ),
                    icon: Icon(
                      _dummyUsers[i].active ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeviceRow {
  final String name;
  final String terminal;
  final bool online;
  const _DeviceRow(this.name, this.terminal, this.online);
}

const _dummyDevices = [
  _DeviceRow('Windows PC - Kasir 1', 'Kasir 1', true),
  _DeviceRow('Tablet Android - Kasir 2', 'Kasir 2', true),
  _DeviceRow('iPad - Kasir 3', 'Kasir 3', false),
];

class _PerangkatTab extends StatelessWidget {
  final ValueChanged<String> onAction;
  const _PerangkatTab({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: 'Perangkat Terhubung',
          subtitle: 'Perangkat dan terminal kasir yang terdaftar',
          child: Column(
            children: [
              for (var i = 0; i < _dummyDevices.length; i++) ...[
                if (i > 0) Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.devices_rounded, size: 18, color: Colors.black54),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _dummyDevices[i].name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Terminal: ${_dummyDevices[i].terminal}',
                              style: const TextStyle(fontSize: 11.5, color: Colors.black45),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (_dummyDevices[i].online
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFF9CA3AF))
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _dummyDevices[i].online ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _dummyDevices[i].online
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => onAction('Hapus ${_dummyDevices[i].name}'),
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SectionCard(
          title: 'Pengaturan Sinkronisasi',
          subtitle: 'Atur sinkronisasi data antar perangkat',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ToggleRow(
                icon: Icons.sync_rounded,
                label: 'Sinkronisasi Otomatis',
                value: true,
                onChanged: (_) => onAction('Sinkronisasi Otomatis'),
              ),
              const SizedBox(height: 10),
              _DropdownField(
                label: 'Interval Sinkronisasi',
                value: '5 Menit',
                options: const ['1 Menit', '5 Menit', '15 Menit', '30 Menit'],
                onChanged: (_) => onAction('Interval Sinkronisasi'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrinterDevice {
  final String name;
  final String type;
  final String address;
  const _PrinterDevice(this.name, this.type, this.address);
}

const _pairedPrinters = [
  _PrinterDevice('EPSON TM-T82', 'Bluetooth', '00:11:62:3A:9B:4C'),
  _PrinterDevice('Xprinter XP-58', 'Bluetooth', '00:1B:10:4F:2A:91'),
  _PrinterDevice('EPSON TM-T88V', 'LAN / WiFi', '192.168.1.50'),
  _PrinterDevice('Bixolon SPP-R200', 'USB', 'USB001'),
];

const _discoverablePrinters = [
  _PrinterDevice('RONGTA RP326', 'Bluetooth', '00:1A:7D:DA:71:13'),
  _PrinterDevice('Zjiang ZJ-5890', 'Bluetooth', '00:02:5B:00:12:34'),
];

IconData _iconForPrinterType(String type) {
  switch (type) {
    case 'Bluetooth':
      return Icons.bluetooth_rounded;
    case 'LAN / WiFi':
      return Icons.wifi_rounded;
    default:
      return Icons.usb_rounded;
  }
}

class _PrinterTab extends StatefulWidget {
  final ValueChanged<String> onAction;
  const _PrinterTab({required this.onAction});

  @override
  State<_PrinterTab> createState() => _PrinterTabState();
}

class _PrinterTabState extends State<_PrinterTab> {
  _PrinterDevice _selected = _pairedPrinters[0];
  bool _autoPrint = true;

  Future<void> _openPicker() async {
    final picked = await showModalBottomSheet<_PrinterDevice>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _PrinterPickerSheet(selected: _selected),
    );
    if (picked != null) {
      setState(() => _selected = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Pengaturan Printer Struk',
      subtitle: 'Hubungkan dan atur printer struk Bluetooth, LAN, atau USB',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Printer Aktif', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Material(
            color: const Color(0xFFF7F8FB),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _openPicker,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _iconForPrinterType(_selected.type),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selected.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${_selected.type} • ${_selected.address}',
                            style: const TextStyle(fontSize: 11.5, color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Ganti',
                      style: TextStyle(fontSize: 12.5, color: _primary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: _primary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _ToggleRow(
            icon: Icons.print_rounded,
            label: 'Auto Print Setelah Transaksi',
            value: _autoPrint,
            onChanged: (v) => setState(() => _autoPrint = v),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.onAction('Test Print ke ${_selected.name}'),
                  icon: const Icon(Icons.description_outlined, size: 16),
                  label: const Text('Test Print'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => widget.onAction('Simpan Printer'),
                  icon: const Icon(Icons.save_rounded, size: 16),
                  label: const Text('Simpan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

class _PrinterPickerSheet extends StatefulWidget {
  final _PrinterDevice selected;
  const _PrinterPickerSheet({required this.selected});

  @override
  State<_PrinterPickerSheet> createState() => _PrinterPickerSheetState();
}

class _PrinterPickerSheetState extends State<_PrinterPickerSheet> {
  final List<_PrinterDevice> _devices = List.of(_pairedPrinters);
  bool _scanning = false;

  Future<void> _scan() async {
    setState(() => _scanning = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _scanning = false;
      for (final d in _discoverablePrinters) {
        if (!_devices.any((e) => e.address == d.address)) _devices.add(d);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: Text('Pilih Printer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                TextButton.icon(
                  onPressed: _scanning ? null : _scan,
                  icon: _scanning
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(_scanning ? 'Mencari...' : 'Cari Printer'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: _devices.length,
                separatorBuilder: (context, i) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final d = _devices[i];
                  final isSelected = d.address == widget.selected.address;
                  return Material(
                    color: isSelected ? const Color(0xFFEFF4FF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).pop(d),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? _primary : Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _iconForPrinterType(d.type),
                              size: 18,
                              color: isSelected ? _primary : Colors.black45,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    d.name,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${d.type} • ${d.address}',
                                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded, color: _primary, size: 18),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
