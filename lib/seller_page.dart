import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SellerPage extends StatefulWidget {
  final String keyToken;

  const SellerPage({super.key, required this.keyToken});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  final _newUser = TextEditingController();
  final _newPass = TextEditingController();
  final _days = TextEditingController();
  final _editUser = TextEditingController();
  final _editDays = TextEditingController();
  bool loading = false;

  // --- Warna Tema Hitam Merah ---
  final Color primaryDark = Colors.black;
  final Color primaryWhite = Colors.white;
  final Color accentRed = Colors.redAccent;
  final Color cardDark = const Color(0xFF1A1A1A);

  Future<void> _create() async {
    final u = _newUser.text.trim(), p = _newPass.text.trim(), d = _days.text.trim();
    if (u.isEmpty || p.isEmpty || d.isEmpty) return _alert("❗ Semua field wajib diisi");
    setState(() => loading = true);
    final res = await http.get(Uri.parse(
        "http://dianaxyz-offc.hostingercloud.web.id:4278/createAccount?key=${widget.keyToken}&newUser=$u&pass=$p&day=$d"));
    final data = jsonDecode(res.body);
    if (data['created'] == true) {
      _alert("✅ Akun berhasil dibuat!");
      _newUser.clear(); _newPass.clear(); _days.clear();
    } else {
      _alert("❌ ${data['message'] ?? 'Gagal membuat akun.'}");
    }
    setState(() => loading = false);
  }

  Future<void> _edit() async {
    final u = _editUser.text.trim(), d = _editDays.text.trim();
    if (u.isEmpty || d.isEmpty) return _alert("❗ Username dan durasi wajib diisi");
    setState(() => loading = true);
    final res = await http.get(Uri.parse(
        "http://dianaxyz-offc.hostingercloud.web.id:4278/editUser?key=${widget.keyToken}&username=$u&addDays=$d"));
    final data = jsonDecode(res.body);
    if (data['edited'] == true) {
      _alert("✅ Durasi berhasil diperbarui.");
      _editUser.clear(); _editDays.clear();
    } else {
      _alert("❌ ${data['message'] ?? 'Gagal mengubah durasi.'}");
    }
    setState(() => loading = false);
  }

  void _alert(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: accentRed.withOpacity(0.3)),
        ),
        content: Text(msg, style: TextStyle(color: primaryWhite)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: accentRed)),
          )
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController c, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: type,
        style: TextStyle(color: primaryWhite),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: accentRed),
          filled: true,
          fillColor: cardDark,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accentRed.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accentRed),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: TextStyle(
        color: primaryWhite, fontSize: 16, fontFamily: 'Orbitron', fontWeight: FontWeight.bold)),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryDark,
        body: Container(
          color: primaryDark,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionTitle("Buat Akun Baru"),
                _input("Username", _newUser),
                _input("Password", _newPass),
                _input("Durasi (hari)", _days, type: TextInputType.number),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: loading ? null : _create,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentRed,
                    foregroundColor: primaryWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: loading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primaryWhite,
                    ),
                  )
                      : const Text("BUAT", style: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 30),
                _sectionTitle("Ubah Durasi"),
                _input("Username", _editUser),
                _input("Tambah Durasi (hari)", _editDays, type: TextInputType.number),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: loading ? null : _edit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentRed,
                    foregroundColor: primaryWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: loading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primaryWhite,
                    ),
                  )
                      : const Text("UBAH", style: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}