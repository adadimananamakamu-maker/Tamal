import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';

import 'nik_check.dart';
import 'admin_page.dart';
import 'home_page.dart';
import 'seller_page.dart';
import 'change_password_page.dart';
import 'tools_gateway.dart';
import 'login_page.dart';
import 'bug_sender.dart'; // Import halaman Bug Sender

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

  late String sessionKey;
  late String username;
  late String password;
  late String role;
  late String expiredDate;
  late List<Map<String, dynamic>> listBug;
  late List<Map<String, dynamic>> listDoos;
  late List<dynamic> newsList;
  String androidId = "unknown";

  int _bottomNavIndex = 0;
  Widget _selectedPage = const Placeholder();

  int onlineUsers = 0;
  int activeConnections = 0;

  // Warna tema merah hitam
  final Color primaryDark = Colors.black;
  final Color primaryRed = Color(0xFFE53935); // Merah utama
  final Color accentRed = Color(0xFFB71C1C); // Merah aksen lebih gelap
  final Color lightRed = Color(0xFFEF5350); // Merah lebih terang
  final Color primaryWhite = Colors.white;
  final Color accentGrey = Colors.grey.shade400;
  final Color cardDark = Color(0xFF1A1A1A);
  final Color redGradientStart = Color(0xFFE53935);
  final Color redGradientEnd = Color(0xFFB71C1C);

  @override
  void initState() {
    super.initState();
    sessionKey = widget.sessionKey;
    username = widget.username;
    password = widget.password;
    role = widget.role;
    expiredDate = widget.expiredDate;
    listBug = widget.listBug;
    listDoos = widget.listDoos;
    newsList = widget.news;

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
    androidId = deviceInfo.id;
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    channel = WebSocketChannel.connect(Uri.parse('wss://ws-yosh.nullxteam.fun'));
    channel.sink.add(jsonEncode({
      "type": "validate",
      "key": sessionKey,
      "androidId": androidId,
    }));
    channel.sink.add(jsonEncode({"type": "stats"}));

    channel.stream.listen((event) {
      final data = jsonDecode(event);
      if (data['type'] == 'myInfo') {
        if (data['valid'] == false) {
          if (data['reason'] == 'androidIdMismatch') {
            _handleInvalidSession("Your account has logged on another device.");
          } else if (data['reason'] == 'keyInvalid') {
            _handleInvalidSession("Key is not valid. Please login again.");
          }
        }
      }
      if (data['type'] == 'stats') {
        setState(() {
          onlineUsers = data['onlineUsers'] ?? 0;
          activeConnections = data['activeConnections'] ?? 0;
        });
      }
    });
  }

  void _handleInvalidSession(String message) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: primaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text("⚠️ Session Expired", style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold)),
        content: Text(message, style: TextStyle(color: accentGrey)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
              );
            },
            child: Text("OK", style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
      if (index == 0) {
        _selectedPage = _buildNewsPage();
      } else if (index == 1) {
        _selectedPage = HomePage(
          username: username,
          password: password,
          listBug: listBug,
          role: role,
          expiredDate: expiredDate,
          sessionKey: sessionKey,
        );
      } else if (index == 2) {
        _selectedPage = ToolsPage(
            sessionKey: sessionKey, userRole: role, listDoos: listDoos);
      }
    });
  }

  void _onSidebarTabSelected(int index) {
    setState(() {
      if (index == 3) _selectedPage = NikCheckerPage();
      else if (index == 4) _selectedPage = ChangePasswordPage(username: username, sessionKey: sessionKey);
      else if (index == 5) _selectedPage = SellerPage(keyToken: sessionKey);
      else if (index == 6) _selectedPage = AdminPage(sessionKey: sessionKey);
    });
  }

  Widget _buildNewsPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // News Section - Dengan gradien merah
          Container(
            width: double.infinity,
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.9),
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final item = newsList[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: cardDark,
                    boxShadow: [
                      BoxShadow(
                        color: primaryRed.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (item['image'] != null && item['image'].toString().isNotEmpty)
                          NewsMedia(url: item['image']),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                                primaryRed.withOpacity(0.1),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] ?? 'No Title',
                                style: TextStyle(
                                  color: primaryWhite,
                                  fontSize: 14,
                                  fontFamily: "Orbitron",
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: primaryRed.withOpacity(0.8),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['desc'] ?? '',
                                style: TextStyle(
                                  color: lightRed,
                                  fontFamily: "ShareTechMono",
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Account Info Section - Dengan aksen merah
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryRed.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: primaryRed.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header - Dengan gradien merah
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryRed, accentRed],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_outline, color: primaryWhite, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "ACCOUNT INFO",
                          style: TextStyle(
                            color: primaryWhite,
                            fontSize: 16,
                            fontFamily: 'Orbitron',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User Info
                  _buildCompactInfoItem(
                    icon: Icons.person,
                    label: "Username",
                    value: username,
                  ),
                  const SizedBox(height: 12),

                  _buildCompactInfoItem(
                    icon: Icons.verified_user,
                    label: "Role",
                    value: role.toUpperCase(),
                    valueColor: _getRoleColor(role),
                  ),
                  const SizedBox(height: 12),

                  _buildCompactInfoItem(
                    icon: Icons.calendar_today,
                    label: "Expired",
                    value: expiredDate,
                  ),
                  const SizedBox(height: 12),

                  // Stats dalam satu row
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactInfoItem(
                          icon: Icons.people,
                          label: "Online",
                          value: "$onlineUsers",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCompactInfoItem(
                          icon: Icons.link,
                          label: "Connections",
                          value: "$activeConnections",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Tombol Manage Bug Sender - Dengan gradien merah
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.bug_report, color: primaryWhite, size: 18),
                      label: Text(
                        "MANAGE BUG SENDER",
                        style: TextStyle(
                          color: primaryWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbitron',
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: lightRed.withOpacity(0.5)),
                        ),
                        elevation: 4,
                        shadowColor: primaryRed.withOpacity(0.5),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BugSenderPage(
                              sessionKey: sessionKey,
                              username: username,
                              role: role,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case "owner":
        return Colors.red;
      case "vip":
        return primaryRed;
      case "reseller":
        return Colors.green;
      case "premium":
        return Colors.orange;
      default:
        return lightRed;
    }
  }

  Widget _buildCompactInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryRed.withOpacity(0.1)),
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            primaryRed.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primaryRed.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: primaryRed.withOpacity(0.3)),
            ),
            child: Icon(icon, color: lightRed, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: accentGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ShareTechMono',
                    shadows: valueColor == primaryWhite ? [
                      Shadow(
                        color: primaryRed.withOpacity(0.5),
                        blurRadius: 5,
                      ),
                    ] : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Drawer(
      backgroundColor: primaryDark,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header dengan gradien merah
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryRed, accentRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryRed, accentRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Yoshimitsu",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: primaryWhite,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 5,
                              offset: Offset(1, 1),
                            ),
                          ]
                      )),
                  const SizedBox(height: 12),
                  _buildDrawerInfo("User:", username),
                  _buildDrawerInfo("Role:", role),
                  _buildDrawerInfo("Expired:", expiredDate),
                ],
              ),
            ),
          ),
          if (role == "reseller" || role == "owner")
            _buildDrawerItem(
              icon: Icons.person,
              label: "Seller Page",
              onTap: () {
                Navigator.pop(context);
                _onSidebarTabSelected(5);
              },
            ),
          if (role == "owner")
            _buildDrawerItem(
              icon: Icons.admin_panel_settings,
              label: "Admin Page",
              onTap: () {
                Navigator.pop(context);
                _onSidebarTabSelected(6);
              },
            ),
          _buildDrawerItem(
            icon: Icons.search,
            label: "NIK Checker",
            onTap: () {
              Navigator.pop(context);
              _onSidebarTabSelected(3);
            },
          ),
          _buildDrawerItem(
            icon: Icons.lock_reset,
            label: "Change Password",
            onTap: () {
              Navigator.pop(context);
              _onSidebarTabSelected(4);
            },
          ),
          // Bug Sender di sidebar
          _buildDrawerItem(
            icon: Icons.bug_report,
            label: "Manage Bug Sender",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BugSenderPage(
                    sessionKey: sessionKey,
                    username: username,
                    role: role,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: primaryWhite.withOpacity(0.8), fontSize: 12)),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(color: primaryWhite, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(icon, color: lightRed),
        title: Text(label, style: TextStyle(color: primaryWhite)),
        onTap: onTap,
        hoverColor: primaryRed.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showAccountMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header dengan gradien merah
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryRed, accentRed],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text("👤 Account Info",
                  style: TextStyle(color: primaryWhite, fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            _infoCard(FontAwesomeIcons.user, "Username", username),
            _infoCard(FontAwesomeIcons.calendar, "Expired", expiredDate),
            _infoCard(FontAwesomeIcons.shieldAlt, "Role", role),
            const SizedBox(height: 30),
            // Tombol dengan tema merah
            ElevatedButton.icon(
              icon: Icon(Icons.lock_reset, color: primaryWhite),
              label: Text("Change Password", style: TextStyle(color: primaryWhite)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                elevation: 4,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChangePasswordPage(username: username, sessionKey: sessionKey)),
                );
              },
            ),
            const SizedBox(height: 12),
            // Tombol Bug Sender
            ElevatedButton.icon(
              icon: Icon(Icons.bug_report, color: primaryWhite),
              label: Text("Manage Bug Sender", style: TextStyle(color: primaryWhite)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                elevation: 4,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BugSenderPage(
                      sessionKey: sessionKey,
                      username: username,
                      role: role,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.logout, color: primaryWhite),
              label: Text("Logout", style: TextStyle(color: primaryWhite)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Card(
      color: cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: primaryRed.withOpacity(0.3)),
      ),
      elevation: 2,
      shadowColor: primaryRed.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryRed.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: lightRed),
            ),
            const SizedBox(width: 14),
            Text("$label:", style: TextStyle(color: accentGrey, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(value, style: TextStyle(color: primaryWhite, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      appBar: AppBar(
        title: Text("Yoshimitsu",
            style: TextStyle(
              color: primaryWhite,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              shadows: [
                Shadow(
                  color: primaryRed.withOpacity(0.8),
                  blurRadius: 10,
                ),
              ],
            )),
        backgroundColor: primaryDark,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryWhite),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primaryRed, accentRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: IconButton(
              icon: Icon(FontAwesomeIcons.userCircle, color: primaryWhite),
              onPressed: _showAccountMenu,
            ),
          )
        ],
      ),
      drawer: _buildSidebar(),
      body: FadeTransition(opacity: _animation, child: _selectedPage),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardDark,
          border: Border(top: BorderSide(color: primaryRed.withOpacity(0.3))),
          boxShadow: [
            BoxShadow(
              color: primaryRed.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: lightRed,
          unselectedItemColor: accentGrey,
          currentIndex: _bottomNavIndex,
          onTap: _onBottomNavTapped,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.whatsapp), label: "WhatsApp"),
            BottomNavigationBarItem(icon: Icon(Icons.build_circle_outlined), label: "Tools"),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    _controller.dispose();
    super.dispose();
  }
}

class NewsMedia extends StatefulWidget {
  final String url;
  const NewsMedia({super.key, required this.url});

  @override
  State<NewsMedia> createState() => _NewsMediaState();
}

class _NewsMediaState extends State<NewsMedia> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (_isVideo(widget.url)) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          setState(() {});
          _controller?.setLooping(true);
          _controller?.setVolume(0.0);
          _controller?.play();
        });
    }
  }

  bool _isVideo(String url) {
    return url.endsWith(".mp4") ||
        url.endsWith(".webm") ||
        url.endsWith(".mov") ||
        url.endsWith(".mkv");
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVideo(widget.url)) {
      if (_controller != null && _controller!.value.isInitialized) {
        return AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        );
      } else {
        return Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE53935), // Warna merah untuk loading
          ),
        );
      }
    } else {
      return Image.network(
        widget.url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade800,
          child: Icon(Icons.error, color: Color(0xFFE53935)),
        ),
      );
    }
  }
}