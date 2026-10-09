import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/library_provider.dart';
import '../widgets/glass_card.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  static const Map<String, String> monthNames = {
    'Semua Bulan': 'Semua Bulan',
    '01': 'Januari',
    '02': 'Februari',
    '03': 'Maret',
    '04': 'April',
    '05': 'Mei',
    '06': 'Juni',
    '07': 'Juli',
    '08': 'Agustus',
    '09': 'September',
    '10': 'Oktober',
    '11': 'November',
    '12': 'Desember',
  };

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibraryProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 900;

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentBlue),
      );
    }

    final recentKunjungan = provider.dashboardFilteredKunjungan.take(6).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 28, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Dual Metric Banner matching Mockup Image 2
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            borderColor: const Color(0x3B38BDF8),
            child: isMobile
                ? Column(
                    children: [
                      // Left Stat: Buku
                      _buildMetricBox(
                        title: 'Buku',
                        count: '${provider.countJudulDashboard}',
                        subtitle: 'judul dari ${provider.countBukuDashboard} Buku tersedia',
                        color: AppTheme.accentGreen,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: AppTheme.borderLight, height: 1),
                      ),
                      // Right Stat: Pengunjung
                      _buildMetricBox(
                        title: 'Pengunjung',
                        count: '${provider.countPengunjungDashboard}',
                        subtitle: 'Akumulasi total kunjungan terdaftar',
                        color: AppTheme.accentOrange,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      // Left Stat: Buku
                      Expanded(
                        child: _buildMetricBox(
                          title: 'Buku',
                          count: '${provider.countJudulDashboard}',
                          subtitle: 'judul dari ${provider.countBukuDashboard} Buku tersedia',
                          color: AppTheme.accentGreen,
                        ),
                      ),

                      // Vertical Divider
                      Container(
                        width: 1,
                        height: 60,
                        color: AppTheme.borderLight,
                      ),

                      // Right Stat: Pengunjung
                      Expanded(
                        child: _buildMetricBox(
                          title: 'Pengunjung',
                          count: '${provider.countPengunjungDashboard}',
                          subtitle: 'Akumulasi total kunjungan terdaftar',
                          color: AppTheme.accentOrange,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),

          // Lower Section: Kunjungan Terakhir & Chart ring panel
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Kunjungan Terakhir Table
              Flexible(
                flex: isMobile ? 0 : 3,
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'kunjungan terakhir',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentBlue,
                            ),
                          ),
                          TextButton(
                            onPressed: () => provider.setActiveMenu(1),
                            child: Text(
                              'lihat',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0x1F1E293B),
                          borderRadius: BorderRadius.circular(8),
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

                      // Table Rows
                      recentKunjungan.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(30),
                              child: Center(
                                child: Text('Tidak ada data kunjungan pada filter ini.', style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 12)),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: recentKunjungan.length,
                              separatorBuilder: (context, index) => const Divider(color: AppTheme.borderLight, height: 1),
                              itemBuilder: (context, index) {
                                final item = recentKunjungan[index];
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

              // Right: Multi-Ring Chart & Filter Dropdowns Panel
              Flexible(
                flex: isMobile ? 0 : 2,
                child: GlassCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ringkasan Buku',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          // Month & Year SQLite Filter Dropdowns
                          Row(
                            children: [
                              // Month Filter
                              Container(
                                height: 34,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0x1F1E293B),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.borderLight),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: provider.dashboardMonth,
                                    dropdownColor: const Color(0xFF0F172A),
                                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white),
                                    items: monthNames.entries.map((e) {
                                      return DropdownMenuItem(
                                        value: e.key,
                                        child: Text(e.value),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) provider.setDashboardMonth(val);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),

                              // Year Filter
                              Container(
                                height: 34,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0x1F1E293B),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.borderLight),
                                ),

                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Circular Donut/Ring Chart
                      SizedBox(
                        height: 190,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 60,
                            sections: [
                              PieChartSectionData(
                                color: AppTheme.accentGreen,
                                value: provider.countBukuDashboard > 0 ? provider.countBukuDashboard.toDouble() : 1,
                                title: '',
                                radius: 18,
                              ),
                              PieChartSectionData(
                                color: AppTheme.accentBlue,
                                value: provider.countDipinjamDashboard.toDouble(),
                                title: '',
                                radius: 22,
                              ),
                              PieChartSectionData(
                                color: AppTheme.accentOrange,
                                value: provider.countTerlambatDashboard.toDouble(),
                                title: '',
                                radius: 26,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Chart Legend Metrics
                      _buildChartLegendItem('Total Eksemplar', '${provider.countBukuDashboard} Buku', AppTheme.accentGreen),
                      const SizedBox(height: 10),
                      _buildChartLegendItem('Pinjaman', '${provider.countDipinjamDashboard} Dipinjam', AppTheme.accentBlue),
                      const SizedBox(height: 10),
                      _buildChartLegendItem('Terlambat Kembali', '${provider.countTerlambatDashboard} Terlambat', AppTheme.accentOrange),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox({
    required String title,
    required String count,
    required String subtitle,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          count,
          style: GoogleFonts.inter(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegendItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}
