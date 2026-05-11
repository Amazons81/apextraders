import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Ensure this is in your pubspec.yaml

class SearchDrawer extends StatelessWidget {
  final Color primaryBlue;
  final Color deepBlue;

  final VoidCallback onInstallationClick;
  final VoidCallback onMakePaymentsClick;
  final VoidCallback onYourOrderClick;

  const SearchDrawer({
    super.key,
    required this.primaryBlue,
    required this.deepBlue,
    required this.onInstallationClick,
    required this.onMakePaymentsClick,
    required this.onYourOrderClick,
  });

  // Helper function to launch WhatsApp
  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/14482035533");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch WhatsApp link");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FBFE),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Elegant Header
          Container(
            padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, deepBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Quick Search",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const Text(
                  "Find exactly what you need in Trade X Indicator",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Suggestions List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                _buildSearchOption(
                  context,
                  Icons.auto_awesome_rounded,
                  "Installation guide?",
                  "Step-by-step setup for MT5",
                  onInstallationClick,
                ),
                const SizedBox(height: 10),
                _buildSearchOption(
                  context,
                  Icons.account_balance_wallet_rounded,
                  "Make payments?",
                  "Instant M-Pesa STK push & checkout",
                  onMakePaymentsClick,
                ),
                const SizedBox(height: 10),
                _buildSearchOption(
                  context,
                  Icons.local_mall_rounded,
                  "Your order?",
                  "View items currently in your cart",
                  onYourOrderClick,
                ),
                const SizedBox(height: 10),
                // NEW WHATSAPP OPTION
                _buildSearchOption(
                  context,
                  Icons.forum_rounded,
                  "Completed payment?",
                  "Chat with us on WhatsApp for support",
                      () => _launchWhatsApp(),
                ),
              ],
            ),
          ),

          // Footer
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: deepBlue.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "DISMISS",
                    style: TextStyle(
                      color: deepBlue,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchOption(BuildContext context, IconData icon, String title, String subtitle, VoidCallback action) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: deepBlue, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3142)),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: () {
          Navigator.pop(context);
          action();
        },
      ),
    );
  }
}