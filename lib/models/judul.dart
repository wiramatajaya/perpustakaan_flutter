class Judul {
  final String noJudul;
  final String judul;
  final String penerbit;
  final int tahunTerbit;
  final String isbn;
  final String asal;
  final String deskripsi;

  Judul({
    required this.noJudul,
    required this.judul,
    required this.penerbit,
    required this.tahunTerbit,
    required this.isbn,
    required this.asal,
    required this.deskripsi,
  });

  Map<String, dynamic> toMap() {
    return {
      'no_judul': noJudul,
      'judul': judul,
      'penerbit': penerbit,
      'tahun_terbit': tahunTerbit,
      'isbn': isbn,
      'asal': asal,
      'deskripsi': deskripsi,
    };
  }

  factory Judul.fromMap(Map<String, dynamic> map) {
    return Judul(
      noJudul: map['no_judul'] ?? '',
      judul: map['judul'] ?? '',
      penerbit: map['penerbit'] ?? '',
      tahunTerbit: map['tahun_terbit'] is int 
          ? map['tahun_terbit'] 
          : (int.tryParse(map['tahun_terbit']?.toString() ?? '2024') ?? 2024),
      isbn: map['isbn'] ?? '',
      asal: map['asal'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
    );
  }
}
