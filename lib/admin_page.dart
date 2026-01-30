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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("ADMIN PANEL", style: TextStyle(fontFamily: 'Orbitron')), backgroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("CREATE ACCOUNT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: createUsernameController, decoration: _inputDecoration("New Username"), style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            TextField(controller: createPasswordController, decoration: _inputDecoration("New Password"), style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            TextField(controller: createDayController, decoration: _inputDecoration("Days"), style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {}, 
              style: ElevatedButton.styleFrom(backgroundColor: primaryRed, minimumSize: const Size(double.infinity, 50)),
              child: const Text("CREATE"),
            ),
          ],
        ),
      ),
    );
  }
}
