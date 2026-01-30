import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// Import halaman tujuan navigasi
import 'admin_page.dart';
import 'home_page.dart';
import 'login_page.dart';

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
  
  // Fungsi Logout (Biar beneran sistem, bukan demo)
  Future<void> _handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("PLAY THE DARKNES", 
          style: TextStyle(fontFamily: 'Orbitron', fontSize: 16, color: Colors.redAccent)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.red),
            onPressed: _handleLogout,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BOX INFO USER (Fix _infoRow Error) ---
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 10)
                ]
              ),
              child: Column(
                children: [
                  _infoRow("OPERATOR", widget.username),
                  _infoRow("PRIVILEGE", widget.role.toUpperCase()),
                  _infoRow("EXPIRED", widget.expiredDate),
                  _infoRow("SESSION ID", widget.sessionKey.length > 10 
                      ? widget.sessionKey.substring(0, 10) + "..." 
                      : widget.sessionKey),
                ],
              ),
            ),
            const SizedBox(height: 25),
            
            const Text("DARK ENGINE TOOLS", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2)),
            const SizedBox(height: 15),

            // --- GRID MENU ---
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _menuCard("BUG LIST", Icons.bug_report, Colors.orange, () {
                  Navigator.pushNamed(context, '/home
