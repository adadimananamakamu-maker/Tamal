import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Ini jangan sampe ilang
import 'dart:convert';

class AdminPage extends StatefulWidget {
  final String sessionKey;
  const AdminPage({super.key, required this.sessionKey});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final deleteController = TextEditingController();
  final createUsernameController = TextEditingController();
  final createPasswordController = TextEditingController();
  final createDayController = TextEditingController();
  
  String newUserRole = 'member';
  bool isLoading = false;
  final List<String> roleOptions = ['vip', 'reseller', 'reseller1', 'owner', 'member'];
  final Color primaryRed = const Color(0xFFE53935);

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryRed.withOpacity(0.3))),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryRed)),
      filled: true,
      fillColor: Colors.black,
    );
  }

  Future<void> _deleteUser() async {
    if (deleteController.text.isEmpty) return _showDialog("⚠️", "Isi username!");
    setState(() => isLoading = true);
    try {
      // http gue balikin di sini
      final res = await http.get(Uri.parse('http://dianaxyz-offc.hostingercloud.web.id:4278/deleteUser?key=${widget.sessionKey}&username=${deleteController.text}'));
      final data = jsonDecode(res.body);
      _showDialog(data['deleted'] == true ? "✅" : "❌", data['message'] ?? "Selesai");
      if (data['deleted'] == true) deleteController.clear();
    } catch (_) { _showDialog("🌐", "Server Error"); }
    setState(() => isLoading = false);
  }

  Future<void> _createAccount() async {
    if (createUsernameController.text.isEmpty || createPasswordController.text.isEmpty) return _showDialog("⚠️", "Lengkapi data!");
    setState(() => isLoading = true);
    try {
      final url = 'http://dianaxyz-offc.hostingercloud.web.id:4278/userAdd?key=${widget.sessionKey}&username=${createUsernameController.text}&password=${createPasswordController.text}&day=${createDayController.text}&role=$newUserRole';
      // http gue balikin di sini juga
      final res = await http.get(Uri.parse(url));
      final data = jsonDecode(res.body);
      _showDialog(data['created'] == true ? "✅" : "❌", data['message'] ?? "Selesai");
      if (data['created'] == true) {
        createUsernameController.clear();
        createPasswordController.clear();
        createDayController.clear();
      }
    } catch (_) { _showDialog("🌐", "Server Error"); }
    setState(() => isLoading = false);
  }

  void _showDialog(String title, String msg) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: Colors.black,
      title: Text("$title Alert", style: const TextStyle(color: Colors.white)),
      content: Text(msg, style: const TextStyle(color: Colors.grey)),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK", style: TextStyle(color: primaryRed)))]
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("VIONIX ADMIN"), backgroundColor: Colors.black, centerTitle: true),
      body: isLoading ? Center(child: CircularProgressIndicator(color: primaryRed)) : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _section("CREATE ACCOUNT", Icons.person_add),
            const SizedBox(height: 10),
            TextField(controller: createUsernameController, decoration: _inputDecoration("Username"), style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            TextField(controller: createPasswordController, decoration: _inputDecoration("Password"), style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            TextField(controller: createDayController, decoration: _inputDecoration("Days"), keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              dropdownColor: const Color(0xFF1A1A1A),
              value: newUserRole,
              items: roleOptions.map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase(), style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: (v) => setState(() => newUserRole = v!),
              decoration: _inputDecoration("Role"),
            ),
            const SizedBox(height: 15),
            ElevatedButton(onPressed: _createAccount, style: ElevatedButton.styleFrom(backgroundColor: primaryRed, minimumSize: const Size(double.infinity, 50)), child: const Text("CREATE")),
            const SizedBox(height: 30),
            _section("DELETE USER", Icons.delete),
            const SizedBox(height: 10),
            TextField(controller: deleteController, decoration: _inputDecoration("Username"), style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _deleteUser, style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900, minimumSize: const Size(double.infinity, 50)), child: const Text("DELETE")),
          ],
        ),
      ),
    );
  }

  Widget _section(String t, IconData i) => Row(children: [Icon(i, color: primaryRed), const SizedBox(width: 10), Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]);
}
