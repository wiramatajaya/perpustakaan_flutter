import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/library_provider.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibraryProvider>(context);

    final menuItems = [
      {'label': 'Dashboard', 'icon': LucideIcons.layoutDashboard},
      {'label': 'Pengunjung', 'icon': LucideIcons.fileText},
      {'label': 'Daftar Buku', 'icon': LucideIcons.bookOpen},
      {'label': 'Form Transaksi', 'icon': LucideIcons.refreshCw},
      {'label': 'Riwayat Transaksi', 'icon': LucideIcons.clipboardCheck},
    ];

    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Color(0xFF090E17),
        border: Border(
          right: BorderSide(
            color: Color(0x1A38BDF8),
            width: 1.2,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Brand Logo & Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.bookOpen,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'My Perpus',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Menu items list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: menuItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = provider.activeMenuIndex == index;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0x3B38BDF8), Color(0x1F1E293B)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : null,
                    border: isSelected
                        ? Border.all(
                            color: AppTheme.accentBlue.withOpacity(0.4),
                            width: 1,
                          )
                        : null,
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Icon(
                      item['icon'] as IconData,
                      color: isSelected ? AppTheme.accentBlue : AppTheme.textSecondary,
                      size: 20,
                    ),
                    title: Text(
                      item['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                      ),
                    ),
                    onTap: () => provider.setActiveMenu(index),
                  ),
                );
              },
            ),
          ),

          // Footer info
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x1A1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.info, size: 16, color: AppTheme.accentBlue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'SD Negeri Perpus v1.0',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
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
