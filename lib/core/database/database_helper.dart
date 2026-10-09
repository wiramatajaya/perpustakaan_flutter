import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/judul.dart';
import '../../models/buku.dart';
import '../../models/kunjungan.dart';
import '../../models/transaksi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('my_perpus.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Initialize FFI for Desktop (Windows, Linux, macOS)
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath = '';
    if (kIsWeb) {
      dbPath = filePath;
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final docsDir = await getApplicationDocumentsDirectory();
      final appDir = Directory(join(docsDir.path, 'MyPerpus'));
      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }
      dbPath = join(appDir.path, filePath);
    } else {
      final defaultPath = await getDatabasesPath();
      dbPath = join(defaultPath, filePath);
    }

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Table Judul
    await db.execute('''
      CREATE TABLE judul (
        no_judul TEXT PRIMARY KEY,
        judul TEXT NOT NULL,
        penerbit TEXT NOT NULL,
        tahun_terbit INTEGER NOT NULL,
        isbn TEXT NOT NULL,
        asal TEXT NOT NULL,
        deskripsi TEXT NOT NULL
      )
    ''');

    // 2. Table Buku (Eksemplar)
    await db.execute('''
      CREATE TABLE buku (
        no_buku TEXT PRIMARY KEY,
        no_judul TEXT NOT NULL,
        status TEXT NOT NULL,
        keterangan TEXT NOT NULL,
        FOREIGN KEY (no_judul) REFERENCES judul (no_judul) ON DELETE CASCADE
      )
    ''');

    // 3. Table Kunjungan
    await db.execute('''
      CREATE TABLE kunjungan (
        no_kunjungan TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        kategori TEXT NOT NULL,
        kelas TEXT NOT NULL,
        keperluan TEXT NOT NULL,
        waktu_kunjungan TEXT NOT NULL,
        no_buku TEXT
      )
    ''');

    // 4. Table Transaksi
    await db.execute('''
      CREATE TABLE transaksi (
        no_transaksi TEXT PRIMARY KEY,
        no_buku TEXT NOT NULL,
        nama TEXT NOT NULL,
        kelas TEXT NOT NULL,
        waktu_pinjam TEXT NOT NULL,
        waktu_kembali TEXT NOT NULL,
        status TEXT NOT NULL,
        waktu_dikembalikan TEXT,
        FOREIGN KEY (no_buku) REFERENCES buku (no_buku) ON DELETE CASCADE
      )
    ''');

    // Seed Initial Data for Elementary School Library
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now();

    // --- Seed Judul (15 Titles) ---
    final sampleJudul = [
      Judul(
        noJudul: 'JDL-001',
        judul: 'Laskar Pelangi',
        penerbit: 'Bentang Pustaka',
        tahunTerbit: 2005,
        isbn: '9789793062792',
        asal: 'Hibah Kemdikbud',
        deskripsi: 'Kisah perjuangan 10 murid Sekolah Dasar di Belitung.',
      ),
      Judul(
        noJudul: 'JDL-002',
        judul: 'Ensiklopedia Sains Anak: Tata Surya',
        penerbit: 'Erlangga For Kids',
        tahunTerbit: 2021,
        isbn: '9786022415123',
        asal: 'Pembelian BOS',
        deskripsi: 'Panduan sains astronomi populer bergambar untuk siswa SD.',
      ),
      Judul(
        noJudul: 'JDL-003',
        judul: 'Cerita Rakyat Nusantara: Malin Kundang',
        penerbit: 'Gramedia',
        tahunTerbit: 2019,
        isbn: '9786020312019',
        asal: 'Hibah Perpusda',
        deskripsi: 'Kumpulan cerita fabel dan legenda mendidik dari Indonesia.',
      ),
      Judul(
        noJudul: 'JDL-004',
        judul: 'Matematika Ceria Kelas 4 SD',
        penerbit: 'Yudhistira',
        tahunTerbit: 2022,
        isbn: '9789790192812',
        asal: 'Pembelian BOS',
        deskripsi: 'Buku teks pelajaran Matematika SD Kurikulum Merdeka.',
      ),
      Judul(
        noJudul: 'JDL-005',
        judul: 'Si Kancil Yang Cerdik',
        penerbit: 'Tiga Serangkai',
        tahunTerbit: 2020,
        isbn: '9789790184421',
        asal: 'Pembelian BOS',
        deskripsi: 'Dongeng fabel anak bergambar penuh pesan moral.',
      ),
      Judul(
        noJudul: 'JDL-006',
        judul: 'Kamus Visual Bahasa Inggris SD',
        penerbit: 'Kesaint Blanc',
        tahunTerbit: 2021,
        isbn: '9789795938123',
        asal: 'Hibah Alumni',
        deskripsi: 'Kamus bergambar interaktif 1000 kata untuk anak.',
      ),
      Judul(
        noJudul: 'JDL-007',
        judul: 'Petualangan Si Bolang di Hutan',
        penerbit: 'Balai Pustaka',
        tahunTerbit: 2018,
        isbn: '9789794073312',
        asal: 'Pembelian BOS',
        deskripsi: 'Cerita petualangan edukatif menjaga kelestarian alam.',
      ),
      Judul(
        noJudul: 'JDL-008',
        judul: 'Pendidikan Pancasila Kelas 6',
        penerbit: 'Quadra',
        tahunTerbit: 2023,
        isbn: '9786023134912',
        asal: 'Pembelian BOS',
        deskripsi: 'Buku pelajaran PPKn persiapan kelulusan SD.',
      ),
      Judul(
        noJudul: 'JDL-009',
        judul: 'Komik Sains: Tubuh Manusia',
        penerbit: 'Elex Media',
        tahunTerbit: 2020,
        isbn: '9786020485912',
        asal: 'Pembelian BOS',
        deskripsi: 'Penjelasan organ tubuh manusia dengan komik lucu.',
      ),
      Judul(
        noJudul: 'JDL-010',
        judul: 'Kumpulan Puisi Anak: Bintang Kecil',
        penerbit: 'Pustaka Anak',
        tahunTerbit: 2017,
        isbn: '9789793102941',
        asal: 'Sumbangan Orangtua',
        deskripsi: 'Kumpulan karya puisi sederhana penuh kegembiraan.',
      ),
      Judul(
        noJudul: 'JDL-011',
        judul: 'Atlas Indonesia dan Dunia',
        penerbit: 'Dharma Utama',
        tahunTerbit: 2022,
        isbn: '9786028821098',
        asal: 'Pembelian BOS',
        deskripsi: 'Peta provinsi Indonesia dan benua-benua dunia lengkap.',
      ),
      Judul(
        noJudul: 'JDL-012',
        judul: 'Ilmu Pengetahuan Alam Kelas 5 SD',
        penerbit: 'Kemdikbudristek',
        tahunTerbit: 2023,
        isbn: '9786022443012',
        asal: 'Pemerintah Pusat',
        deskripsi: 'Buku IPAS SD Kurikulum Merdeka Terbitan Resmi.',
      ),
      Judul(
        noJudul: 'JDL-013',
        judul: 'Kisah 25 Nabi dan Rasul',
        penerbit: 'Mizan Kids',
        tahunTerbit: 2019,
        isbn: '9789797521894',
        asal: 'Hibah Komite',
        deskripsi: 'Kisah teladan 25 nabi disajikan dengan ilustrasi indah.',
      ),
      Judul(
        noJudul: 'JDL-014',
        judul: 'Bahasa Indonesia: Pandai Menulis',
        penerbit: 'Tiga Serangkai',
        tahunTerbit: 2021,
        isbn: '9789790189912',
        asal: 'Pembelian BOS',
        deskripsi: 'Panduan tata bahasa dan mengarang cerita pendek.',
      ),
      Judul(
        noJudul: 'JDL-015',
        judul: 'Dongeng Sebelum Tidur: Kancil & Buaya',
        penerbit: 'Bintang Indonesia',
        tahunTerbit: 2020,
        isbn: '9786021102911',
        asal: 'Hibah Perpusda',
        deskripsi: 'Dongeng klasik pengantar tidur yang mendidik.',
      ),
    ];

    for (var j in sampleJudul) {
      await db.insert('judul', j.toMap());
    }

    // --- Seed Buku (44 Exemplars / Copies) ---
    // Generate 44 copies across the 15 titles to match the dashboard stat (44 total copies)
    int copyCounter = 1;
    List<Buku> sampleBuku = [];

    // Assign status breakdown: 30 Dipinjam (19 Terlambat, 11 Normal Dipinjam), 14 Tersedia
    for (int i = 0; i < 44; i++) {
      String jdlId = sampleJudul[i % sampleJudul.length].noJudul;
      String bId = 'BK-${jdlId.replaceAll('JDL-', '')}-${(i % 3 + 1).toString().padLeft(2, '0')}';
      if (sampleBuku.any((element) => element.noBuku == bId)) {
        bId = 'BK-${jdlId.replaceAll('JDL-', '')}-${copyCounter.toString().padLeft(2, '0')}';
      }
      copyCounter++;

      String status = 'Tersedia';
      if (i < 30) {
        status = 'Dipinjam';
      } else if (i == 40) {
        status = 'Rusak';
      }

      sampleBuku.add(Buku(
        noBuku: bId,
        noJudul: jdlId,
        status: status,
        keterangan: status == 'Rusak' ? 'Cover robek sedikit' : 'Kondisi baik',
      ));
    }

    for (var b in sampleBuku) {
      await db.insert('buku', b.toMap());
    }

    // --- Seed Kunjungan (Matching the mockup logs & 105 visitors metric) ---
    final visitorNames = [
      {'nama': 'Dewi Lestari', 'kelas': 'VI A', 'kategori': 'Siswa'},
      {'nama': 'Rina Wijaya', 'kelas': 'VI A', 'kategori': 'Siswa'},
      {'nama': 'Ahmad Fauzi', 'kelas': 'VI A', 'kategori': 'Siswa'},
      {'nama': 'Budi Santoso', 'kelas': 'VI A', 'kategori': 'Siswa'},
      {'nama': 'Siti Aminah', 'kelas': 'VI A', 'kategori': 'Siswa'},
      {'nama': 'Rizky Pratama', 'kelas': 'VI A', 'kategori': 'Siswa'},
      {'nama': 'Doni Kusuma', 'kelas': '5B', 'kategori': 'Siswa'},
      {'nama': 'Nabila Putri', 'kelas': '4A', 'kategori': 'Siswa'},
      {'nama': 'Pak Hartono', 'kelas': 'Guru Kelas 4', 'kategori': 'Guru'},
      {'nama': 'Ibu Ratna', 'kelas': 'Guru Bahasa', 'kategori': 'Guru'},
    ];

    for (int i = 0; i < 105; i++) {
      final v = visitorNames[i % visitorNames.length];
      final visitDate = now.subtract(Duration(minutes: (105 - i) * 35));
      final dateStr = "${visitDate.day.toString().padLeft(2, '0')}/${visitDate.month.toString().padLeft(2, '0')}/${visitDate.year} ${visitDate.hour.toString().padLeft(2, '0')}:${visitDate.minute.toString().padLeft(2, '0')}";

      await db.insert('kunjungan', Kunjungan(
        noKunjungan: 'KNJ-${(i + 1).toString().padLeft(4, '0')}',
        nama: v['nama']!,
        kategori: v['kategori']!,
        kelas: v['kelas']!,
        keperluan: 'Membaca Buku Novel',
        waktuKunjungan: dateStr,
      ).toMap());
    }

    // --- Seed Transaksi (30 Active Loans: 19 Overdue, 11 Normal Active, 10 Returned) ---
    List<Transaksi> sampleTransactions = [];
    
    // 19 Overdue loans (Borrowed > 7 days ago)
    for (int i = 0; i < 19; i++) {
      final pinjamDate = now.subtract(Duration(days: 10 + i));
      final harusKembaliDate = pinjamDate.add(const Duration(days: 7));
      final b = sampleBuku[i];
      final v = visitorNames[i % visitorNames.length];

      sampleTransactions.add(Transaksi(
        noTransaksi: 'TRX-2026-${(i + 1).toString().padLeft(3, '0')}',
        noBuku: b.noBuku,
        nama: v['nama']!,
        kelas: v['kelas']!,
        waktuPinjam: "${pinjamDate.day.toString().padLeft(2, '0')}/${pinjamDate.month.toString().padLeft(2, '0')}/${pinjamDate.year}",
        waktuKembali: "${harusKembaliDate.day.toString().padLeft(2, '0')}/${harusKembaliDate.month.toString().padLeft(2, '0')}/${harusKembaliDate.year}",
        status: 'Terlambat',
      ));
    }

    // 11 Normal Active Loans (Borrowed 2 days ago)
    for (int i = 19; i < 30; i++) {
      final pinjamDate = now.subtract(Duration(days: 2));
      final harusKembaliDate = pinjamDate.add(const Duration(days: 7));
      final b = sampleBuku[i];
      final v = visitorNames[i % visitorNames.length];

      sampleTransactions.add(Transaksi(
        noTransaksi: 'TRX-2026-${(i + 1).toString().padLeft(3, '0')}',
        noBuku: b.noBuku,
        nama: v['nama']!,
        kelas: v['kelas']!,
        waktuPinjam: "${pinjamDate.day.toString().padLeft(2, '0')}/${pinjamDate.month.toString().padLeft(2, '0')}/${pinjamDate.year}",
        waktuKembali: "${harusKembaliDate.day.toString().padLeft(2, '0')}/${harusKembaliDate.month.toString().padLeft(2, '0')}/${harusKembaliDate.year}",
        status: 'Dipinjam',
      ));
    }

    // 10 Returned Loans
    for (int i = 30; i < 40; i++) {
      final pinjamDate = now.subtract(Duration(days: 20 + i));
      final kembaliDate = pinjamDate.add(const Duration(days: 5));
      final b = sampleBuku[i];
      final v = visitorNames[i % visitorNames.length];

      sampleTransactions.add(Transaksi(
        noTransaksi: 'TRX-2026-${(i + 1).toString().padLeft(3, '0')}',
        noBuku: b.noBuku,
        nama: v['nama']!,
        kelas: v['kelas']!,
        waktuPinjam: "${pinjamDate.day.toString().padLeft(2, '0')}/${pinjamDate.month.toString().padLeft(2, '0')}/${pinjamDate.year}",
        waktuKembali: "${kembaliDate.day.toString().padLeft(2, '0')}/${kembaliDate.month.toString().padLeft(2, '0')}/${kembaliDate.year}",
        status: 'Dikembalikan',
        waktuDikembalikan: "${kembaliDate.day.toString().padLeft(2, '0')}/${kembaliDate.month.toString().padLeft(2, '0')}/${kembaliDate.year}",
      ));
    }

    for (var t in sampleTransactions) {
      await db.insert('transaksi', t.toMap());
    }
  }

  // --- CRUD Operations ---

  // JUDUL
  Future<List<Judul>> getAllJudul() async {
    final db = await instance.database;
    final maps = await db.query('judul', orderBy: 'no_judul ASC');
    return maps.map((m) => Judul.fromMap(m)).toList();
  }

  Future<int> insertJudul(Judul judul) async {
    final db = await instance.database;
    return await db.insert('judul', judul.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateJudul(Judul judul) async {
    final db = await instance.database;
    return await db.update(
      'judul',
      judul.toMap(),
      where: 'no_judul = ?',
      whereArgs: [judul.noJudul],
    );
  }

  Future<int> deleteJudul(String noJudul) async {
    final db = await instance.database;
    return await db.delete('judul', where: 'no_judul = ?', whereArgs: [noJudul]);
  }

  // BUKU (Eksemplar)
  Future<List<Buku>> getAllBuku() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT b.*, j.judul as judul, j.penerbit as penerbit
      FROM buku b
      LEFT JOIN judul j ON b.no_judul = j.no_judul
      ORDER BY b.no_buku ASC
    ''');
    return result.map((m) => Buku.fromMap(m)).toList();
  }

  Future<int> insertBuku(Buku buku) async {
    final db = await instance.database;
    return await db.insert('buku', buku.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateBukuStatus(String noBuku, String status) async {
    final db = await instance.database;
    return await db.update(
      'buku',
      {'status': status},
      where: 'no_buku = ?',
      whereArgs: [noBuku],
    );
  }

  Future<int> deleteBuku(String noBuku) async {
    final db = await instance.database;
    return await db.delete('buku', where: 'no_buku = ?', whereArgs: [noBuku]);
  }

  // KUNJUNGAN
  Future<List<Kunjungan>> getAllKunjungan() async {
    final db = await instance.database;
    final maps = await db.query('kunjungan', orderBy: 'rowid DESC');
    return maps.map((m) => Kunjungan.fromMap(m)).toList();
  }

  Future<int> insertKunjungan(Kunjungan kunjungan) async {
    final db = await instance.database;
    return await db.insert('kunjungan', kunjungan.toMap());
  }

  // TRANSAKSI
  Future<List<Transaksi>> getAllTransaksi() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT t.*, j.judul as judul_buku, b.no_judul as no_judul
      FROM transaksi t
      LEFT JOIN buku b ON t.no_buku = b.no_buku
      LEFT JOIN judul j ON b.no_judul = j.no_judul
      ORDER BY t.no_transaksi DESC
    ''');
    return result.map((m) => Transaksi.fromMap(m)).toList();
  }

  Future<int> insertTransaksi(Transaksi transaksi) async {
    final db = await instance.database;
    await db.insert('transaksi', transaksi.toMap());
    // Update copy status to 'Dipinjam'
    return await updateBukuStatus(transaksi.noBuku, 'Dipinjam');
  }

  Future<int> kembalikanBuku(String noTransaksi, String noBuku, String tanggalKembali) async {
    final db = await instance.database;
    await db.update(
      'transaksi',
      {
        'status': 'Dikembalikan',
        'waktu_dikembalikan': tanggalKembali,
      },
      where: 'no_transaksi = ?',
      whereArgs: [noTransaksi],
    );
    // Update copy status to 'Tersedia'
    return await updateBukuStatus(noBuku, 'Tersedia');
  }
}
