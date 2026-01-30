import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  final String? password;
  final String role;
  final String expiredDate;
  final String sessionKey;
  final List<Map<String, dynamic>> listBug;
  final List<Map<String, dynamic>> listDoos;
  final List<dynamic> news;

  const DashboardPage({
    super.key,
    required this.username,
    this.password,
    required this.role,
    required this.expiredDate,
    required this.sessionKey,
    required this.listBug,
    required this.listDoos,
    required this.news,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  
  // Fungsi Logout
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // --- FUNGSI INFO ROW (INI YANG TADI ERROR) ---
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'ShareTechMono')),
        ],
      ),
    );
  }

  // --- FUNGSI MENU CARD (INI JUGA YANG TADI ERROR) ---
  Widget _menuCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 35),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("PLAY THE DARKNES", style: TextStyle(fontFamily: 'Orbitron', fontSize: 16, color: Colors.redAccent)),
        backgroundColor: Colors.black,
        actions: [IconButton(icon: const Icon(Icons.logout, color: Colors.red), onPressed: _logout)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  _infoRow("OPERATOR", widget.username),
                  _infoRow("PRIVILEGE", widget.role.toUpperCase()),
                  _infoRow("EXPIRED", widget.expiredDate),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _menuCard("BUG ENGINE", Icons.bug_report, Colors.orange, () {
                  Navigator.pushNamed(context, '/home', arguments: {
                    'username': widget.username,
                    'listBug': widget.listBug,
                    'role': widget.role,
                    'sessionKey': widget.sessionKey,
                  });
                }),
                _menuCard("ADMIN PANEL", Icons.admin_panel_settings, Colors.blue, () {
                  Navigator.pushNamed(context, '/admin', arguments: {'sessionKey': widget.sessionKey});
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
