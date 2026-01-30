import 'dart:ui';
import 'package:flutter/material.dart';
import 'manage_server.dart';
import 'wifi_internal.dart';
import 'wifi_external.dart'; // FIX: Sudah sinkron
import 'ddos_panel.dart';
import 'nik_check.dart';
import 'tiktok_page.dart';
import 'instagram_page.dart';
import 'qr_gen.dart';
import 'domain_page.dart';
import 'spam_ngl.dart';

class ToolsPage extends StatelessWidget {
  final String sessionKey;
  final String userRole;
  final List<Map<String, dynamic>> listDoos;

  const ToolsPage({
    super.key,
    required this.sessionKey,
    required this.userRole,
    required this.listDoos,
  });

  // --- Warna Tema Hitam Merah ---
  final Color primaryDark = Colors.black;
  final Color primaryRed = const Color(0xFFD32F2F);
  final Color accentRed = Colors.redAccent;
  final Color primaryWhite = Colors.white;
  final Color cardDark = const Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      appBar: AppBar(
        title: const Text("TOOLS GATEWAY", 
          style: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildToolTile(
            context,
            icon: Icons.wifi,
            label: "WIFI EXTERNAL",
            color: accentRed,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WifiExternalPage(sessionKey: sessionKey))
            ),
          ),
          _buildToolTile(
            context,
            icon: Icons.router,
            label: "WIFI INTERNAL",
            color: Colors.blueAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WifiKillerPage())),
          ),
          _buildToolTile(
            context,
            icon: Icons.security,
            label: "DDOS PANEL",
            color: Colors.orangeAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AttackPanel(sessionKey: sessionKey, listDoos: listDoos))),
          ),
          _buildToolTile(
            context,
            icon: Icons.search,
            label: "NIK CHECKER",
            color: Colors.greenAccent,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NikCheckerPage())),
          ),
          _buildToolTile(
            context,
            icon: Icons.video_library,
            label: "TIKTOK DL",
            color: Colors.cyanAccent,
            onTap: () => _showComingSoon(context),
          ),
        ],
      ),
    );
  }

  Widget _buildToolTile(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Card(
      color: cardDark,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: primaryRed.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryRed.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(label, style: TextStyle(color: primaryWhite, fontFamily: 'Orbitron', fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Feature Coming Soon!", style: TextStyle(fontFamily: 'Orbitron', color: primaryWhite)),
        backgroundColor: primaryRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
