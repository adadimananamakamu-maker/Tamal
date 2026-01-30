import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'splash.dart'; // Pastikan ini mengarah ke file video splash lo

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userController = TextEditingController();
  final passController = TextEditingController();
  bool isLoading = false;
  bool obscurePass = true;

  final Color primaryRed = const Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // Ambil data login yang tersimpan biar gak ngetik ulang
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userController.text = prefs.getString('saved_user') ?? '';
      passController.text = prefs.getString('saved_pass') ?? '';
    });
  }

  Future<void> _handleLogin() async {
    if (userController.text.isEmpty || passController.text.isEmpty) {
      _showSnackBar("Please fill all fields");
      return;
    }

    setState(() => isLoading = true);

    // Endpoint API Login lo
    final url = "http://dianaxyz-offc.hostingercloud.web.id:4278/login?user=${userController.text}&pass=${passController.text}";

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        // Simpan login sukses ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_user', userController.text);
        await prefs.setString('saved_pass', passController.text);

        if (!mounted) return;

        // --- NAVIGASI KE SPLASH VIDEO (Kirim Semua Data) ---
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SplashScreen(
              username: userController.text,
              password: passController.text,
              role: data['role'] ?? 'member',
              expiredDate: data['expired'] ?? '-',
              sessionKey: data['key'] ?? '',
              listBug: List<Map<String, dynamic>>.from(data['list_bug'] ?? []),
              listDoos: List<Map<String, dynamic>>.from(data['list_ddos'] ?? []),
              news: data['news'] ?? [],
            ),
          ),
        );
      } else {
        _showSnackBar(data['message'] ?? "Login Invalid");
      }
    } catch (e) {
      _showSnackBar("Server Error: Check your connection");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: primaryRed, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            colors: [Colors.black, primaryRed.withOpacity(0.1), Colors.black],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Icon(Icons.security, size: 80, color: primaryRed),
                const SizedBox(height: 20),
                const Text("X-GATEWAY ACCESS", 
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Orbitron')),
                const SizedBox(height: 40),

                _buildInputField(userController, "Username", Icons.person_outline, false),
