import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/library_provider.dart';
import '../widgets/glass_card.dart';

class PengunjungView extends StatefulWidget {
  const PengunjungView({super.key});

  @override
  State<PengunjungView> createState() => _PengunjungViewState();
}

class _PengunjungViewState extends State<PengunjungView> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kelasController = TextEditingController();
  final _keperluanController = TextEditingController();
  String _selectedKategoriForm = 'Siswa';

  @override
  void dispose() {
    _namaController.dispose();
    _kelasController.dispose();
    _keperluanController.dispose();
    super.dispose();
  }

  void _submitPresensi() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<LibraryProvider>(context, listen: false);
      final success = await provider.addKunjungan(
        nama: _namaController.text.trim(),
        kategori: _selectedKategoriForm,
        kelas: _kelasController.text.trim().isEmpty ? '-' : _kelasController.text.trim(),
        keperluan: _keperluanController.text.trim().isEmpty ? 'Membaca Buku' : _keperluanController.text.trim(),
      );

      if (success && mounted) {
        _namaController.clear();
        _kelasController.clear();
        _keperluanController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Presensi kunjungan berhasil dicatat!'),
            backgroundColor: AppTheme.accentGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibraryProvider>(context);
    final filteredList = provider.filteredKunjungan;
    final isMobile = MediaQuery.of(context).size.width < 900;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 28, vertical: 10),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Table of Visitor Logs
          Flexible(
            flex: isMobile ? 0 : 3,
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Toolbar: Title & Filters
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '📜 Riwayat Kunjungan',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Search Input
                          SizedBox(
                            width: 140,
                            height: 38,
                            child: TextField(
                              onChanged: (val) => provider.setSearchKunjungan(val),
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Cari...',
                                prefixIcon: Icon(LucideIcons.search, size: 14, color: AppTheme.textMuted),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Category Filter Dropdown
                          Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0x281E293B),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.borderLight),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: provider.selectedKategoriKunjungan,
                                dropdownColor: const Color(0xFF0F172A),
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                                items: ['Semua Kategori', 'Siswa', 'Guru', 'Staf']
                                    .map((cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(cat),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) provider.setKategoriKunjungan(val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0x1F1E293B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text('WAKTU', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue)),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text('PENGUNJUNG', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('KATEGORI', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Table Data Rows
                  filteredList.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(30),
                          child: Center(
                            child: Text(
                              'Tidak ada data kunjungan ditemukan.',
                              style: GoogleFonts.inter(color: AppTheme.textMuted),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredList.take(12).length,
                          separatorBuilder: (context, index) => const Divider(color: AppTheme.borderLight, height: 1),
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      item.waktuKunjungan,
                                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.accentGreen, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.nama,
                                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                        ),
                                        Text(
                                          '${item.kategori}: ${item.kelas}',
                                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.accentBlue),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0x280EA5E9),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0x4D0EA5E9)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          item.kategori,
                                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.accentBlue, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
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
          if (isMobile) const SizedBox(height: 20) else const SizedBox(width: 20),

          // Right Side: Form Presensi (Matching Image 1 mockup)
          Flexible(
            flex: isMobile ? 0 : 2,
            child: GlassCard(
              padding: const EdgeInsets.all(22),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.fileCheck, color: AppTheme.accentOrange, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'Form Presensi',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Input Nama
                    Text(
                      'Nama Pengunjung *',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _namaController,
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                      decoration: const InputDecoration(hintText: 'Nama lengkap...'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),

                    // Input Kategori & Kelas
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kategori', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                              const SizedBox(height: 6),
                              Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0x281E293B),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.borderLight),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedKategoriForm,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF0F172A),
                                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                                    items: ['Siswa', 'Guru', 'Staf']
                                        .map((cat) => DropdownMenuItem(
                                              value: cat,
                                              child: Text(cat),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedKategoriForm = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kelas', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _kelasController,
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                                decoration: const InputDecoration(hintText: 'VIA / 6a'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Input Keperluan
                    Text('Keperluan', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _keperluanController,
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                      decoration: const InputDecoration(hintText: 'Membaca, Pinjam Buku, dll.'),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _submitPresensi,
                        icon: const Icon(LucideIcons.send, size: 16),
                        label: Text(
                          'Submit Kunjungan',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
