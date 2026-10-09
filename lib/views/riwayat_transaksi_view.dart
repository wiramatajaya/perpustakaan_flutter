import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/library_provider.dart';
import '../widgets/glass_card.dart';

class RiwayatTransaksiView extends StatelessWidget {
  const RiwayatTransaksiView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibraryProvider>(context);
    final filteredList = provider.filteredTransaksi;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 28, vertical: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toolbar Title & Search / Filters
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                  '📋 Riwayat Transaksi Peminjaman',
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
                      width: 160,
                      height: 38,
                      child: TextField(
                        onChanged: (val) => provider.setSearchTransaksi(val),
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Cari nama / kode...',
                          prefixIcon: Icon(LucideIcons.search, size: 14, color: AppTheme.textMuted),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Status Filter Dropdown
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
                          value: provider.selectedStatusTransaksi,
                          dropdownColor: const Color(0xFF0F172A),
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                          items: ['Semua Status', 'Dipinjam', 'Dikembalikan', 'Terlambat']
                              .map((st) => DropdownMenuItem(
                                    value: st,
                                    child: Text(st),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) provider.setStatusTransaksi(val);
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0x1F1E293B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text('NO TRANSAKSI', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                  Expanded(flex: 3, child: Text('NO BUKU', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                  Expanded(flex: 4, child: Text('JUDUL BUKU', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                  Expanded(flex: 3, child: Text('PEMINJAM', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                  Expanded(flex: 2, child: Text('TGL PINJAM', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                  Expanded(flex: 2, child: Text('BATAS KEMBALI', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                  Expanded(flex: 2, child: Text('STATUS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue))),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Data Rows
            filteredList.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text('Tidak ada data transaksi ditemukan.', style: GoogleFonts.inter(color: AppTheme.textMuted)),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) => const Divider(color: AppTheme.borderLight, height: 1),
                    itemBuilder: (context, index) {
                      final item = filteredList[index];

                      Color statusColor = AppTheme.accentBlue;
                      if (item.status == 'Dikembalikan') statusColor = AppTheme.accentGreen;
                      if (item.status == 'Terlambat') statusColor = AppTheme.accentOrange;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(flex: 3, child: Text(item.noTransaksi, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.accentGreen, fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text(item.noBuku, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary))),
                            Expanded(flex: 4, child: Text(item.judulBuku ?? '-', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary))),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.nama, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                                  Text('Kelas: ${item.kelas}', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                                ],
                              ),
                            ),
                            Expanded(flex: 2, child: Text(item.waktuPinjam, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary))),
                            Expanded(flex: 2, child: Text(item.waktuKembali, style: GoogleFonts.inter(fontSize: 12, color: item.status == 'Terlambat' ? AppTheme.accentRed : AppTheme.textSecondary))),
                            Expanded(
                              flex: 2,
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
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
