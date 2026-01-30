import 'dart:ui';
import 'package:flutter/material.dart';
import 'manage_server.dart';
import 'wifi_internal.dart';
import 'wifi_external.dart'; // File yang baru lo benerin tadi
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
        title: const Text("TOOLS GATEWAY", style: TextStyle(fontFamily: 'Orbitron')),
        backgroundColor: Colors.transparent,
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
          // Tambahkan tile lainnya di sini sesuai kebutuhan
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
        leading: Icon(icon, color: color),
        title: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
        onTap: onTap,
      ),
    );
  }
}
