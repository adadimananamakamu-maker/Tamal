import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'nik_check.dart';
import 'admin_page.dart';
import 'home_page.dart';
import 'seller_page.dart';
import 'change_password_page.dart';
import 'tools_gateway.dart';
import 'login_page.dart';
import 'bug_sender.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  final String password;
  final String role;
  final String expiredDate;
  final String sessionKey;
  final List<Map<String, dynamic>> listBug;
  final List<Map<String, dynamic>> listDoos;
  final List<dynamic> news;

  const DashboardPage({
    super.key,
    required this.username,
    required this.password,
    required this.role,
    required this.expiredDate,
    required this.listBug,
    required this.listDoos,
    required this.sessionKey,
    required this.news,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late WebSocketChannel channel;

  int _bottomNavIndex = 0;
  Widget _selectedPage = const Placeholder();

  int onlineUsers = 0;
  int activeConnections = 0;

  final Color primaryDark = Colors.black;
  final Color primaryRed = const Color(0xFFE53935);
  final Color accentRed = const Color(0xFFB71C1C);
  final Color lightRed = const Color(0xFFEF5350);
  final Color primaryWhite = Colors.white;
  final Color accentGrey = Colors.grey.shade400;
  final Color cardDark = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    _selectedPage = _buildNewsPage();
    _initAndroidIdAndConnect();
  }

  Future<void> _initAndroidIdAndConnect() async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    _connectToWebSocket(deviceInfo.id);
  }

  void _connectToWebSocket(String androidId) {
    try {
      channel = WebSocketChannel.connect(Uri.parse('wss://ws-yosh.nullxteam.fun'));
      channel.sink.add(jsonEncode({
        "type": "validate",
        "key": widget.sessionKey,
        "androidId": androidId,
      }));
      channel.sink.add(jsonEncode({"type": "stats"}));

      channel.stream.listen((event) {
        final data = jsonDecode(event);
        if (data['type'] == 'stats') {
          setState(() {
            onlineUsers = data['onlineUsers'] ?? 0;
            activeConnections = data['activeConnections'] ?? 0;
          });
        }
      });
    } catch (_) {}
  }

  void _handleInvalidSession(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
      if (index == 0) {
        _selectedPage = _buildNewsPage();
      } else if (index == 1) {
        _selectedPage = HomePage(
          username: widget.username,
          password: widget.password,
          listBug: widget.listBug,
          role: widget.role,
          expiredDate: widget.expiredDate,
          sessionKey: widget.sessionKey,
        );
      } else if (index == 2) {
        _selectedPage = ToolsPage(
            sessionKey: widget.sessionKey, userRole: widget.role, listDoos: widget.listDoos);
      }
    });
  }

  void _onSidebarTabSelected(int index) {
    setState(() {
      if (index == 3) _selectedPage = NikCheckerPage();
      else if (index == 4) _selectedPage = ChangePasswordPage(username: widget.username, sessionKey: widget.sessionKey);
      else if (index == 5) _selectedPage = SellerPage(keyToken: widget.sessionKey);
      else if (index == 6) _selectedPage = AdminPage(sessionKey: widget.sessionKey);
    });
  }

  Widget _buildNewsPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'nik_check.dart';
import 'admin_page.dart';
import 'home_page.dart';
import 'seller_page.dart';
import 'change_password_page.dart';
import 'tools_gateway.dart';
import 'login_page.dart';
import 'bug_sender.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  final String password;
  final String role;
  final String expiredDate;
  final String sessionKey;
  final List<Map<String, dynamic>> listBug;
  final List<Map<String, dynamic>> listDoos;
  final List<dynamic> news;

  const DashboardPage({
    super.key,
    required this.username,
    required this.password,
    required this.role,
    required this.expiredDate,
    required this.listBug,
    required this.listDoos,
    required this.sessionKey,
    required this.news,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late WebSocketChannel channel;
  int _bottomNavIndex = 0;
  Widget _selectedPage = const Center(child: CircularProgressIndicator());
  int onlineUsers = 0;
  int activeConnections = 0;

  final Color primaryDark = Colors.black;
  final Color primaryRed = const Color(0xFFE53935);
  final Color cardDark = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _selectedPage = _buildNewsPage();
    _initAndroidIdAndConnect();
  }

  Future<void> _initAndroidIdAndConnect() async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    _connectToWebSocket(deviceInfo.id);
  }

  void _connectToWebSocket(String androidId) {
    try {
      channel = WebSocketChannel.connect(Uri.parse('wss://ws-yosh.nullxteam.fun'));
      channel.sink.add(jsonEncode({"type": "validate", "key": widget.sessionKey, "androidId": androidId}));
      channel.stream.listen((event) {
        final data = jsonDecode(event);
        if (data['type'] == 'stats') {
          setState(() {
            onlineUsers = data['onlineUsers'] ?? 0;
            activeConnections = data['activeConnections'] ?? 0;
          });
        }
      });
    } catch (_) {}
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
      if (index == 0) _selectedPage = _buildNewsPage();
      else if (index == 1) _selectedPage = HomePage(username: widget.username, password: widget.password, listBug: widget.listBug, role: widget.role, expiredDate: widget.expiredDate, sessionKey: widget.sessionKey);
      else if (index == 2) _selectedPage = ToolsPage(sessionKey: widget.sessionKey, userRole: widget.role, listDoos: widget.listDoos);
    });
  }

  Widget _buildNewsPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            height: 150,
            child: PageView.builder(
              itemCount: widget.news.length,
              itemBuilder: (context, index) => Card(
                color: cardDark,
                child: Center(child: Text(widget.news[index]['title'] ?? "News", style: const TextStyle(color: Colors.white))),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: primaryRed.withOpacity(0.5))),
            child: Column(
              children: [
                _infoRow("User", widget.username),
                _infoRow("Role", widget.role.toUpperCase()),
                _infoRow("Exp", widget.expiredDate),
                const Divider(color: Colors.white24),
                _infoRow("Online", "$onlineUsers"),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BugSenderPage(sessionKey: widget.sessionKey, username: widget.username, role: widget.role))),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
                  child: const Text("MANAGE BUG SENDER"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _infoRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      appBar: AppBar(title: const Text("VIONIX ENGINE"), backgroundColor: primaryDark, centerTitle: true),
      drawer: Drawer(
        backgroundColor: primaryDark,
        child: ListView(
          children: [
            DrawerHeader(decoration: BoxDecoration(color: primaryRed), child: const Text("MENU", style: TextStyle(color: Colors.white, fontSize: 24))),
            if (widget.role == "reseller" || widget.role == "owner") ListTile(leading: Icon(Icons.store, color: primaryRed), title: const Text("Seller Page", style: TextStyle(color: Colors.white)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SellerPage(keyToken: widget.sessionKey)))),
            if (widget.role == "owner") ListTile(leading: Icon(Icons.admin_panel_settings, color: primaryRed), title: const Text("Admin Page", style: TextStyle(color: Colors.white)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPage(sessionKey: widget.sessionKey)))),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text("Logout", style: TextStyle(color: Colors.white)), onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false)),
          ],
        ),
      ),
      body: _selectedPage,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: cardDark,
        currentIndex: _bottomNavIndex,
        selectedItemColor: primaryRed,
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: "News"),
          BottomNavigationBarItem(icon: Icon(Icons.bug_report), label: "Bugs"),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: "Tools"),
        ],
      ),
    );
  }
}
