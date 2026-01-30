import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late VideoPlayerController _controller;
  late VideoPlayerController _backgroundController;

  // Warna tema merah-hitam
  final Color primaryDark = Color(0xFF0D0D0D);
  final Color primaryRed = Color(0xFFE53935); // Merah utama
  final Color accentRed = Color(0xFFB71C1C); // Merah aksen lebih gelap
  final Color lightRed = Color(0xFFEF5350); // Merah lebih terang
  final Color primaryWhite = Colors.white;
  final Color cardDark = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();

    // Controller untuk video di card
    _controller = VideoPlayerController.asset("assets/videos/landing.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });

    // Controller untuk video background (menggunakan video yang sama)
    _backgroundController = VideoPlayerController.asset("assets/videos/landing.mp4")
      ..initialize().then((_) {
        setState(() {});
        _backgroundController.setLooping(true);
        _backgroundController.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $uri");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          "assets/images/logo.png",
          width: 60,
          height: 60,
        ),
      ),
      body: Stack(
        children: [
          // Video background
          _backgroundController.value.isInitialized
              ? SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _backgroundController.value.size.width,
                height: _backgroundController.value.size.height,
                child: VideoPlayer(_backgroundController),
              ),
            ),
          )
              : Container(
            color: primaryDark,
          ),

          // Glass effect overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          ),

          // Content overlay
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Glass video card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              _controller.value.isInitialized
                                  ? SizedBox(
                                width: double.infinity,
                                height: 200,
                                child: VideoPlayer(_controller),
                              )
                                  : Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.red[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: primaryRed,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                "Yoshimitsu",
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: lightRed,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(2, 2),
                                      blurRadius: 8,
                                      color: Colors.black.withOpacity(0.8),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 90),

                        const Text(
                          "Please Log in or Register to continue",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryRed,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: primaryRed,
                              elevation: 6,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, "/login");
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: primaryRed,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _openUrl("http://ssadihodtingg.publicsrv.my.id:6289"),
                            child: Text(
                              "Register",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryRed),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      const Text(
                        "Contact Us",
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: FaIcon(
                              FontAwesomeIcons.telegram,
                              color: primaryRed,
                              size: 28,
                            ),
                            onPressed: () => _openUrl("https://t.me/Tighplay"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "© 2025 Play The Dark",
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}