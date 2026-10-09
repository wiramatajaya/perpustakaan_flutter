class Transaksi {
  final String noTransaksi;
  final String noBuku;
  final String nama;
  final String kelas;
  final String waktuPinjam;
  final String waktuKembali; // Due date or return date
  final String status;       // 'Dipinjam', 'Dikembalikan', 'Terlambat'
  final String? waktuDikembalikan; // Actual returned date if returned

  // Joined display attributes
  final String? judulBuku;
  final String? noJudul;

  Transaksi({
    required this.noTransaksi,
    required this.noBuku,
    required this.nama,
    required this.kelas,
    required this.waktuPinjam,
    required this.waktuKembali,
    required this.status,
    this.waktuDikembalikan,
    this.judulBuku,
    this.noJudul,
  });

  Map<String, dynamic> toMap() {
    return {
      'no_transaksi': noTransaksi,
      'no_buku': noBuku,
      'nama': nama,
      'kelas': kelas,
      'waktu_pinjam': waktuPinjam,
      'waktu_kembali': waktuKembali,
      'status': status,
      'waktu_dikembalikan': waktuDikembalikan,
    };
  }

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      noTransaksi: map['no_transaksi'] ?? '',
      noBuku: map['no_buku'] ?? '',
      nama: map['nama'] ?? '',
      kelas: map['kelas'] ?? '',
      waktuPinjam: map['waktu_pinjam'] ?? '',
      waktuKembali: map['waktu_kembali'] ?? '',
      status: map['status'] ?? 'Dipinjam',
      waktuDikembalikan: map['waktu_dikembalikan'],
      judulBuku: map['judul_buku'] ?? map['judul'],
      noJudul: map['no_judul'],
    );
  }
}
