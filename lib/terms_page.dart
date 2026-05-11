//adjust it such that I UNDERSTAND & AGREE button is not hidden by bottom navigation buttons
import 'package:flutter/material.dart';
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  final Color primaryBlue = const Color(0xFF00B4DB);
  final Color deepBlue = const Color(0xFF0083B0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "TERMS & CONDITIONS",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header Accent
          Container(
            height: 5,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryBlue, deepBlue]),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("1. Introduction"),
                  _buildSectionBody(
                      "Welcome to Trade X Indicator. By purchasing and using the Trade X Indicator, you agree to comply with and be bound by the following terms and conditions. Please read them carefully before completing your purchase."
                  ),

                  _buildSectionTitle("2. No Financial Advice"),
                  _buildSectionBody(
                      "The Trade X Indicator is a technical analysis tool designed to assist in market evaluation. It does NOT constitute financial, investment, or trading advice. All trading decisions are made at the user's own risk."
                  ),

                  _buildSectionTitle("3. Risk Warning"),
                  _buildSectionBody(
                      "Trading Forex, Cryptocurrencies, and Indices involves significant risk. Past performance of this indicator is not indicative of future results. You should only invest money that you can afford to lose."
                  ),

                  _buildSectionTitle("4. License and Usage"),
                  _buildSectionBody(
                      "Upon successful payment, you are granted a non-exclusive, non-transferable license to use the Trade X Indicator. Redistribution, reselling, or sharing of the files and extraction passwords is strictly prohibited and will result in license termination."
                  ),

                  _buildSectionTitle("5. Refund Policy"),
                  _buildSectionBody(
                      "Due to the digital nature of the Trade X Indicator (software files), all sales are final. Once the download link and extraction password have been issued to your email, we do not offer refunds or exchanges."
                  ),

                  _buildSectionTitle("6. Limitation of Liability"),
                  _buildSectionBody(
                      "Trade X Indicator and Apex Markets Shop shall not be held liable for any financial losses, damages, or emotional distress resulting from the use or inability to use the indicator."
                  ),

                  _buildSectionTitle("7. Intellectual Property"),
                  _buildSectionBody(
                      "All algorithms, graphics, and documentation related to Trade X Indicator are the intellectual property of Apex Markets Shop. Unauthorized copying or reverse engineering is illegal."
                  ),

                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      "Last Updated: April 2024",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom Close Button
// Bottom Close Button
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "I UNDERSTAND & AGREE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: deepBlue,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSectionBody(String text) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
        height: 1.6,
        fontWeight: FontWeight.w300,
      ),
    );
  }
}