import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
const Color kFundBg      = Color(0xFF0B0E11);
const Color kFundSurface = Color(0xFF1A1D21);
const Color kFundAccent  = Color(0xFF26D7D7);
const Color kFundSlate   = Color(0xFF8E97A4);
const Color kFundWhite   = Colors.white;

class FundPage extends StatefulWidget {
  const FundPage({super.key});

  @override
  State<FundPage> createState() => _FundPageState();
}

class _FundPageState extends State<FundPage> {
  String selectedSize = "\$10K";
  String selectedPlatform = "MetaTrader 5";

  final List<String> sizes = ["\$5K", "\$10K", "\$25K", "\$50K", "\$100K", "\$200K", "\$250K"];
  final List<String> platforms = ["MetaTrader 5", "cTrader", "MatchTrade", "TradeLocker"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFundBg,
      appBar: AppBar(
        backgroundColor: kFundBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kFundWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("FUNDED ACCOUNT", style: _headerStyle(size: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ── Account Size ──
            _sectionLabel("ACCOUNT SIZE"),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: sizes.map((size) => _buildSelectableBox(
                label: size,
                isSelected: selectedSize == size,
                onTap: () => setState(() => selectedSize = size),
                width: (MediaQuery.of(context).size.width - 70) / 4,
              )).toList(),
            ),

            const SizedBox(height: 32),

            // ── Plan Features ──
            _sectionLabel("PLAN FEATURES"),
            const SizedBox(height: 16),
            _buildFeatureTable(),

            const SizedBox(height: 32),

            // ── Consistency & Fee ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel("CONSISTENCY SCORE"),
                      const SizedBox(height: 12),
                      _buildStatusRow("Evaluation Phase", "Yes"),
                      _buildStatusRow("Simulated Funded", "Yes"),
                    ],
                  ),
                ),
                _buildFeeDisplay(),
              ],
            ),

            const SizedBox(height: 32),

            // ── Trading Platform ──
            _sectionLabel("TRADING PLATFORM"),
            const SizedBox(height: 16),
            _buildWarningBox(),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.8,
              ),
              itemCount: platforms.length,
              itemBuilder: (context, index) => _buildSelectableBox(
                label: platforms[index],
                isSelected: selectedPlatform == platforms[index],
                onTap: () => setState(() => selectedPlatform = platforms[index]),
              ),
            ),

            const SizedBox(height: 40),

            // ── Proceed Button ──
            _buildProceedButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets ──────────────────────────────────────────────────────────

  TextStyle _headerStyle({double size = 12}) => GoogleFonts.inter(
    fontSize: size, fontWeight: FontWeight.w900, color: kFundAccent, letterSpacing: 1.5,
  );

  Widget _sectionLabel(String text) => Text(text, style: _headerStyle());

  Widget _buildSelectableBox({required String label, required bool isSelected, required VoidCallback onTap, double? width}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: kFundSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? kFundAccent : Colors.transparent, width: 2),
          boxShadow: [if (isSelected) BoxShadow(color: kFundAccent.withOpacity(0.2), blurRadius: 10)],
        ),
        child: Center(
          child: Text(label, style: GoogleFonts.inter(color: kFundWhite, fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildFeatureTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kFundSurface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _featureRow("Profit Target", "10%"),
          const Divider(color: Colors.white10),
          _featureRow("Max Overall Drawdown", "6%"),
          const Divider(color: Colors.white10),
          _featureRow("Max Daily Drawdown", "4%"),
          const Divider(color: Colors.white10),
          _featureRow("Profit Split", "Up to 90%"),
        ],
      ),
    );
  }

  Widget _featureRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.inter(color: kFundSlate, fontSize: 13)),
          const SizedBox(width: 6),
          const Icon(Icons.info_outline, color: kFundSlate, size: 14),
          const Spacer(),
          Text(value, style: GoogleFonts.inter(color: kFundWhite, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: GoogleFonts.inter(color: kFundSlate, fontSize: 12)),
          Text(status, style: GoogleFonts.inter(color: kFundWhite, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFeeDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("\$58", style: GoogleFonts.inter(color: kFundSlate, decoration: TextDecoration.lineThrough, fontSize: 16)),
        Text("\$24", style: GoogleFonts.inter(color: kFundAccent, fontWeight: FontWeight.w900, fontSize: 32)),
      ],
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.orange.withOpacity(0.2))),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
          const SizedBox(width: 12),
          const Expanded(child: Text("MetaTrader 5 and cTrader are not available for USA residents", style: TextStyle(color: kFundSlate, fontSize: 11))),
        ],
      ),
    );
  }

  Widget _buildProceedButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kFundAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 8,
          shadowColor: kFundAccent.withOpacity(0.4),
        ),
        onPressed: () {
          // Pops the page and tells the HomePage to jump to activation
          Navigator.pop(context, "jump_to_activation");
        },
        child: Text("PROCEED", style: GoogleFonts.inter(color: kFundBg, fontWeight: FontWeight.w900, fontSize: 15)),
      ),
    );
  }
}