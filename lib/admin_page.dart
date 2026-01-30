import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPage extends StatefulWidget {
  final String sessionKey;
  const AdminPage({super.key, required this.sessionKey});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final createUsernameController = TextEditingController();
  final createPasswordController = TextEditingController();
  final createDayController = TextEditingController();
  final deleteUsernameController = TextEditingController();
  
  String newUserRole = 'member';
  bool isLoading = false;
  final List<String> roleOptions = ['vip', 'reseller', 'reseller1', 'owner', 'member'];
  final Color primaryRed = const Color(0xFFE53935);

  // --- LOGIC API CREATE ---
  Future<void> _createAccount() async {
    if (createUsernameController.text.isEmpty) return;
    setState(() => isLoading = true);
    final url = "http://dianaxyz-offc.hostingercloud.web.id:4278/createAccount?key=${widget.sessionKey}&user=${createUsernameController.text}&pass=${createPasswordController.text}&day=${createDayController.text}&role=$newUserRole";
    try {
      final res = await http.get(Uri.parse(url));
      _showMsg(res.body);
      if (res.body.contains("success")) {
        createUsernameController.clear();
        createPasswordController.clear();
      }
    } catch (e) {
      _showMsg("Connection Error!");
    }
    setState(() => isLoading = false);
  }

  // --- LOGIC API DELETE ---
  Future<void> _deleteAccount() async {
    if (deleteUsernameController.text.isEmpty) return;
    setState(() => isLoading = true);
    final url = "http://dianaxyz-offc.hostingercloud.web.id:4278/deleteAccount?key=${widget.sessionKey}&user=${deleteUsernameController.text}";
    try {
      final res = await http.get(Uri.parse(url));
      _showMsg(res.body);
      deleteUsernameController.clear();
    } catch (e) {
      _showMsg("Connection Error!");
    }
    setState(() => isLoading = false);
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: primaryRed));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("ADMIN DASHBOARD", style: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSectionTitle("CREATE NEW USER"),
            const SizedBox(height: 15),
            _buildTextField(createUsernameController, "New Username", Icons.person_add),
            const SizedBox(height: 10),
            _buildTextField(createPasswordController, "New Password", Icons.vpn_key),
            const SizedBox(height: 10),
            _buildTextField(createDayController, "Duration (Days)", Icons.timer, isNumber: true),
            const SizedBox(height: 15),
            _buildRoleDropdown(),
            const SizedBox(height: 20),
            _buildButton("CREATE USER NOW", _createAccount, primaryRed),
            
            const SizedBox(height: 40),
            const Divider(color: Colors.white24, thickness: 1),
            const SizedBox(height: 20),
            
            _buildSectionTitle("DELETE USER SYSTEM"),
            const SizedBox(height: 15),
            _buildTextField(deleteUsernameController, "Target Username", Icons.delete_forever),
            const SizedBox(height: 20),
            _buildButton("DELETE ACCOUNT", _deleteAccount, Colors.grey[900]!),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE WIDGETS ---
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Orbitron', letterSpacing: 1.2)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryRed, size: 20),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF111111),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primaryRed.withOpacity(0.2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primaryRed)),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(10), border: Border.all(color: primaryRed.withOpacity(0.2))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: newUserRole,
          dropdownColor: Colors.black,
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontFamily: 'Orbitron', fontSize: 12),
          items: roleOptions.map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase()))).toList(),
          onChanged: (v) => setState(() => newUserRole = v!),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback press, Color bg) {
    return ElevatedButton(
      onPressed: isLoading ? null : press,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg, 
        minimumSize: const Size(double.infinity, 55), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.white10))
      ),
      child: isLoading 
        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
        : Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
    );
  }
}
