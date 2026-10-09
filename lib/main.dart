import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/theme/app_theme.dart';
import 'providers/library_provider.dart';
import 'widgets/sidebar.dart';
import 'widgets/top_bar.dart';
import 'views/dashboard_view.dart';
import 'views/pengunjung_view.dart';
import 'views/daftar_buku_view.dart';
import 'views/form_transaksi_view.dart';
import 'views/riwayat_transaksi_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Desktop FFI SQLite initialization (Windows, Linux, macOS)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
      ],
      child: const MyPerpusApp(),
    ),
  );
}

class MyPerpusApp extends StatelessWidget {
  const MyPerpusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Perpus - Sistem Informasi Perpustakaan SD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainShellView(),
    );
  }
}

class MainShellView extends StatelessWidget {
  const MainShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibraryProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 800;

    final List<Widget> views = [
      const DashboardView(),
      const PengunjungView(),
      const DaftarBukuView(),
      const FormTransaksiView(),
      const RiwayatTransaksiView(),
    ];

    final List<String> titles = [
      'Dashboard',
      'daftar kunjungan',
      'Daftar Buku',
      'Form Transaksi',
      'Riwayat Transaksi',
    ];

    return Scaffold(
      drawer: isMobile ? const Drawer(child: Sidebar()) : null,
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: provider.activeMenuIndex,
              onTap: (index) => provider.setActiveMenu(index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(0xFF090E17),
              selectedItemColor: AppTheme.accentBlue,
              unselectedItemColor: AppTheme.textSecondary,
              selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 10),
              items: const [
                BottomNavigationBarItem(icon: Icon(LucideIcons.layoutDashboard), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.fileText), label: 'Pengunjung'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.bookOpen), label: 'Buku'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.refreshCw), label: 'Transaksi'),
                BottomNavigationBarItem(icon: Icon(LucideIcons.clipboardCheck), label: 'Riwayat'),
              ],
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF090E17), Color(0xFF0D1527), Color(0xFF090E17)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            // Desktop Left Sidebar (Only shown on Desktop/Tablet > 800px)
            if (!isMobile) const Sidebar(),

            // Main Workspace
            Expanded(
              child: Column(
                children: [
                  // Top Header Bar
                  TopBar(title: titles[provider.activeMenuIndex]),

                  // Dynamic View Page Content
                  Expanded(
                    child: IndexedStack(
                      index: provider.activeMenuIndex,
                      children: views,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
