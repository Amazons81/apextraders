//lets change the backround to white. do not chnag eanything else
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../information_page.dart';
import 'homepage.dart';

// ─── Design Tokens (mirrors home_page.dart) ───────────────────────────────────
const Color kNavy      = Color(0xFF050E1F);
const Color kCard      = Color(0xFF0A1628);
const Color kCardLight = Color(0xFF0F1E36);
const Color kBlue      = Color(0xFF1A6FD8);
const Color kCyan      = Color(0xFF00D4FF);
const Color kGold      = Color(0xFFFFBE00);
const Color kGreen     = Color(0xFF00E676);
const Color kRed       = Color(0xFFFF5252);
const Color kWhite     = Colors.white;
const Color kMuted     = Color(0xFF607D9A);
const Color kDivider   = Color(0xFF1A2C45);

// ─── Typography ───────────────────────────────────────────────────────────────
TextStyle _display({
  double size = 14,
  FontWeight weight = FontWeight.w700,
  Color color = kWhite,
  double spacing = 0,
}) =>
    GoogleFonts.barlow(
        fontSize: size, fontWeight: weight, color: color, letterSpacing: spacing);

TextStyle _body({
  double size = 13,
  FontWeight weight = FontWeight.w400,
  Color color = kWhite,
}) =>
    GoogleFonts.dmSans(fontSize: size, fontWeight: weight, color: color);

// ─── Glow decoration ──────────────────────────────────────────────────────────
BoxDecoration _glowCard({
  Color border = kBlue,
  double glowIntensity = 0.22,
  BorderRadius? radius,
}) =>
    BoxDecoration(
      color: kCard,
      borderRadius: radius ?? BorderRadius.circular(16),
      border: Border.all(color: border.withOpacity(0.35), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: border.withOpacity(glowIntensity),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );

// ─── OrderSummaryDrawer ───────────────────────────────────────────────────────
class OrderSummaryDrawer extends StatelessWidget {
  final UserData user;
  final String selectedCurrency;
  final double exchangeRate;
  final String currencySymbol;
  final Color primaryBlue;
  final Color deepBlue;

  const OrderSummaryDrawer({
    super.key,
    required this.user,
    required this.selectedCurrency,
    required this.exchangeRate,
    required this.currencySymbol,
    required this.primaryBlue,
    required this.deepBlue,
  });

  String _formatPrice(double amount) =>
      "$currencySymbol ${(amount * exchangeRate).toStringAsFixed(2)}";

  void _goHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomePage(user: user)),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const double basePrice     = 1290.0;
    const double originalPrice = 3870.0;
    final String formattedTotal = _formatPrice(basePrice);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome(context);
      },
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.88,
        backgroundColor: kNavy,
        child: Column(
          children: [
            _buildHeader(context),
            Divider(color: kDivider, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildProductCard(context, originalPrice),
                  const SizedBox(height: 16),
                  _buildPromoNote(),
                  const SizedBox(height: 14),
                  _buildIncludesNote(),
                  const SizedBox(height: 16),
                  _buildFeatureStrip(),
                ],
              ),
            ),
            _buildCheckoutSection(context, formattedTotal),
          ],
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 8,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: kCard,
        border: Border(bottom: BorderSide(color: kDivider)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kBlue.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: kBlue.withOpacity(0.4)),
            ),
            child: const Icon(Icons.receipt_long_outlined, color: kCyan, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Order Summary",
                  style: _display(size: 16, color: kWhite, weight: FontWeight.w800)),
              Text("Review before checkout",
                  style: _body(size: 11, color: kMuted)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: kMuted, size: 24),
            onPressed: () => _goHome(context),
          ),
        ],
      ),
    );
  }

  // ─── Product Card ────────────────────────────────────────────────
  Widget _buildProductCard(BuildContext context, double originalPrice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glowCard(border: kCyan, glowIntensity: 0.15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: kCardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kDivider),
              ),
              child: Image.asset(
                'assets/images/one.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Center(child: Icon(Icons.analytics_outlined, color: kCyan, size: 36)),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kGold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: kGold.withOpacity(0.35)),
                  ),
                  child: Text("LIFETIME LICENSE",
                      style: _display(size: 8, color: kGold, weight: FontWeight.w800, spacing: 1)),
                ),
                const SizedBox(height: 7),
                Text("Trade X Indicator",
                    style: _display(size: 16, color: kWhite, weight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text("MetaTrader 5 · Lifetime Access",
                    style: _body(size: 11, color: kMuted)),
                const SizedBox(height: 12),
                // Price row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,

                  children: [
                    Text(_formatPrice(1290.0),
                        style: _display(size: 18, color: kCyan, weight: FontWeight.w900)),
                    const SizedBox(width: 8),

                    Text(
                      _formatPrice(originalPrice),
                      style: _body(size: 10, color: kMuted).copyWith(
                        decoration: TextDecoration.lineThrough,
                        decorationColor: kMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Promo Note ──────────────────────────────────────────────────
  Widget _buildPromoNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer_outlined, color: kGreen, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "67% Early Bird Discount Applied 🎉",
              style: _body(size: 13, color: kGreen, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Includes Note ───────────────────────────────────────────────
  Widget _buildIncludesNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBlue.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBlue.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: kCyan, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Your purchase includes the Trade X Indicator and a secure password for activation.",
              style: _body(size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Feature Strip ───────────────────────────────────────────────
  Widget _buildFeatureStrip() {
    final features = [
      (Icons.bolt_rounded,        "Instant\nDelivery"),
      (Icons.all_inclusive,       "Lifetime\nAccess"),
      (Icons.support_agent,       "24/7\nSupport"),
      (Icons.workspace_premium,   "90%\nAccuracy"),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: _glowCard(border: kBlue, glowIntensity: 0.12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: features.map((f) => Column(
          children: [
            Icon(f.$1, color: kCyan, size: 22),
            const SizedBox(height: 6),
            Text(f.$2,
                textAlign: TextAlign.center,
                style: _body(size: 10, color: Colors.white)),
          ],
        )).toList(),
      ),
    );
  }

  // ─── Checkout Section ────────────────────────────────────────────
  Widget _buildCheckoutSection(BuildContext context, String formattedTotal) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
          color: kCard,
          border: Border(top: BorderSide(color: kDivider)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Total row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Payable",
                        style: _body(size: 12, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text("Tax included · One-time payment",
                        style: _body(size: 10, color: Colors.white.withOpacity(0.6))),
                  ],
                ),
                Text(formattedTotal,
                    style: _display(size: 24, color: kCyan, weight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 16),
            // Checkout button with glow
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: kBlue.withOpacity(0.45),
                    blurRadius: 22,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InformationPage(
                        price: "KSh 1,290.00",
                        kshAmount: 1290.0,
                        productName: "Indicator",
                        initialUser: user,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline_rounded, color: kWhite, size: 16),
                    const SizedBox(width: 10),
                    Text("CHECKOUT",
                        style: _display(size: 14, color: kWhite, weight: FontWeight.w900, spacing: 1.5)),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_ios_rounded, color: kCyan, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Security badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: kGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_outlined, size: 12, color: kGreen),
                ),
                const SizedBox(width: 6),
                Text("Secured by PayHero · 256-bit SSL",
                    style: _body(size: 11, color: kMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}