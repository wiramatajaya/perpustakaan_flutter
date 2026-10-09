class Buku {
  final String noBuku;
  final String noJudul;
  final String status; // 'Tersedia', 'Dipinjam', 'Rusak', 'Hilang'
  final String keterangan;
  
  // Joined detail for UI display
  final String? judulTitle;
  final String? penerbit;

  Buku({
    required this.noBuku,
    required this.noJudul,
    required this.status,
    required this.keterangan,
    this.judulTitle,
    this.penerbit,
  });

  Map<String, dynamic> toMap() {
    return {
      'no_buku': noBuku,
      'no_judul': noJudul,
      'status': status,
      'keterangan': keterangan,
    };
  }

  factory Buku.fromMap(Map<String, dynamic> map) {
    return Buku(
      noBuku: map['no_buku'] ?? '',
      noJudul: map['no_judul'] ?? '',
      status: map['status'] ?? 'Tersedia',
      keterangan: map['keterangan'] ?? '',
      judulTitle: map['judul'],
      penerbit: map['penerbit'],
    );
  }

  Buku copyWith({
    String? noBuku,
    String? noJudul,
    String? status,
    String? keterangan,
    String? judulTitle,
    String? penerbit,
  }) {
    return Buku(
      noBuku: noBuku ?? this.noBuku,
      noJudul: noJudul ?? this.noJudul,
      status: status ?? this.status,
      keterangan: keterangan ?? this.keterangan,
      judulTitle: judulTitle ?? this.judulTitle,
      penerbit: penerbit ?? this.penerbit,
    );
  }
}
