import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/buku.dart';
import '../models/judul.dart';
import '../models/transaksi.dart';
import '../providers/library_provider.dart';
import '../widgets/glass_card.dart';

class DaftarBukuView extends StatefulWidget {
  const DaftarBukuView({super.key});

  @override
  State<DaftarBukuView> createState() => _DaftarBukuViewState();
}

class _DaftarBukuViewState extends State<DaftarBukuView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Dialog Detail Buku
  void _showDetailBukuDialog(Judul judul) {
    final provider = Provider.of<LibraryProvider>(context, listen: false);
    final copies = provider.listBuku.where((b) => b.noJudul == judul.noJudul).toList();
    final loans = provider.listTransaksi;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppTheme.accentBlue, width: 1.5),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0x2838BDF8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.bookOpen, color: AppTheme.accentBlue, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul.judul,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    'Kode Judul: ${judul.noJudul} • ISBN: ${judul.isbn}',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 580,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: AppTheme.borderLight, height: 20),

                // Book Metadata Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailTile('Penerbit', judul.penerbit, LucideIcons.building),
                    ),
                    Expanded(
                      child: _buildDetailTile('Tahun Terbit', judul.tahunTerbit.toString(), LucideIcons.calendar),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailTile('Asal Buku', judul.asal, LucideIcons.archive),
                    ),
                    Expanded(
                      child: _buildDetailTile('Total Eksemplar', '${copies.length} Buku', LucideIcons.copy),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Deskripsi
                Text('Deskripsi Buku:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x1F1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Text(
                    judul.deskripsi.isEmpty ? 'Tidak ada deskripsi.' : judul.deskripsi,
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textPrimary, height: 1.4),
                  ),
                ),
                const SizedBox(height: 20),

                // Copies Table
                Text('Daftar Eksemplar & Status Pinjaman:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.accentGreen)),
                const SizedBox(height: 8),

                copies.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('Belum ada eksemplar fisik untuk judul ini.', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 12)),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: const Color(0x1F1E293B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Column(
                          children: copies.map((copy) {
                            final activeLoan = loans.firstWhere(
                              (t) => t.noBuku == copy.noBuku && (t.status == 'Dipinjam' || t.status == 'Terlambat'),
                              orElse: () => Transaksi(noTransaksi: '', noBuku: '', nama: '', kelas: '', waktuPinjam: '', waktuKembali: '', status: ''),
                            );

                            Color stColor = AppTheme.accentGreen;
                            if (copy.status == 'Dipinjam') stColor = AppTheme.accentBlue;
                            if (copy.status == 'Rusak') stColor = AppTheme.accentOrange;
                            if (copy.status == 'Hilang') stColor = AppTheme.accentRed;

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: AppTheme.borderLight, width: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  Text(copy.noBuku, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentGreen)),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: stColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(copy.status, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: stColor)),
                                  ),
                                  const Spacer(),
                                  if (activeLoan.noTransaksi.isNotEmpty)
                                    Text(
                                      'Dipinjam: ${activeLoan.nama} (${activeLoan.kelas})',
                                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.accentBlue),
                                    )
                                  else
                                    Text(
                                      copy.keterangan,
                                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.accentBlue),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
            Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ],
    );
  }

  // Dialog to Add/Edit Judul Buku
  void _showJudulDialog({Judul? judulEdit}) {
    final isEdit = judulEdit != null;
    final noJudulCtrl = TextEditingController(text: isEdit ? judulEdit.noJudul : 'JDL-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}');
    final judulCtrl = TextEditingController(text: isEdit ? judulEdit.judul : '');
    final penerbitCtrl = TextEditingController(text: isEdit ? judulEdit.penerbit : '');
    final tahunCtrl = TextEditingController(text: isEdit ? judulEdit.tahunTerbit.toString() : '2024');
    final isbnCtrl = TextEditingController(text: isEdit ? judulEdit.isbn : '');
    final asalCtrl = TextEditingController(text: isEdit ? judulEdit.asal : 'Pembelian BOS');
    final deskripsiCtrl = TextEditingController(text: isEdit ? judulEdit.deskripsi : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.accentBlue, width: 1.2),
        ),
        title: Text(
          isEdit ? 'Edit Judul Buku' : 'Tambah Judul Buku',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: noJudulCtrl,
                  readOnly: isEdit,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Kode Judul (no_judul)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: judulCtrl,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Judul Buku'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: penerbitCtrl,
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Penerbit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: tahunCtrl,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Tahun Terbit'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: isbnCtrl,
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                        decoration: const InputDecoration(labelText: 'ISBN'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: asalCtrl,
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Asal Buku'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: deskripsiCtrl,
                  maxLines: 2,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Deskripsi singkat'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.inter(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (judulCtrl.text.trim().isEmpty) return;
              final provider = Provider.of<LibraryProvider>(context, listen: false);
              final newJdl = Judul(
                noJudul: noJudulCtrl.text.trim(),
                judul: judulCtrl.text.trim(),
                penerbit: penerbitCtrl.text.trim(),
                tahunTerbit: int.tryParse(tahunCtrl.text.trim()) ?? 2024,
                isbn: isbnCtrl.text.trim(),
                asal: asalCtrl.text.trim(),
                deskripsi: deskripsiCtrl.text.trim(),
              );

              if (isEdit) {
                await provider.updateJudul(newJdl);
              } else {
                await provider.addJudul(newJdl);
              }

              if (context.mounted) Navigator.pop(context);
            },
            child: Text(isEdit ? 'Simpan' : 'Tambah'),
          ),
        ],
      ),
    );
  }

  // Dialog to Add Eksemplar (Copy)
  void _showBukuCopyDialog() {
    final provider = Provider.of<LibraryProvider>(context, listen: false);
    if (provider.listJudul.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan tambah Judul Buku terlebih dahulu.')),
      );
      return;
    }

    String selectedNoJudul = provider.listJudul.first.noJudul;
    final noBukuCtrl = TextEditingController(text: 'BK-${selectedNoJudul.replaceAll('JDL-', '')}-01');
    final keteranganCtrl = TextEditingController(text: 'Kondisi Baik');
    String selectedStatus = 'Tersedia';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.accentGreen, width: 1.2),
          ),
          title: Text(
            'Tambah Eksemplar / Copy Buku',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pilih Judul Buku', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0x281E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedNoJudul,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF0F172A),
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                      items: provider.listJudul.map((j) => DropdownMenuItem(
                        value: j.noJudul,
                        child: Text('${j.noJudul} - ${j.judul}'),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedNoJudul = val;
                            noBukuCtrl.text = 'BK-${val.replaceAll('JDL-', '')}-${(provider.listBuku.length + 1).toString().padLeft(2, '0')}';
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noBukuCtrl,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Nomor Buku (no_buku / barcode)'),
                ),
                const SizedBox(height: 12),
                Text('Status Ketersediaan', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0x281E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedStatus,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF0F172A),
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                      items: ['Tersedia', 'Dipinjam', 'Rusak', 'Hilang']
                          .map((st) => DropdownMenuItem(
                                value: st,
                                child: Text(st),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedStatus = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: keteranganCtrl,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Keterangan'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.inter(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (noBukuCtrl.text.trim().isEmpty) return;
                final newBuku = Buku(
                  noBuku: noBukuCtrl.text.trim(),
                  noJudul: selectedNoJudul,
                  status: selectedStatus,
                  keterangan: keteranganCtrl.text.trim(),
                );
                await provider.addBuku(newBuku);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Tambah Copy'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibraryProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 900;

    final filteredJudul = provider.filteredAndSortedJudul;
    final filteredBuku = provider.filteredAndSortedBuku;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 28, vertical: 10),
      child: Column(
        children: [
          // Header Bar & Filters
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                // Tab Buttons
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0x1F1E293B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicator: BoxDecoration(
                      color: AppTheme.accentBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.accentBlue),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppTheme.textSecondary,
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: const [
                      Tab(text: '  📚 Judul Buku (Master)  '),
                      Tab(text: '  📖 Eksemplar / Copy Buku  '),
                    ],
                  ),
                ),

                // Search Box
                SizedBox(
                  width: 180,
                  height: 38,
                  child: TextField(
                    onChanged: (val) => provider.setSearchBuku(val),
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Cari judul/kode...',
                      prefixIcon: Icon(LucideIcons.search, size: 14, color: AppTheme.textMuted),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    ),
                  ),
                ),

                // Status Filter Dropdown
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0x281E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: provider.selectedStatusBukuFilter,
                      dropdownColor: const Color(0xFF0F172A),
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                      items: ['Semua Status', 'Tersedia', 'Dipinjam', 'Rusak', 'Hilang']
                          .map((st) => DropdownMenuItem(
                                value: st,
                                child: Text(st),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) provider.setStatusBukuFilter(val);
                      },
                    ),
                  ),
                ),

                // Sort Order Dropdown
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0x281E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: provider.selectedBukuSortOrder,
                      dropdownColor: const Color(0xFF0F172A),
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                      items: ['Terbaru', 'Terlama', 'A-Z', 'Z-A']
                          .map((so) => DropdownMenuItem(
                                value: so,
                                child: Text('Urutkan: $so'),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) provider.setBukuSortOrder(val);
                      },
                    ),
                  ),
                ),

                // Action Buttons
                ElevatedButton.icon(
                  onPressed: () => _showJudulDialog(),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Judul'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showBukuCopyDialog(),
                  icon: const Icon(LucideIcons.copy, size: 16),
                  label: const Text('Eksemplar'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGreen),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tab View Content
          SizedBox(
            height: 600,
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: JUDUL BUKU TABLE
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0x1F1E293B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text('NO JUDUL', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                            Expanded(flex: 4, child: Text('JUDUL BUKU', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                            Expanded(flex: 3, child: Text('PENERBIT', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                            Expanded(flex: 2, child: Text('TAHUN', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                            Expanded(flex: 3, child: Text('ASAL', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                            Expanded(flex: 3, child: Text('AKSI', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: filteredJudul.length,
                          separatorBuilder: (context, index) => const Divider(color: AppTheme.borderLight, height: 1),
                          itemBuilder: (context, index) {
                            final item = filteredJudul[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(flex: 2, child: Text(item.noJudul, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.accentGreen, fontWeight: FontWeight.bold))),
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.judul, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                                        Text('ISBN: ${item.isbn}', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                                      ],
                                    ),
                                  ),
                                  Expanded(flex: 3, child: Text(item.penerbit, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary))),
                                  Expanded(flex: 2, child: Text(item.tahunTerbit.toString(), style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary))),
                                  Expanded(flex: 3, child: Text(item.asal, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.accentOrange))),
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(LucideIcons.eye, size: 16, color: AppTheme.accentGreen),
                                          tooltip: 'Lihat Detail Buku',
                                          onPressed: () => _showDetailBukuDialog(item),
                                        ),
                                        IconButton(
                                          icon: const Icon(LucideIcons.edit2, size: 16, color: AppTheme.accentBlue),
                                          tooltip: 'Edit Judul',
                                          onPressed: () => _showJudulDialog(judulEdit: item),
                                        ),
                                        IconButton(
                                          icon: const Icon(LucideIcons.trash2, size: 16, color: AppTheme.accentRed),
                                          tooltip: 'Hapus Judul',
                                          onPressed: () => provider.deleteJudul(item.noJudul),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // TAB 2: EKSEMPLAR BUKU TABLE
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0x1F1E293B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 3, child: Text('NO BUKU (EKSEMPLAR)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                            Expanded(flex: 3, child: Text('KODE JUDUL', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                            Expanded(flex: 4, child: Text('JUDUL BUKU', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                            Expanded(flex: 3, child: Text('STATUS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                            Expanded(flex: 3, child: Text('KETERANGAN', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                            Expanded(flex: 1, child: Text('AKSI', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: filteredBuku.length,
                          separatorBuilder: (context, index) => const Divider(color: AppTheme.borderLight, height: 1),
                          itemBuilder: (context, index) {
                            final item = filteredBuku[index];

                            Color statusColor = AppTheme.accentGreen;
                            if (item.status == 'Dipinjam') statusColor = AppTheme.accentBlue;
                            if (item.status == 'Rusak') statusColor = AppTheme.accentOrange;
                            if (item.status == 'Hilang') statusColor = AppTheme.accentRed;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(flex: 3, child: Text(item.noBuku, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.accentGreen, fontWeight: FontWeight.bold))),
                                  Expanded(flex: 3, child: Text(item.noJudul, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary))),
                                  Expanded(flex: 4, child: Text(item.judulTitle ?? '-', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary))),
                                  Expanded(
                                    flex: 3,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: statusColor.withOpacity(0.4)),
                                        ),
                                        child: Text(
                                          item.status,
                                          style: GoogleFonts.inter(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(flex: 3, child: Text(item.keterangan, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted))),
                                  Expanded(
                                    flex: 1,
                                    child: IconButton(
                                      icon: const Icon(LucideIcons.trash2, size: 16, color: AppTheme.accentRed),
                                      onPressed: () => provider.deleteBuku(item.noBuku),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
