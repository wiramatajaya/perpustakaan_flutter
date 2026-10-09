import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/buku.dart';
import '../providers/library_provider.dart';
import '../widgets/glass_card.dart';

class FormTransaksiView extends StatefulWidget {
  const FormTransaksiView({super.key});

  @override
  State<FormTransaksiView> createState() => _FormTransaksiViewState();
}

class _FormTransaksiViewState extends State<FormTransaksiView> {
  final _pinjamFormKey = GlobalKey<FormState>();
  final _namaPeminjamCtrl = TextEditingController();
  final _kelasPeminjamCtrl = TextEditingController();
  final _searchPeminjamanCtrl = TextEditingController();
  final _searchPengembalianCtrl = TextEditingController();
  
  Buku? _selectedBukuObject;
  DateTime _tanggalPinjam = DateTime.now();
  DateTime _tanggalKembali = DateTime.now().add(const Duration(days: 7));

  String _searchPengembalianQuery = '';

  @override
  void dispose() {
    _namaPeminjamCtrl.dispose();
    _kelasPeminjamCtrl.dispose();
    _searchPeminjamanCtrl.dispose();
    _searchPengembalianCtrl.dispose();
    super.dispose();
  }

  void _submitPeminjaman() async {
    if (_pinjamFormKey.currentState!.validate() && _selectedBukuObject != null) {
      final provider = Provider.of<LibraryProvider>(context, listen: false);
      final success = await provider.addTransaksi(
        noBuku: _selectedBukuObject!.noBuku,
        nama: _namaPeminjamCtrl.text.trim(),
        kelas: _kelasPeminjamCtrl.text.trim(),
        tanggalPinjam: _tanggalPinjam,
        tanggalKembali: _tanggalKembali,
      );

      if (success && mounted) {
        _namaPeminjamCtrl.clear();
        _kelasPeminjamCtrl.clear();
        _searchPeminjamanCtrl.clear();
        setState(() {
          _selectedBukuObject = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peminjaman berhasil diproses! Status buku diperbarui menjadi Dipinjam.'),
            backgroundColor: AppTheme.accentGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (_selectedBukuObject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih buku yang akan dipinjam!'),
          backgroundColor: AppTheme.accentOrange,
        ),
      );
    }
  }

  void _prosesPengembalian(String noTransaksi, String noBuku) async {
    final provider = Provider.of<LibraryProvider>(context, listen: false);
    final success = await provider.processReturn(noTransaksi, noBuku);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengembalian buku berhasil! Status buku kembali Tersedia.'),
          backgroundColor: AppTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Searchable Dialog to Pick Book to Borrow
  void _showBookSearchDialog(List<Buku> availableBooks) {
    String localQuery = '';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filtered = availableBooks.where((b) {
            final title = b.judulTitle ?? '';
            return b.noBuku.toLowerCase().contains(localQuery.toLowerCase()) ||
                b.noJudul.toLowerCase().contains(localQuery.toLowerCase()) ||
                title.toLowerCase().contains(localQuery.toLowerCase());
          }).toList();

          return AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppTheme.accentBlue, width: 1.2),
            ),
            title: Text(
              'Cari & Pilih Buku Dipinjam',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            content: SizedBox(
              width: 500,
              height: 400,
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    onChanged: (val) {
                      setDialogState(() => localQuery = val);
                    },
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Ketik Kode Buku (ID) atau Judul Buku...',
                      prefixIcon: Icon(LucideIcons.search, size: 16, color: AppTheme.accentBlue),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              'Buku tidak ditemukan atau sedang tidak tersedia.',
                              style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const Divider(color: AppTheme.borderLight, height: 1),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return ListTile(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                hoverColor: const Color(0x1F38BDF8),
                                leading: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0x2810B981),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.noBuku,
                                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentGreen),
                                  ),
                                ),
                                title: Text(
                                  item.judulTitle ?? item.noJudul,
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Penerbit: ${item.penerbit ?? '-'} • ID Judul: ${item.noJudul}',
                                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                                ),
                                trailing: const Icon(LucideIcons.checkCircle2, size: 18, color: AppTheme.accentBlue),
                                onTap: () {
                                  setState(() {
                                    _selectedBukuObject = item;
                                    _searchPeminjamanCtrl.text = '${item.noBuku} - ${item.judulTitle ?? item.noJudul}';
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal', style: GoogleFonts.inter(color: AppTheme.textMuted)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibraryProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 900;

    final availableBooks = provider.listBuku.where((b) => b.status == 'Tersedia').toList();

    // Filter active loans for return search
    final activeLoans = provider.listTransaksi.where((t) {
      final isLoan = t.status == 'Dipinjam' || t.status == 'Terlambat';
      if (!isLoan) return false;

      final title = t.judulBuku ?? '';
      final q = _searchPengembalianQuery.toLowerCase();
      return t.noBuku.toLowerCase().contains(q) ||
          t.noTransaksi.toLowerCase().contains(q) ||
          t.nama.toLowerCase().contains(q) ||
          t.kelas.toLowerCase().contains(q) ||
          title.toLowerCase().contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 28, vertical: 10),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Card: Form Peminjaman Buku
          Flexible(
            flex: isMobile ? 0 : 1,
            child: GlassCard(
              padding: const EdgeInsets.all(22),
              child: Form(
                key: _pinjamFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.arrowUpRight, color: AppTheme.accentBlue, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'Form Transaksi Peminjaman',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Searchable Book Picker (Buku ID & Judul)
                    Text(
                      'Pilih / Cari Buku Dipinjam (ID atau Judul) *',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _showBookSearchDialog(availableBooks),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0x281E293B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedBukuObject != null ? AppTheme.accentBlue : AppTheme.borderLight,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.search, size: 16, color: AppTheme.accentBlue),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedBukuObject != null
                                    ? '${_selectedBukuObject!.noBuku} - ${_selectedBukuObject!.judulTitle ?? _selectedBukuObject!.noJudul}'
                                    : 'Klik untuk mencari ID / Judul buku tersedia...',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: _selectedBukuObject != null ? Colors.white : AppTheme.textMuted,
                                  fontWeight: _selectedBukuObject != null ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            const Icon(LucideIcons.chevronDown, size: 16, color: AppTheme.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Input Nama Peminjam
                    Text(
                      'Nama Peminjam *',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _namaPeminjamCtrl,
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                      decoration: const InputDecoration(hintText: 'Nama lengkap siswa / guru...'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Nama peminjam wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),

                    // Input Kelas
                    Text(
                      'Kelas / Jabatan *',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _kelasPeminjamCtrl,
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                      decoration: const InputDecoration(hintText: 'Contoh: VI A / Guru SD'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Kelas wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),

                    // Dates Selection
                    Row(
                      children: [
                        // Tanggal Pinjam
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tanggal Pinjam', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _tanggalPinjam,
                                    firstDate: DateTime(2025),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _tanggalPinjam = picked;
                                      _tanggalKembali = picked.add(const Duration(days: 7));
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0x281E293B),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.borderLight),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(DateFormat('dd/MM/yyyy').format(_tanggalPinjam), style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
                                      const Icon(LucideIcons.calendar, size: 16, color: AppTheme.accentBlue),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Tanggal Harus Kembali
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Batas Kembali', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _tanggalKembali,
                                    firstDate: DateTime(2025),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setState(() => _tanggalKembali = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0x281E293B),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.borderLight),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(DateFormat('dd/MM/yyyy').format(_tanggalKembali), style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
                                      const Icon(LucideIcons.calendar, size: 16, color: AppTheme.accentOrange),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _submitPeminjaman,
                        icon: const Icon(LucideIcons.checkCircle, size: 18),
                        label: Text(
                          'Proses Peminjaman Buku',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMobile) const SizedBox(height: 20) else const SizedBox(width: 20),

          // Right Card: Form / Search & Pengembalian Buku
          Flexible(
            flex: isMobile ? 0 : 1,
            child: GlassCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.arrowDownLeft, color: AppTheme.accentGreen, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Pengembalian Buku',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Daftar pinjaman aktif yang perlu dikembalikan',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // Search Bar for Pengembalian (ID Buku / Transaksi / Peminjam)
                  TextField(
                    controller: _searchPengembalianCtrl,
                    onChanged: (val) {
                      setState(() => _searchPengembalianQuery = val);
                    },
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Cari ID Buku, No. Transaksi, atau Peminjam...',
                      prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppTheme.accentGreen),
                      suffixIcon: _searchPengembalianQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(LucideIcons.x, size: 14, color: AppTheme.textMuted),
                              onPressed: () {
                                _searchPengembalianCtrl.clear();
                                setState(() => _searchPengembalianQuery = '');
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  activeLoans.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(30),
                          child: Center(
                            child: Text(
                              _searchPengembalianQuery.isNotEmpty
                                  ? 'Tidak ada data pengembalian cocok dengan pencarian.'
                                  : 'Tidak ada pinjaman aktif saat ini.',
                              style: GoogleFonts.inter(color: AppTheme.textMuted),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activeLoans.length,
                          separatorBuilder: (context, index) => const Divider(color: AppTheme.borderLight, height: 1),
                          itemBuilder: (context, index) {
                            final item = activeLoans[index];
                            final isOverdue = item.status == 'Terlambat';

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              item.noBuku,
                                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentGreen),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '(${item.noTransaksi})',
                                              style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isOverdue ? AppTheme.accentOrange.withOpacity(0.2) : AppTheme.accentBlue.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                item.status,
                                                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: isOverdue ? AppTheme.accentOrange : AppTheme.accentBlue),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.judulBuku ?? 'Buku Perpustakaan',
                                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Peminjam: ${item.nama} (${item.kelas})',
                                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                                        ),
                                        Text(
                                          'Batas: ${item.waktuKembali}',
                                          style: GoogleFonts.inter(fontSize: 11, color: isOverdue ? AppTheme.accentRed : AppTheme.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _prosesPengembalian(item.noTransaksi, item.noBuku),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.accentGreen,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    child: const Text('Kembalikan', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
