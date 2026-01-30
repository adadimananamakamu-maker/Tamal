import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageServerPage extends StatefulWidget {
  final String keyToken; // Ini sessionKey lo
  const ManageServerPage({super.key, required this.keyToken});

  @override
  State<ManageServerPage> createState() => _ManageServerPageState();
}

class _ManageServerPageState extends State<ManageServerPage> {
  bool isLoading = true;
  Map<String, dynamic>? serverData;

  // --- Warna Tema ---
  final Color primaryDark = Colors.black;
  final Color primaryWhite = Colors.white; // FIX: Sudah dibenerin dari typo Co{lors
  final Color accentRed = Colors.redAccent;
  final Color cardDark = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _fetchServerData();
  }

  // API Logic lo tetep ada di sini
  Future<void> _fetchServerData() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("http://dianaxyz-offc.hostingercloud.web.id:4278/myServer?key=${widget.keyToken}"),
      );

      if (response.statusCode == 200) {
        setState(() {
          serverData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      appBar: AppBar(
        title: const Text("MANAGE VPS SERVER", 
          style: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildServerCard(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildServerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: accentRed.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("SERVER STATUS", style: TextStyle(color: accentRed, fontFamily: 'Orbitron')),
          const Divider(color: Colors.white10),
          _infoRow("Status", serverData?['status'] ?? "Online"),
          _infoRow("IP Address", serverData?['ip'] ?? "127.0.0.1"),
          _infoRow("Region", serverData?['region'] ?? "Singapore"),
          _infoRow("Expired", serverData?['expired'] ?? "-"),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("REBOOT"),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: accentRed),
            child: const Text("SHUTDOWN"),
          ),
        ),
      ],
    );
  }
}
