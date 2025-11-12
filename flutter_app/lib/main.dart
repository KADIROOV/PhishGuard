// lib/main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:convert';

void main() {
  runApp(const PhishGuardApp());
}

class PhishGuardApp extends StatelessWidget {
  const PhishGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhishGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE53935)),
        useMaterial3: true,
        fontFamily: GoogleFonts.roboto().fontFamily,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _urlController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _resultText = '';
  Map<String, dynamic> _scanResult = {};
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkUrl() async {
    if (!_formKey.currentState!.validate()) return;

    final url = _urlController.text.trim();
    setState(() {
      _isLoading = true;
      _resultText = '';
      _scanResult = {};
    });

    try {
      // Bu yerda backend API chaqiriladi (keyinroq qo‘shiladi)
      // Hozircha demo natija
      await Future.delayed(const Duration(seconds: 3));

      // Demo natija
      final demoResult = {
        "malicious": 4,
        "suspicious": 1,
        "harmless": 12,
        "undetected": 3,
        "total": 20,
        "risk_level": "XAVFLI",
        "vt_link": "https://www.virustotal.com/gui/url/demo123"
      };

      setState(() {
        _scanResult = demoResult;
        _resultText = _buildResultText(demoResult);
        _animationController.forward(from: 0);
      });
    } catch (e) {
      setState(() {
        _resultText = 'Xato: $e\nIltimos, qayta urinib ko‘ring.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _buildResultText(Map<String, dynamic> data) {
    final risk = data['risk_level'];
    final color = risk == 'XAVFSIZ'
        ? '🟢'
        : risk == 'SHUBHALI'
            ? '🟡'
            : '🔴';

    return '$color *Natija: $risk*\n\n'
        'Xavfli: ${data['malicious']}\n'
        'Shubhali: ${data['suspicious']}\n'
        'Xavfsiz: ${data['harmless']}\n'
        'Aniqlanmagan: ${data['undetected']}\n'
        'Jami: ${data['total']}\n\n'
        '[VirusTotal sahifasi](${data['vt_link']})';
  }

  void _launchVT(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'PhishGuard',
              textStyle: GoogleFonts.orbitron(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              speed: const Duration(milliseconds: 150),
            ),
          ],
          isRepeatingAnimation: false,
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.security, size: 100, color: Colors.red);
                  },
                ),
              ),
              const SizedBox(height: 30),

              // URL Input
              TextFormField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: 'Shubhali havolani kiriting',
                  hintText: 'https://example.com',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'URL kiriting';
                  }
                  if (!value.startsWith('http://') && !value.startsWith('https://')) {
                    return 'URL http yoki https bilan boshlanishi kerak';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Check Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _checkUrl,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.security),
                label: Text(
                  _isLoading ? 'Tekshirilmoqda...' : 'Tekshirish',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                ),
              ),
              const SizedBox(height: 32),

              // Result Card
              if (_resultText.isNotEmpty)
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (_scanResult.isNotEmpty) ...[
                          // Risk Indicator
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            decoration: BoxDecoration(
                              color: _scanResult['risk_level'] == 'XAVFSIZ'
                                  ? Colors.green
                                  : _scanResult['risk_level'] == 'SHUBHALI'
                                      ? Colors.orange
                                      : Colors.red,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              _scanResult['risk_level'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          _resultText,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            fontFamily: 'monospace',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_scanResult.containsKey('vt_link')) ...[
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () => _launchVT(_scanResult['vt_link']),
                            icon: const Icon(Icons.open_in_browser),
                            label: const Text('VirusTotal sahifasini ochish'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
