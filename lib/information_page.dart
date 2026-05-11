//here is the page with implementation. how do i hide stripe keys so that i can push on git?
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';


import 'PaymentProcessingPage.dart';
import 'main.dart';

import 'config/app_secrets.dart';


// ─── Design Tokens ────────────────────────────────────────────────────────────
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

// ─── Typography helpers ───────────────────────────────────────────────────────
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

// ─── Glow card decoration ─────────────────────────────────────────────────────
BoxDecoration _glowCard({
  Color border = kBlue,
  double glowIntensity = 0.22,
  BorderRadius? radius,
}) =>
    BoxDecoration(
      color: kCard,
      borderRadius: radius ?? BorderRadius.circular(20),
      border: Border.all(color: border.withOpacity(0.35), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: border.withOpacity(glowIntensity),
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ],
    );

// ─── InformationPage ──────────────────────────────────────────────────────────
class InformationPage extends StatefulWidget {
  final String price;
  final double kshAmount;
  final UserData initialUser;
  final String productName;

  const InformationPage({
    super.key,
    required this.price,
    required this.kshAmount,
    required this.initialUser,
    this.productName = "Trade X Indicator",
  });

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage>
    with SingleTickerProviderStateMixin {

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController mpesaController;

  bool _isLoading        = false;
  bool _isCardLoading    = false;
  String _selectedMethod = 'Mpesa';

  // Paystack keys

  // Animated glow for pay button
  late AnimationController _pulseController;
  late Animation<double>   _pulseAnimation;

  @override
  void initState() {
    super.initState();
    nameController  = TextEditingController(text: widget.initialUser.fullName);
    emailController = TextEditingController(text: widget.initialUser.email);
    mpesaController = TextEditingController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mpesaController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ── Paystack Card Payment ──────────────────────────────────────
  Future<void> _chargeCard() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _snack("Please enter a valid email address first.", isError: true);
      return;
    }

    setState(() => _isCardLoading = true);

    final String reference =
        'TRADEX_${DateTime.now().millisecondsSinceEpoch}';
    final int amountInKobo = (widget.kshAmount * 100).round();

    try {
      await FlutterPaystackPlus.openPaystackPopup(
        context:       context,

        secretKey: AppSecrets.paystackSecretKey,

        customerEmail: email,
        reference:     reference,
        amount:        amountInKobo.toString(),
        currency:      'KES',
        callBackUrl:   'https://plays-ruby.vercel.app/api/callback',
        metadata: {
          'name':    nameController.text.trim(),
          'product': widget.productName,
        },
        onSuccess: () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentProcessingPage(
                  externalReference: reference,
                  userName:          nameController.text.trim(),
                  userEmail:         email,
                ),
              ),
            );
          }
        },
        onClosed: () => _snack("Card payment cancelled.", isError: true),
      );
    } catch (e) {
      _snack("Card payment error: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isCardLoading = false);
    }
  }

  // ── STK Push ──────────────────────────────────────────────────
  Future<void> triggerStkPush() async {
    final phone = mpesaController.text.trim();
    if (phone.isEmpty || phone.length < 9) {
      _snack("Invalid M-Pesa number. Use 07... or 254...", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    const String apiUrl     = "https://backend.payhero.co.ke/api/v2/payments";


    final String authHeader = AppSecrets.payHeroAuth;

    final int    amountToSend = widget.kshAmount.round();
    final bool   isVip        = widget.productName.toLowerCase().contains("vip");
    final String accountRef   = isVip ? "TradeXVIP" : "Indicator";
    final String txnDesc      = isVip ? "TradeXVIP" : "Indicator";

    String formattedPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '254${formattedPhone.substring(1)}';
    } else if (formattedPhone.startsWith('7') || formattedPhone.startsWith('1')) {
      formattedPhone = '254$formattedPhone';
    }

    final Map<String, dynamic> body = {
      "amount":                  amountToSend,
      "phone_number":            formattedPhone,
      "channel_id":              6385,
      "provider":                "m-pesa",
      "external_reference":      "${DateTime.now().millisecondsSinceEpoch}",
      "callback_url":            "https://plays-ruby.vercel.app/api/callback",
      "account_reference":       accountRef,
      "transaction_description": txnDesc,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type":  "application/json",
          "Accept":        "application/json",
          "Authorization": authHeader,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentProcessingPage(
                externalReference: body["external_reference"],
                userName:  nameController.text.trim(),
                userEmail: emailController.text.trim(),
              ),
            ),
          );
        }
      } else {
        final err = jsonDecode(response.body);
        _snack(err['message'] ?? "Payment failed. Try again.", isError: true);
      }
    } catch (e) {
      _snack("Connection error: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: _body(size: 13, color: kWhite)),
      backgroundColor: isError ? kRed : kBlue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavy,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            _buildProgressIndicator(),
            _buildOrderSummaryCard(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _sectionLabel("CONTACT DETAILS"),
                  const SizedBox(height: 12),
                  _buildContactCard(),
                  const SizedBox(height: 20),

                  // ── CARD PAYMENT SECTION (standalone, above M-Pesa card) ──
                  _sectionLabel("PAY WITH CARD"),
                  const SizedBox(height: 12),
                  _buildCardPaymentSection(),
                  const SizedBox(height: 20),

                  // ── MOBILE MONEY SECTION ──
                  _sectionLabel("OTHER PAYMENT METHOD"),
                  const SizedBox(height: 12),
                  _buildPaymentCard(),
                  const SizedBox(height: 28),
                  _buildPayButton(),
                  const SizedBox(height: 16),
                  _buildSecurityNotice(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kCard,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: kDivider),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: kCyan, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline_rounded, color: kGold, size: 16),
          const SizedBox(width: 8),
          Text("Payment Details",
              style: _display(size: 16, color: kWhite, weight: FontWeight.w800, spacing: 0.5)),
        ],
      ),
    );
  }

  // ─── Progress stepper ─────────────────────────────────────────
  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: _glowCard(border: kBlue, radius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stepDot(true,  "Registration"),
              _stepLine(true),
              _stepDot(true,  "Confirmation"),
              _stepLine(false),
              _stepDot(false, "Checkout"),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: kCyan.withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: kCyan.withOpacity(0.3)),
            ),
            child: Text(
              "AI-powered signals for MT5. No guesswork. Clear entries & exits.",
              textAlign: TextAlign.center,
              style: _body(size: 12, color: kCyan),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDot(bool active, String label) => Column(children: [
    Container(
      width: 22, height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? kCyan : kDivider,
        boxShadow: active
            ? [BoxShadow(color: kCyan.withOpacity(0.4), blurRadius: 8)]
            : [],
      ),
      child: Icon(Icons.check, size: 12, color: active ? kNavy : kMuted),
    ),
    const SizedBox(height: 5),
    Text(label, style: _body(size: 9, color: active ? kCyan : kMuted)),
  ]);

  Widget _stepLine(bool active) => Container(
    width: 38, height: 2,
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: active ? kCyan : kDivider,
      borderRadius: BorderRadius.circular(2),
    ),
  );

  // ─── Order Summary ────────────────────────────────────────────
  Widget _buildOrderSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2A5E), Color(0xFF0A1628)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: kCyan.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
              color: kCyan.withOpacity(0.18),
              blurRadius: 28,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kGold.withOpacity(0.4)),
                      ),
                      child: Text("DIGITAL LICENSE",
                          style: _display(
                              size: 9,
                              color: kGold,
                              weight: FontWeight.w800,
                              spacing: 1.2)),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.productName,
                        style: _display(
                            size: 18,
                            color: kWhite,
                            weight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text("Lifetime access ·",
                        style: _body(size: 12, color: kMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(widget.price,
                      style: _display(
                          size: 28, color: kCyan, weight: FontWeight.w900)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: kGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text("67% OFF",
                        style: _display(
                            size: 10,
                            color: kGreen,
                            weight: FontWeight.w800)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: kDivider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _summaryFeature(Icons.bolt_rounded,     "Instant Delivery"),
              _summaryFeature(Icons.all_inclusive,    "Lifetime Access"),
              _summaryFeature(Icons.support_agent,    "24/7 Support"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryFeature(IconData icon, String label) => Column(children: [
    Icon(icon, color: kCyan, size: 20),
    const SizedBox(height: 4),
    Text(label, style: _body(size: 10, color: Colors.white)),
  ]);

  // ─── Contact Card ─────────────────────────────────────────────
  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glowCard(border: kBlue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel("Full Name"),
          _buildTextField(
            "Your full name",
            Icons.person_outline_rounded,
            controller: nameController,
          ),
          const SizedBox(height: 18),
          _fieldLabel("Email Address"),
          _buildTextField(
            "you@email.com",
            Icons.email_outlined,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  // ─── Card Payment Section (standalone, ABOVE M-Pesa card) ─────
  Widget _buildCardPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glowCard(border: kCyan, glowIntensity: 0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Paystack badge + SSL
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C3F7).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF00C3F7).withOpacity(0.45)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.credit_card_rounded,
                        color: Color(0xFF00C3F7), size: 14),
                    const SizedBox(width: 6),
                    Text("Paystack",
                        style: _display(
                            size: 11,
                            color: const Color(0xFF00C3F7),
                            weight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text("Secure card checkout",
                  style: _body(size: 12, color: kMuted)),
              const Spacer(),
              const Icon(Icons.lock_outline_rounded,
                  color: kGreen, size: 14),
              const SizedBox(width: 4),
              Text("SSL", style: _body(size: 10, color: kGreen)),
            ],
          ),

          const SizedBox(height: 16),



          // Pay with card button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _isCardLoading ? null : _chargeCard,
              icon: _isCardLoading
                  ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    color: kWhite, strokeWidth: 2),
              )
                  : const Icon(Icons.credit_card_rounded,
                  color: kWhite, size: 18),
              label: Text(
                _isCardLoading
                    ? "Opening payment..."
                    : "PAY ${widget.price} WITH CARD",
                style: _display(
                    size: 13,
                    color: kWhite,
                    weight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A2E6E),
                disabledBackgroundColor:
                const Color(0xFF0A2E6E).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(
                    color: Color(0xFF00C3F7), width: 1),
                elevation: 0,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Info note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kCyan.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kCyan.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: kCyan, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "You will be redirected to a secure Paystack checkout page to complete your card payment.",
                    style: _body(size: 11, color: kMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardBrand(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(label,
        style: _display(
            size: 9,
            color: color,
            weight: FontWeight.w900,
            spacing: 0.5)),
  );

  // ─── Payment Card (M-Pesa / Airtel + Skrill) ──────────────────
  Widget _buildPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glowCard(border: kBlue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel("Payment Provider"),
          _buildPaymentDropdown(),
          const SizedBox(height: 18),
          _fieldLabel("M-Pesa Number"),
          _buildTextField(
            "07xx xxx xxx",
            Icons.phone_android_outlined,
            controller: mpesaController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),

          // STK Push info note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kGold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kGold.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: kGold, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "An STK push will be sent to your Mpesa number immediately after clicking pay.",
                    style: _body(size: 12, color: kMuted),
                  ),
                ),
              ],
            ),
          ),

          // Skrill / Global Payment
          const SizedBox(height: 16),
          _fieldLabel("SKRILL / GLOBAL PAYMENT"),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: kCardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: kCyan.withOpacity(0.2), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.alternate_email_rounded,
                    color: kCyan, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pay via Skrill to:",
                          style: _body(
                              size: 10,
                              color: kMuted,
                              weight: FontWeight.bold)),
                      Text("amazons7781@gmail.com",
                          style: _display(
                              size: 13,
                              color: kWhite,
                              weight: FontWeight.w600)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(
                        text: "amazons7781@gmail.com"));
                    _snack("Email copied to clipboard!");
                  },
                  icon: const Icon(Icons.copy_rounded,
                      color: kCyan, size: 20),
                  tooltip: "Copy Email",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared text field ────────────────────────────────────────
  Widget _buildTextField(
      String hint,
      IconData icon, {
        TextEditingController? controller,
        TextInputType? keyboardType,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: _body(size: 15, color: kWhite),
      cursorColor: kCyan,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: kCyan, size: 20),
        hintText: hint,
        hintStyle: _body(size: 14, color: kMuted),
        filled: true,
        fillColor: kCardLight,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kDivider, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kCyan, width: 1.8),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 2),
    child: Text(label,
        style: _display(
            size: 11,
            color: kMuted,
            weight: FontWeight.w600,
            spacing: 0.8)),
  );

  // ─── Payment Dropdown ─────────────────────────────────────────
  Widget _buildPaymentDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: kCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kDivider, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMethod,
          isExpanded: true,
          dropdownColor: kCard,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: kCyan),
          style: _body(size: 15, color: kWhite, weight: FontWeight.w500),
          onChanged: (val) => setState(() => _selectedMethod = val!),
          items: ['Mpesa', 'Airtel Money']
              .map((e) => DropdownMenuItem(
            value: e,
            child: Row(
              children: [
                const Icon(Icons.phone_android_outlined,
                    color: kCyan, size: 16),
                const SizedBox(width: 10),
                Text(e),
              ],
            ),
          ))
              .toList(),
        ),
      ),
    );
  }

  // ─── Pay Button (M-Pesa STK Push) ────────────────────────────
  Widget _buildPayButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isLoading
              ? []
              : [
            BoxShadow(
              color: kCyan.withOpacity(
                  _pulseAnimation.value * 0.45),
              blurRadius: 30,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : triggerStkPush,
          style: ElevatedButton.styleFrom(
            backgroundColor: kBlue,
            disabledBackgroundColor: kBlue.withOpacity(0.4),
            minimumSize: const Size(double.infinity, 62),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: _isLoading
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 22, width: 22,
                child: CircularProgressIndicator(
                    color: kCyan, strokeWidth: 2.5),
              ),
              const SizedBox(width: 14),
              Text("Sending STK Push...",
                  style: _display(size: 14, color: kCyan)),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_android_outlined,
                  color: kWhite, size: 18),
              const SizedBox(width: 10),
              Text("CONFIRM AND PAY (M-PESA)",
                  style: _display(
                      size: 15,
                      color: kWhite,
                      weight: FontWeight.w900,
                      spacing: 1.2)),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_rounded,
                  color: kCyan, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Security Notice ──────────────────────────────────────────
  Widget _buildSecurityNotice() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: kGreen.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user_outlined,
                  size: 14, color: kGreen),
            ),
            const SizedBox(width: 8),
            Text("Payments secured by PayHero & Paystack",
                style: _body(
                    size: 12,
                    color: kGreen,
                    weight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          "256-bit SSL encrypted · Your data is safe",
          textAlign: TextAlign.center,
          style: _body(size: 11, color: kMuted),
        ),
      ],
    );
  }

  // ─── Section label ────────────────────────────────────────────
  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 2),
    child: Text(
      text,
      style: _display(
          size: 11,
          color: kCyan,
          weight: FontWeight.w800,
          spacing: 2),
    ),
  );
}