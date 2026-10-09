import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/database/database_helper.dart';
import '../models/judul.dart';
import '../models/buku.dart';
import '../models/kunjungan.dart';
import '../models/transaksi.dart';

class LibraryProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Judul> _listJudul = [];
  List<Buku> _listBuku = [];
  List<Kunjungan> _listKunjungan = [];
  List<Transaksi> _listTransaksi = [];

  bool _isLoading = true;
  int _activeMenuIndex = 0;

  // --- Dashboard Filters ---
  String _dashboardMonth = 'Semua Bulan'; // 'Semua Bulan', '01', '02', ..., '12'
  String _dashboardYear = 'Semua Tahun';   // 'Semua Tahun', '2026', '2025', '2024'

  // --- Pengunjung Filters ---
  String _searchKunjunganQuery = '';
  String _selectedKategoriKunjungan = 'Semua Kategori';

  // --- Daftar Buku Filters & Sorting ---
  String _searchBukuQuery = '';
  String _selectedStatusBukuFilter = 'Semua Status'; // 'Semua Status', 'Tersedia', 'Dipinjam', 'Rusak', 'Hilang'
  String _selectedBukuSortOrder = 'Terbaru'; // 'Terbaru', 'Terlama', 'A-Z', 'Z-A'

  // --- Transaksi Filters ---
  String _searchTransaksiQuery = '';
  String _selectedStatusTransaksi = 'Semua Status';

  // Getters
  List<Judul> get listJudul => _listJudul;
  List<Buku> get listBuku => _listBuku;
  List<Kunjungan> get listKunjungan => _listKunjungan;
  List<Transaksi> get listTransaksi => _listTransaksi;
  bool get isLoading => _isLoading;
  int get activeMenuIndex => _activeMenuIndex;

  String get dashboardMonth => _dashboardMonth;
  String get dashboardYear => _dashboardYear;

  String get searchKunjunganQuery => _searchKunjunganQuery;
  String get selectedKategoriKunjungan => _selectedKategoriKunjungan;

  String get searchBukuQuery => _searchBukuQuery;
  String get selectedStatusBukuFilter => _selectedStatusBukuFilter;
  String get selectedBukuSortOrder => _selectedBukuSortOrder;

  String get searchTransaksiQuery => _searchTransaksiQuery;
  String get selectedStatusTransaksi => _selectedStatusTransaksi;

  LibraryProvider() {
    loadAllData();
  }

  void setActiveMenu(int index) {
    _activeMenuIndex = index;
    notifyListeners();
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _listJudul = await _dbHelper.getAllJudul();
      _listBuku = await _dbHelper.getAllBuku();
      _listKunjungan = await _dbHelper.getAllKunjungan();
      _listTransaksi = await _dbHelper.getAllTransaksi();
    } catch (e) {
      debugPrint('Error loading library data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Filter Setting Methods ---
  void setDashboardMonth(String month) {
    _dashboardMonth = month;
    notifyListeners();
  }

  void setDashboardYear(String year) {
    _dashboardYear = year;
    notifyListeners();
  }

  void setSearchKunjungan(String query) {
    _searchKunjunganQuery = query;
    notifyListeners();
  }

  void setKategoriKunjungan(String kategori) {
    _selectedKategoriKunjungan = kategori;
    notifyListeners();
  }

  void setSearchBuku(String query) {
    _searchBukuQuery = query;
    notifyListeners();
  }

  void setStatusBukuFilter(String status) {
    _selectedStatusBukuFilter = status;
    notifyListeners();
  }

  void setBukuSortOrder(String sort) {
    _selectedBukuSortOrder = sort;
    notifyListeners();
  }

  void setSearchTransaksi(String query) {
    _searchTransaksiQuery = query;
    notifyListeners();
  }

  void setStatusTransaksi(String status) {
    _selectedStatusTransaksi = status;
    notifyListeners();
  }

  // --- Date Parsing Helper ---
  bool _matchesMonthYear(String dateStr, String targetMonth, String targetYear) {
    if (targetMonth == 'Semua Bulan' && targetYear == 'Semua Tahun') {
      return true;
    }
    if (dateStr.isEmpty) return false;

    try {
      // Expected formats: "dd/MM/yyyy HH:mm" or "dd/MM/yyyy"
      final parts = dateStr.split(' ')[0].split('/');
      if (parts.length >= 3) {
        final m = parts[1]; // MM
        final y = parts[2]; // yyyy

        final monthMatch = targetMonth == 'Semua Bulan' || m == targetMonth;
        final yearMatch = targetYear == 'Semua Tahun' || y == targetYear;

        return monthMatch && yearMatch;
      }
    } catch (e) {
      debugPrint('Date parse error for $dateStr: $e');
    }
    return true;
  }

  // --- DASHBOARD FILTERED METRICS ---
  List<Kunjungan> get dashboardFilteredKunjungan {
    return _listKunjungan.where((k) {
      return _matchesMonthYear(k.waktuKunjungan, _dashboardMonth, _dashboardYear);
    }).toList();
  }

  List<Transaksi> get dashboardFilteredTransaksi {
    return _listTransaksi.where((t) {
      return _matchesMonthYear(t.waktuPinjam, _dashboardMonth, _dashboardYear);
    }).toList();
  }

  int get countJudulDashboard => _listJudul.length;

  int get countBukuDashboard => _listBuku.length;

  int get countPengunjungDashboard => dashboardFilteredKunjungan.length;

  int get countDipinjamDashboard {
    if (_dashboardMonth == 'Semua Bulan' && _dashboardYear == 'Semua Tahun') {
      return _listBuku.where((b) => b.status == 'Dipinjam').length;
    }
    return dashboardFilteredTransaksi.where((t) => t.status == 'Dipinjam' || t.status == 'Terlambat').length;
  }

  int get countTerlambatDashboard {
    if (_dashboardMonth == 'Semua Bulan' && _dashboardYear == 'Semua Tahun') {
      return _listTransaksi.where((t) => t.status == 'Terlambat').length;
    }
    return dashboardFilteredTransaksi.where((t) => t.status == 'Terlambat').length;
  }

  // --- FILTERED & SORTED DAFTAR BUKU ---
  List<Judul> get filteredAndSortedJudul {
    var list = _listJudul.where((j) {
      final q = _searchBukuQuery.toLowerCase();
      return j.judul.toLowerCase().contains(q) ||
          j.noJudul.toLowerCase().contains(q) ||
          j.penerbit.toLowerCase().contains(q) ||
          j.isbn.toLowerCase().contains(q);
    }).toList();

    switch (_selectedBukuSortOrder) {
      case 'Terlama':
        list.sort((a, b) => a.noJudul.compareTo(b.noJudul));
        break;
      case 'A-Z':
        list.sort((a, b) => a.judul.toLowerCase().compareTo(b.judul.toLowerCase()));
        break;
      case 'Z-A':
        list.sort((a, b) => b.judul.toLowerCase().compareTo(a.judul.toLowerCase()));
        break;
      case 'Terbaru':
      default:
        list.sort((a, b) => b.noJudul.compareTo(a.noJudul));
        break;
    }
    return list;
  }

  List<Buku> get filteredAndSortedBuku {
    var list = _listBuku.where((b) {
      final q = _searchBukuQuery.toLowerCase();
      final title = b.judulTitle ?? '';
      final matchesSearch = b.noBuku.toLowerCase().contains(q) ||
          b.noJudul.toLowerCase().contains(q) ||
          title.toLowerCase().contains(q);

      final matchesStatus = _selectedStatusBukuFilter == 'Semua Status' ||
          b.status == _selectedStatusBukuFilter;

      return matchesSearch && matchesStatus;
    }).toList();

    switch (_selectedBukuSortOrder) {
      case 'Terlama':
        list.sort((a, b) => a.noBuku.compareTo(b.noBuku));
        break;
      case 'A-Z':
        list.sort((a, b) => (a.judulTitle ?? '').toLowerCase().compareTo((b.judulTitle ?? '').toLowerCase()));
        break;
      case 'Z-A':
        list.sort((a, b) => (b.judulTitle ?? '').toLowerCase().compareTo((a.judulTitle ?? '').toLowerCase()));
        break;
      case 'Terbaru':
      default:
        list.sort((a, b) => b.noBuku.compareTo(a.noBuku));
        break;
    }
    return list;
  }

  // --- FILTERED PENGUNJUNG ---
  List<Kunjungan> get filteredKunjungan {
    return _listKunjungan.where((k) {
      final matchesSearch = k.nama.toLowerCase().contains(_searchKunjunganQuery.toLowerCase()) ||
          k.kelas.toLowerCase().contains(_searchKunjunganQuery.toLowerCase()) ||
          k.keperluan.toLowerCase().contains(_searchKunjunganQuery.toLowerCase());

      final matchesKategori = _selectedKategoriKunjungan == 'Semua Kategori' ||
          k.kategori == _selectedKategoriKunjungan;

      return matchesSearch && matchesKategori;
    }).toList();
  }

  // --- FILTERED TRANSAKSI ---
  List<Transaksi> get filteredTransaksi {
    return _listTransaksi.where((t) {
      final title = t.judulBuku ?? '';
      final matchesSearch = t.nama.toLowerCase().contains(_searchTransaksiQuery.toLowerCase()) ||
          t.noBuku.toLowerCase().contains(_searchTransaksiQuery.toLowerCase()) ||
          title.toLowerCase().contains(_searchTransaksiQuery.toLowerCase()) ||
          t.noTransaksi.toLowerCase().contains(_searchTransaksiQuery.toLowerCase());

      final matchesStatus = _selectedStatusTransaksi == 'Semua Status' ||
          t.status == _selectedStatusTransaksi;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // --- CRUD Actions ---

  Future<bool> addKunjungan({
    required String nama,
    required String kategori,
    required String kelas,
    required String keperluan,
  }) async {
    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(now);
    final noKnj = 'KNJ-${now.millisecondsSinceEpoch.toString().substring(5)}';

    final newKunjungan = Kunjungan(
      noKunjungan: noKnj,
      nama: nama,
      kategori: kategori,
      kelas: kelas,
      keperluan: keperluan,
      waktuKunjungan: dateStr,
    );

    await _dbHelper.insertKunjungan(newKunjungan);
    await loadAllData();
    return true;
  }

  Future<bool> addJudul(Judul judul) async {
    await _dbHelper.insertJudul(judul);
    await loadAllData();
    return true;
  }

  Future<bool> updateJudul(Judul judul) async {
    await _dbHelper.updateJudul(judul);
    await loadAllData();
    return true;
  }

  Future<bool> deleteJudul(String noJudul) async {
    await _dbHelper.deleteJudul(noJudul);
    await loadAllData();
    return true;
  }

  Future<bool> addBuku(Buku buku) async {
    await _dbHelper.insertBuku(buku);
    await loadAllData();
    return true;
  }

  Future<bool> deleteBuku(String noBuku) async {
    await _dbHelper.deleteBuku(noBuku);
    await loadAllData();
    return true;
  }

  Future<bool> addTransaksi({
    required String noBuku,
    required String nama,
    required String kelas,
    required DateTime tanggalPinjam,
    required DateTime tanggalKembali,
  }) async {
    final now = DateTime.now();
    final noTrx = 'TRX-${DateFormat('yyyyMMdd').format(now)}-${now.millisecondsSinceEpoch.toString().substring(8)}';
    
    final pinjamStr = DateFormat('dd/MM/yyyy').format(tanggalPinjam);
    final kembaliStr = DateFormat('dd/MM/yyyy').format(tanggalKembali);

    final transaksi = Transaksi(
      noTransaksi: noTrx,
      noBuku: noBuku,
      nama: nama,
      kelas: kelas,
      waktuPinjam: pinjamStr,
      waktuKembali: kembaliStr,
      status: 'Dipinjam',
    );

    await _dbHelper.insertTransaksi(transaksi);
    await loadAllData();
    return true;
  }

  Future<bool> processReturn(String noTransaksi, String noBuku) async {
    final now = DateTime.now();
    final todayStr = DateFormat('dd/MM/yyyy').format(now);

    await _dbHelper.kembalikanBuku(noTransaksi, noBuku, todayStr);
    await loadAllData();
    return true;
  }
}
