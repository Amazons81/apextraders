import 'package:flutter/material.dart';
import 'dart:async';
import 'SuccessDownloadPage.dart';

// --- Theme Constants (Matching your other pages) ---
const Color kNavy      = Color(0xFF050E1F);
const Color kCard      = Color(0xFF0A1628);
const Color kCardLight = Color(0xFF0F1E36);
const Color kCyan      = Color(0xFF00D4FF);
const Color kWhite     = Colors.white;
const Color kMuted     = Color(0xFF607D9A);
const Color kGreen     = Color(0xFF00E676);
const Color kDivider   = Color(0xFF1A2C45);

class PaymentProcessingPage extends StatefulWidget {
  final String externalReference;
  final String userName;
  final String userEmail;

  const PaymentProcessingPage({
    super.key,
    required this.externalReference,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<PaymentProcessingPage> createState() => _PaymentProcessingPageState();
}

class _PaymentProcessingPageState extends State<PaymentProcessingPage> {
  Timer? _timer;
  Timer? _statusTimer;
  int _secondsRemaining = 80;
  int _statusIndex = 0;

  final List<String> _statusMessages = [
    "Initializing secure connection...",
    "Waiting for M-Pesa response...",
    "Verifying transaction details...",
    "Processing Trade X Indicator files...",
    "Finalizing your Trade X Indicator setup...",
    "Redirecting to download page..."
  ];

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _startStatusRotation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _statusTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        _navigateToSuccess();
      } else {
        if (mounted) setState(() => _secondsRemaining--);
      }
    });
  }

  void _startStatusRotation() {
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _statusIndex < _statusMessages.length - 1) {
        setState(() => _statusIndex++);
      }
    });
  }

  void _navigateToSuccess() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessDownloadPage(
            userName: widget.userName,
            userEmail: widget.userEmail,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavy,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. MAIN PROCESSING CARD
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: kCyan.withOpacity(0.2), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: kCyan.withOpacity(0.05),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 2. ANIMATED LOADER SECTION
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 100, width: 100,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(kCyan.withOpacity(0.1)),
                            ),
                          ),
                          SizedBox(
                            height: 80, width: 80,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              strokeCap: StrokeCap.round,
                              valueColor: const AlwaysStoppedAnimation<Color>(kCyan),
                            ),
                          ),
                          const Icon(Icons.security_rounded, size: 32, color: kCyan),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // 3. TEXT SECTION
                      const Text(
                        "Processing Payment",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: kWhite,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Dynamic status text
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          _statusMessages[_statusIndex],
                          key: ValueKey<String>(_statusMessages[_statusIndex]),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: kMuted,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      const Divider(color: kDivider, thickness: 1),
                      const SizedBox(height: 24),

                      // 4. INSTRUCTION NOTE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 18, color: kCyan),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Please keep this window open while we verify your transaction.",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 12,
                                color: kMuted.withOpacity(0.8),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // 5. BOTTOM SECURITY BRANDING
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_user_rounded, size: 16, color: kGreen),
                        const SizedBox(width: 8),
                        Text(
                          "SECURE 256-BIT ENCRYPTION",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: kGreen.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Automated verification in progress...",
                      style: TextStyle(color: kMuted.withOpacity(0.5), fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}