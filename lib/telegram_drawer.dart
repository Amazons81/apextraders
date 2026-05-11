import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'information_page.dart';
import 'main.dart';

// ─── Design Tokens (aligned with your current theme) ─────────────────────────
const Color kNavy      = Color(0xFF050E1F);
const Color kCard      = Color(0xFF0A1628);
const Color kCardLight = Color(0xFF0F1E36);
const Color kBlue      = Color(0xFF1A6FD8);
const Color kCyan      = Color(0xFF00D4FF);
const Color kWhite     = Colors.white;
const Color kMuted     = Color(0xFF607D9A); // Your primary theme color
const Color kDivider   = Color(0xFF1A2C45);

// ─── Typography Helpers ──────────────────────────────────────────────────────
TextStyle _display({double size = 14, FontWeight weight = FontWeight.w700, Color color = kWhite}) =>
    GoogleFonts.barlow(fontSize: size, fontWeight: weight, color: color);

TextStyle _body({double size = 13, FontWeight weight = FontWeight.w400, Color color = kWhite}) =>
    GoogleFonts.dmSans(fontSize: size, fontWeight: weight, color: color);

class TelegramDrawer extends StatelessWidget {
  final UserData user;
  final String currencySymbol;
  final double exchangeRate;
  final Color primaryBlue;
  final Color deepBlue;

  const TelegramDrawer({
    super.key,
    required this.user,
    required this.currencySymbol,
    required this.exchangeRate,
    required this.primaryBlue,
    required this.deepBlue,
  });

  String _formatPrice(double amount) =>
      "$currencySymbol ${(amount * exchangeRate).toStringAsFixed(2)}";

  @override
  Widget build(BuildContext context) {
    final double bundleKesAmount = 1935.0;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.88,
      backgroundColor: kNavy, // Enriched background
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                _buildSectionTitle("EXCLUSIVE BENEFITS"),
                const SizedBox(height: 16),
                _buildBenefitItem(Icons.bolt_rounded, "Daily Sniper Setups", "High-probability entries shared daily."),
                _buildBenefitItem(Icons.groups_rounded, "Private Community", "Chat and learn with 5,000+ active traders."),
                _buildBenefitItem(Icons.verified_user_rounded, "Lifetime Access", "One-time payment, no monthly fees."),
                const SizedBox(height: 30),
                _buildPriceSummary(bundleKesAmount),
              ],
            ),
          ),
          _buildCheckoutButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        color: kCard,
        border: Border(bottom: BorderSide(color: kDivider, width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kMuted.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kMuted.withOpacity(0.3)),
            ),
            child: const Icon(Icons.telegram, color: kCyan, size: 32),
          ),
          const SizedBox(height: 20),
          Text("VIP ELITE BUNDLE",
              style: _display(size: 22, weight: FontWeight.w900, color: kWhite)),
          const SizedBox(height: 4),
          Text("Trade X Indicator + VIP Telegram Access",
              style: _body(size: 13, color: kMuted)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: _display(size: 11, weight: FontWeight.w800, color: kMuted.withOpacity(0.7)));
  }

  Widget _buildBenefitItem(IconData icon, String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kDivider),
      ),
      child: Row(
        children: [
          Icon(icon, color: kCyan, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _display(size: 14, color: kWhite)),
                Text(sub, style: _body(size: 11, color: kMuted)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPriceSummary(double amount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kMuted.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Bundle Value", style: _body(color: kMuted)),
              Text(_formatPrice(amount), style: _display(color: kWhite)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: kDivider, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Payable", style: _display(size: 16, color: kWhite)),
              Text(_formatPrice(amount),
                  style: _display(size: 22, color: kCyan, weight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }




  Widget _buildCheckoutButton(BuildContext context) {
    final double bundleKesAmount = 1935.0;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
          color: kCard,
          border: Border(top: BorderSide(color: kDivider)),
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InformationPage(
                  price: _formatPrice(bundleKesAmount), // ← was hardcoded "KSh 1,945.00"
                  kshAmount: bundleKesAmount,            // ← always KES for STK push
                  productName: "TradeXVIP",
                  initialUser: user,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kBlue,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 8,
            shadowColor: kBlue.withOpacity(0.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("PROCEED TO PAYMENT",
                  style: _display(size: 14, weight: FontWeight.w800)),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }



}