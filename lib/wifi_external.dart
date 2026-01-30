import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WifiExternalPage extends StatefulWidget {
  final String sessionKey;
  const WifiExternalPage({super.key, required this.sessionKey});

  @override
  State<WifiExternalPage> createState() => _WifiExternalPageState();
}

class _WifiExternalPageState extends State<WifiExternalPage> {
  String publicIp = "-";
  String region = "-";
  String city = "-";
  String asn = "-";
  bool isVpn = false;
  bool isLoading = true;
  bool isAttacking = false;

  final Color primaryDark = Colors.black;
  final Color primaryWhite = Colors.white;
  final Color accentRed = Colors.redAccent;
  final Color cardDark = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _loadPublicInfo();
  }

  Future<void> _loadPublicInfo() async {
    setState(() => isLoading = true);
    try {
      final ipRes = await http.get(Uri.parse("https://ipapi.co/json/"));
      if (ipRes.statusCode == 200) {
        final data = jsonDecode(ipRes.body);
        setState(() {
          publicIp = data['ip'] ?? "-";
          region = data['region'] ?? "-";
          city = data['city'] ?? "-";
          asn = data['org'] ?? "-";
          String org = asn.toLowerCase();
          isVpn = org.contains("hosting") || org.contains("vpn") || org.contains("google");
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _attackTarget() async {
    setState(() => isAttacking = true);
    await Future.delayed(const Duration(seconds: 3)); 
    setState(() => isAttacking = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Attack Execution Finished")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      appBar: AppBar(
        title: const Text("WIFI EXTERNAL", style: TextStyle(fontFamily: 'Orbitron', color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoCard(),
                const SizedBox(height: 30),
                if (isVpn)
                  const Text("⚠️ Target VPN Terdeteksi", style: TextStyle(color: Colors.red))
                else
                  ElevatedButton.icon(
                    onPressed: isAttacking ? null : _attackTarget,
                    icon: const Icon(Icons.wifi_off),
                    label: Text(isAttacking ? "ATTACKING..." : "START KILL"),
                    style: ElevatedButton.styleFrom(backgroundColor: accentRed, foregroundColor: Colors.white),
                  ),
              ],
            ),
          ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(15), border: Border.all(color: accentRed.withOpacity(0.3))),
      child: Column(
        children: [
          _infoRow("Public IP", publicIp),
          _infoRow("Region", region),
          _infoRow("ISP/ASN", asn),
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
}
