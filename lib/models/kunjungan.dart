class Kunjungan {
  final String noKunjungan;
  final String nama;
  final String kategori; // 'Siswa', 'Guru', 'Staf'
  final String kelas;    // e.g., 'VI A', '4B', '-'
  final String keperluan; // e.g., 'Membaca Buku Novel', 'Pinjam Buku'
  final String waktuKunjungan; // ISO or formatted date string
  final String? noBuku;

  Kunjungan({
    required this.noKunjungan,
    required this.nama,
    required this.kategori,
    required this.kelas,
    required this.keperluan,
    required this.waktuKunjungan,
    this.noBuku,
  });

  Map<String, dynamic> toMap() {
    return {
      'no_kunjungan': noKunjungan,
      'nama': nama,
      'kategori': kategori,
      'kelas': kelas,
      'keperluan': keperluan,
      'waktu_kunjungan': waktuKunjungan,
      'no_buku': noBuku,
    };
  }

  factory Kunjungan.fromMap(Map<String, dynamic> map) {
    return Kunjungan(
      noKunjungan: map['no_kunjungan'] ?? '',
      nama: map['nama'] ?? '',
      kategori: map['kategori'] ?? 'Siswa',
      kelas: map['kelas'] ?? '-',
      keperluan: map['keperluan'] ?? 'Membaca Buku',
      waktuKunjungan: map['waktu_kunjungan'] ?? '',
      noBuku: map['no_buku'],
    );
  }
}
