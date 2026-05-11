
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_x_indicator/swipeable_hero.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';
import 'dart:async';
import 'dart:io';
import 'fundpage.dart';
import 'information_page.dart';
import 'main.dart';
import 'flipping_feature_grid.dart';
import 'search_drawer.dart';
import 'order_summary_drawer.dart';
import 'telegram_drawer.dart';
import 'download_helper.dart';
import 'dart:math'; // Required for Random()

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color kNavy      = Color(0xFF050E1F);
const Color kCard      = Color(0xFF0A1628);
const Color kCardLight = Color(0xFF0F1E36);
const Color kBlue      = Color(0xFF1A6FD8);
const Color kCyan      = Color(0xFF00D4FF);
const Color kGold      = Color(0xFFFFBE00);
const Color kGreen     = Color(0xFF00E676);
const Color kRed       = Color(0xFFFF5252);
const Color kTelegram  = Color(0xFF0088CC);
const Color kWhite     = Colors.white;
const Color kMuted     = Color(0xFF607D9A);
const Color kDivider   = Color(0xFF1A2C45);

// ─── Typography ───────────────────────────────────────────────────────────────
TextStyle _displayFont({
  double size = 14,
  FontWeight weight = FontWeight.w700,
  Color color = kWhite,
  double spacing = 0,
}) =>
    GoogleFonts.barlow(
        fontSize: size, fontWeight: weight, color: color, letterSpacing: spacing);

TextStyle _bodyFont({
  double size = 13,
  FontWeight weight = FontWeight.w400,
  Color color = kWhite,
}) =>
    GoogleFonts.dmSans(fontSize: size, fontWeight: weight, color: color);

// ─── Glow Card ────────────────────────────────────────────────────────────────
BoxDecoration _glowCard({
  Color border = kBlue,
  double glowIntensity = 0.25,
  BorderRadius? radius,
}) =>
    BoxDecoration(
      color: kCard,
      borderRadius: radius ?? BorderRadius.circular(20),
      border: Border.all(color: border.withOpacity(0.4), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: border.withOpacity(glowIntensity),
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ],
    );

// ─── HomePage ─────────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  final UserData user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  // ── Pricing ────────────────────────────────────────────────────
  final double basePriceStandard = 1290.0;
  final double basePriceVIP      = 1935.0;
  final double oldPriceStandard  = 3870.0;
  final double oldPriceVIP       = 4515.0;

  final int _totalSignals = 1247;
  final int _winCount     = 1121;

  final GlobalKey _activateKey = GlobalKey();
  double _activateScale = 1.0;


  // ── Currency ───────────────────────────────────────────────────
  final List<Map<String, dynamic>> _currencies = [
    {"country": "🇰🇪", "code": "KES", "symbol": "KSh", "rate": 1.0},
    {"country": "🇺🇸", "code": "USD", "symbol": "\$",   "rate": 0.0077},

    {"country": "🇿🇦", "code": "ZAR", "symbol": "R",    "rate": 0.14},

    {"country": "🇳🇬", "code": "NGN", "symbol": "₦",    "rate": 12.5},
    {"country": "🇬🇭", "code": "GHS", "symbol": "₵",    "rate": 0.11},
    {"country": "🇨🇦", "code": "CAD", "symbol": "CA\$", "rate": 0.011},
    {"country": "🇦🇺", "code": "AUD", "symbol": "A\$",  "rate": 0.012},
    {"country": "🇩🇪", "code": "EUR", "symbol": "€",    "rate": 0.0071},
    {"country": "🇬🇧", "code": "GBP", "symbol": "£",    "rate": 0.006},
    {"country": "🇹🇿", "code": "TZS", "symbol": "TSh",  "rate": 20.3},
    {"country": "🇺🇬", "code": "UGX", "symbol": "USh",  "rate": 28.5},
    {"country": "🇮🇳", "code": "INR", "symbol": "₹",    "rate": 0.64},
  ];

  Map<String, dynamic> _selectedCurrency = {
    "country": "🇰🇪", "code": "KES", "symbol": "KSh", "rate": 1.0
  };

  // ── State ──────────────────────────────────────────────────────
  final GlobalKey<ScaffoldState> _scaffoldKey    = GlobalKey<ScaffoldState>();
  final GlobalKey                _installKey     = GlobalKey();
  final ScrollController         _scrollController = ScrollController();

  Timer?   _timer;
  Duration _duration = const Duration(hours: 2, minutes: 14, seconds: 33);

  Timer? _lastSignalTimer;
  int _minutesAgo = Random().nextInt(3) + 1;




  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  bool _isMuted            = true;
  bool _isReviewsExpanded  = false;

  final List<Map<String, dynamic>> _tickerItems = [
    {"pair": "EUR/USD", "price": "1.0847", "change": "+0.12%", "up": true},
    {"pair": "GBP/USD", "price": "1.2643", "change": "-0.08%", "up": false},
    {"pair": "XAU/USD", "price": "2,312.5","change": "+0.34%", "up": true},
    {"pair": "BTC/USD", "price": "67,420", "change": "+1.22%", "up": true},
    {"pair": "USD/JPY", "price": "154.23", "change": "-0.21%", "up": false},
    {"pair": "NAS100",  "price": "18,240", "change": "+0.45%", "up": true},
  ];

  final List<Map<String, dynamic>> _userReviews = [
    {"name": "mercieamelia@gmail.com",        "comment": "i bought the indicator only,how can i join telegram. do i also pay?", "stars": 5},
    {"name": "markeva0194@gmail.com",         "comment": "The accuracy is impressive.",                                          "stars": 5},
    {"name": "gabriellelelaurent@gmail.com",  "comment": "I like the real-time alerts feature.",                                 "stars": 4},
    {"name": "amos2014musyoka@gmail.com",     "comment": "Huge thanks guys. I flipped 500USD to 4000",                           "stars": 5},
    {"name": "emilywilson@gmail.com",         "comment": "Definitely worth it, great performance.",                              "stars": 5},
    {"name": "dunskylak@gmail.com",           "comment": "Best trading tool",                                                    "stars": 4},
    {"name": "ianbcollins@gmail.com",         "comment": "Game changer",                                                         "stars": 5},
    {"name": "arapexjmwangi92@gmail.com",     "comment": "Super easy to use and reliable signals.",                              "stars": 5},
    {"name": "brianstoic23@gmail.com",        "comment": "Nice one!",                                                            "stars": 5},
    {"name": "julianst05claire@gmail.com",    "comment": "Makes market analysis much simpler.",                                  "stars": 4},
    {"name": "emaxikiprop@gmail.com",       "comment": "so far, i'm finally seeing some importance",                           "stars": 5},
    {"name": "danieljosh@gmail.com",          "comment": "Consistent results over the past few weeks.",                          "stars": 5},
    {"name": "oliver4040@gmail.com",   "comment": "Very helpful in catching early entries.",                              "stars": 3},
  ];




  @override
  void initState() {
    super.initState();

    // 1. Auto-set currency from registration country
    _initializeCurrency();

    // 2. Video Controller Setup
    _videoController = VideoPlayerController.asset('assets/images/three.mp4')
      ..initialize().then((_) {
        if (mounted) setState(() => _isVideoInitialized = true);
        _videoController.setLooping(false);
        _videoController.setVolume(0.0);
        _videoController.addListener(_videoLoopListener);
        _videoController.play();
      });

    // 3. Main Countdown Timer (1 second intervals)
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _duration = _duration.inSeconds > 0
            ? _duration - const Duration(seconds: 1)
            : const Duration(hours: 2, minutes: 14, seconds: 33);
      });
    });

    // ─── 4. ADD THIS: Last Signal Time Timer (1 minute intervals) ───

    // 2. Setup the Last Signal Timer
    _lastSignalTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _minutesAgo++;

          // Restart logic: if it reaches 4, go back to 1
          if (_minutesAgo >= 4) {
            _minutesAgo = 1;
          }
        });
      }
    });
  }



  void _initializeCurrency() {
    final countryToCode = {
      'Australia':      'AUD',
      'Germany':        'EUR',
      'United Kingdom': 'GBP',
      'Tanzania':       'TZS',
      'Uganda':         'UGX',
      'India':          'INR',
      'Kenya':          'KES',
      'USA':            'USD',
      'South Africa':   'ZAR',
      'Nigeria':        'NGN',
      'Ghana':          'GHS',
      'Canada':         'CAD',
    };

    final targetCode = countryToCode[widget.user.country];
    if (targetCode == null) return; // unknown country → keep default KES

    final match = _currencies.firstWhere(
          (c) => c["code"] == targetCode,
      orElse: () => _currencies[0],
    );

    // No setState needed here — initState runs before first build
    _selectedCurrency = match;
  }






  @override
  void dispose() {
    _timer?.cancel();
    _lastSignalTimer?.cancel(); // 👈 Add this to prevent memory leaks

    _videoController.removeListener(_videoLoopListener);
    _videoController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  void _triggerActivationJump() {
    if (_activateKey.currentContext != null) {
      Scrollable.ensureVisible(
        _activateKey.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutQuart,
      );
    }

    setState(() => _activateScale = 1.2);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _activateScale = 1.0);
    });
  }

  void _videoLoopListener() {
    if (_videoController.value.isInitialized) {
      final pos = _videoController.value.position;

      // Set end point to 23 seconds and 50 milliseconds
      final cutoff = const Duration(seconds: 23, milliseconds: 98);

      if (pos >= cutoff) {
        // Jump back to exactly 2 seconds
        _videoController.seekTo(const Duration(seconds: 2));
        _videoController.play();
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────
  String _formatPrice(double kshAmount) {
    final double converted = kshAmount * (_selectedCurrency["rate"] as double);
    final String symbol    = _selectedCurrency["symbol"] as String;
    final String formatted = converted >= 100
        ? converted.toStringAsFixed(0)
        : converted.toStringAsFixed(2);
    return "$symbol $formatted";
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, "0");
    return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  void _jumpToActivation() {
    Scrollable.ensureVisible(
      _activateKey.currentContext!,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutQuart,
    );
    setState(() => _activateScale = 1.15);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _activateScale = 1.0);
    });
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: kMuted.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          Text("Select Currency",
              style: _displayFont(size: 16, color: kCyan, spacing: 1)),
          const SizedBox(height: 8),
          Divider(color: kDivider),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _currencies.length,
              itemBuilder: (ctx, i) {
                final c         = _currencies[i];
                final isSelected = c["code"] == _selectedCurrency["code"];
                return ListTile(
                  leading: Text(c["country"],
                      style: const TextStyle(fontSize: 22)),
                  title: Text(
                    "${c["code"]}  —  ${c["symbol"]}",
                    style: _bodyFont(
                      color: isSelected ? kCyan : kWhite,
                      weight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: kCyan)
                      : null,
                  onTap: () {
                    setState(() => _selectedCurrency = c);
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/14482035533");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch WhatsApp');
    }
  }

  Future<void> _downloadGuide() async {
    try {
      await DownloadHelper.downloadAsset(
          'assets/images/two.png', 'installation_guide.png');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Guide downloaded successfully 📥",
              style: _bodyFont()),
          backgroundColor: kBlue,
        ));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Download failed: $e"),
              backgroundColor: kRed),
        );
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  BUILD  —  Page order (top → bottom)
  //
  //  1.  AppBar
  //  2.  Progress Stepper          (orientation: where am I?)
  //  3.  Main Headline             (hook)
  //  4.  Live Stats Bar            (social proof — early)
  //  5.  Market Sessions Clock     (trading context)
  //  6.  Hero Swipeable            (visuals)
  //  7.  Flipping Feature Grid     (what does it do?)
  //  8.  Quick-Action Row          (Download free | Join Telegram)
  //  9.  Pricing Section           (primary CTA)
  //  10. Telegram VIP Bundle       (upsell)
  //  11. Video Demo                (reinforce decision)
  //  12. More Details              (deep-dive)
  //  13. Installation Guide        (how-to)
  //  14. FAQ                       (objection handling)
  //  15. Reviews                   (final social proof)
  //  16. Footer
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    // ─── ADD PopScope HERE ───
    return PopScope(
      canPop: true, // This allows the system back button to go back to the Register page
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: kNavy,
        appBar: _buildAppBar(),
        drawer: _buildLeftDrawer(),
        endDrawer: OrderSummaryDrawer(
          user: widget.user,
          selectedCurrency: 'KES',
          exchangeRate: 1.0,
          currencySymbol: 'KSh',
          primaryBlue: kBlue,
          deepBlue: kNavy,
        ),
        floatingActionButton: _buildWhatsAppFAB(),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [

              _buildProgressIndicator(),

              _buildMainHeadline(),

              _buildLiveStatsBar(),


              _buildHeroSection(),
              FlippingFeatureGrid(primaryBlue: kBlue, deepBlue: kNavy),
              _buildQuickActionRow(),
              _buildTelegramVIPSection(),
              _buildPricingSection(),
              _buildMarketSessionsClock(),
              _buildAutoPlayVideoSection(),
              _buildMoreDetails(),
              Container(key: _installKey, child: _buildInstallationGuide()),
              _buildFAQSection(),
              _buildReviewsSection(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── FAB ──────────────────────────────────────────────────────
  Widget _buildWhatsAppFAB() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF25D366).withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2)
        ],
      ),
      child: FloatingActionButton(
        onPressed: _launchWhatsApp,
        backgroundColor: const Color(0xFF25D366),
        elevation: 0,
        child: const Icon(Icons.chat_bubble_rounded,
            color: Colors.white, size: 26),
      ),
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kCard,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: kDivider),
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu_open_rounded, color: kCyan),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Currency pill
          GestureDetector(
            onTap: _showCurrencyPicker,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBlue.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedCurrency["country"],
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 5),
                  Text(_selectedCurrency["code"],
                      style: _displayFont(
                          size: 11,
                          color: kCyan,
                          weight: FontWeight.w800,
                          spacing: 0.5)),
                  const Icon(Icons.keyboard_arrow_down,
                      color: kCyan, size: 15),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Trading Console',
            style: _displayFont(
                size: 11,
                color: kWhite,
                weight: FontWeight.w900,
                spacing: 1.5),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: kCyan),
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => FractionallySizedBox(
              heightFactor: 0.9,
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(25)),
                child: SearchDrawer(
                  primaryBlue: kBlue,
                  deepBlue: kNavy,
                  onInstallationClick: () => Scrollable.ensureVisible(
                    _installKey.currentContext!,
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                  ),
                  onMakePaymentsClick: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InformationPage(
                        price: "KSh 1290.00",
                        kshAmount: 1290.0,
                        productName: "Trade X Indicator",
                        initialUser: widget.user,
                      ),
                    ),
                  ),
                  onYourOrderClick: () =>
                      _scaffoldKey.currentState?.openEndDrawer(),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: kCyan),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
      ],
    );
  }

  // ─── Progress Stepper ──────────────────────────────────────────
  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: _glowCard(border: kBlue, radius: BorderRadius.circular(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepDot(true,  "Registration"),
          _stepLine(false),
          _stepDot(false, "Confirm Details"),
          _stepLine(false),
          _stepDot(false, "Checkout"),
        ],
      ),
    );
  }

  Widget _stepDot(bool active, String label) => Column(children: [
    CircleAvatar(
      radius: 9,
      backgroundColor:
      active ? kCyan : kMuted.withOpacity(0.3),
      child: Icon(Icons.check,
          size: 10, color: active ? kNavy : kMuted),
    ),
    const SizedBox(height: 4),
    Text(label,
        style: _bodyFont(
            size: 9, color: active ? kCyan : kMuted)),
  ]);

  Widget _stepLine(bool active) => Container(
    width: 30,
    height: 2,
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: active ? kCyan : kDivider,
      borderRadius: BorderRadius.circular(2),
    ),
  );



  // ─── Main Headline ─────────────────────────────────────────────
  Widget _buildMainHeadline() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Column(
        children: [
          // 1. APEX TRADES (Now on top)
          Text(
            "APEX TRADES",
            textAlign: TextAlign.center,
            style: _displayFont(
                size: 44, weight: FontWeight.w900, spacing: -0.5),
          ),

          const SizedBox(height: 12), // Spacing between title and badge

          // 2. AI badge (Now below main title)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: kGold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: kGold.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium_rounded,
                    color: kGold, size: 14),
                const SizedBox(width: 6),
                Text("High Accuracy Level",
                    style: _displayFont(
                        size: 10,
                        color: kGold,
                        weight: FontWeight.w800,
                        spacing: 1.2)),
              ],
            ),
          ),

          const SizedBox(height: 16), // Spacing before subtitle

          // 3. Subtitle
          Text(
            "Turn Your Trading Into Consistent Profits",
            textAlign: TextAlign.center,
            style: _bodyFont(
                size: 15, color: kCyan, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }


  Widget _buildLiveStatsBar() {
    // ─── Updated: Fixed Win Rate to 89.5% as requested ───
    const String winRate = "89.5";

    // Singular/Plural logic for the time
    final String timeSuffix = _minutesAgo == 1 ? "min" : "mins";

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kCardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGreen.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: kGreen.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Last Signal Time
          _liveStatItem(
              "LAST SIGNAL",
              "$_minutesAgo $timeSuffix ago",
              kCyan
          ),

          _verticalDivider(),

          // 2. Updated: Win Rate now shows 89.5%
          _liveStatItem("WIN RATE", "$winRate%", kGreen),

          _verticalDivider(),

          // 3. Live Status
          _liveStatItem("LIVE NOW", "● ACTIVE", kRed, pulse: true),
        ],
      ),
    );
  }




  Widget _liveStatItem(String label, String value, Color color,
      {bool pulse = false}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pulse) _PulseDot(color: color),
            if (pulse) const SizedBox(width: 4),
            Text(value,
                style: _displayFont(
                    size: 15,
                    color: color,
                    weight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: _bodyFont(size: 9, color: kMuted)),
      ],
    );
  }

  Widget _verticalDivider() =>
      Container(width: 1, height: 32, color: kDivider);

  // ─── Market Sessions Clock ─────────────────────────────────────
  Widget _buildMarketSessionsClock() {
    final now = DateTime.now().toUtc();
    final sessions = [
      {"name": "Sydney",   "open": 22, "close": 7},
      {"name": "Tokyo",    "open": 0,  "close": 9},
      {"name": "London",   "open": 7,  "close": 16},
      {"name": "New York", "open": 12, "close": 21},
    ];

    bool isOpen(int open, int close) {
      final h = now.hour;
      return open < close
          ? (h >= open && h < close)
          : (h >= open || h < close);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration:
      _glowCard(border: kBlue, glowIntensity: 0.1),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  color: kCyan, size: 16),
              const SizedBox(width: 8),
              Text("MARKET SESSIONS",
                  style: _displayFont(
                      size: 11, color: kCyan, spacing: 1.5)),
              const Spacer(),
              Text(
                "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} UTC",
                style: _bodyFont(size: 10, color: kMuted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: sessions.map((s) {
              final open  =
              isOpen(s["open"] as int, s["close"] as int);
              final color = open ? kGreen : kMuted;
              return Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.1),
                      border: Border.all(
                          color: color.withOpacity(0.4),
                          width: 1.5),
                    ),
                    child: Icon(
                      open
                          ? Icons.radio_button_on
                          : Icons.radio_button_off,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(s["name"] as String,
                      style: _bodyFont(size: 10, color: kWhite)),
                  const SizedBox(height: 2),
                  Text(
                    open ? "OPEN" : "CLOSED",
                    style: _displayFont(
                        size: 8,
                        color: color,
                        weight: FontWeight.w800,
                        spacing: 0.8),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Hero Section ──────────────────────────────────────────────
  Widget _buildHeroSection() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: kCyan.withOpacity(0.15), blurRadius: 30)
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SwipeableHeroSection(
              images: [
                'assets/images/one.png',
                'assets/images/seven.jpeg',
                'assets/images/eights.jpeg',




              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Take the guesswork out of trading with the Trade X Indicator. "
                "Designed for both scalpers and swing traders, crafted for high "
                "precision to maximize winning opportunities.",
            textAlign: TextAlign.center,
            style: _bodyFont(size: 13, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildQuickActionRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Ensures vertical alignment
        children: [
          Expanded(
            child: SizedBox(
              height: 60, // Fixed height makes them look uniform
              child: _outlineActionButton(
                label: "FREE INDICATOR\nDOWNLOAD", // Added a line break for balance
                icon: Icons.cloud_download_rounded,
                color: kBlue,
                onTap: _jumpToActivation,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 60, // Matches the height of the first button
              child: _outlineActionButton(
                label: "FREE TELEGRAM\nCOMMUNITY", // Matches the two-line structure
                icon: Icons.telegram,
                color: kTelegram,
                onTap: _jumpToActivation,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Outlined (ghost) button — Updated to use white text/border and branded icons
  Widget _outlineActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      // Icon retains the passed-in branded color
      icon: Icon(icon, color: color, size: 16),
      label: Text(
        label,
        style: _displayFont(
            size: 11,
            color: Colors.white, // Font color changed to white
            weight: FontWeight.w800,
            spacing: 0.8),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        // Border color changed to white
        side: const BorderSide(color: Colors.white, width: 1.4),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        // Subtle background fill for better visibility against dark navy
        backgroundColor: Colors.white.withOpacity(0.05),
      ),
    );
  }



  Widget _buildPricingSection() {
    return Container(
      key: _activateKey,
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      padding: const EdgeInsets.all(24),
      decoration: _glowCard(border: kCyan, glowIntensity: 0.2),
      child: Column(
        children: [
          // 1. Countdown Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: kGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: kGreen.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, color: kGreen, size: 16),
                const SizedBox(width: 8),
                Text(
                  "Offer ends in ${_formatDuration(_duration)}",
                  style: _displayFont(size: 14, color: kGreen, weight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Stat Pills (MOVED ABOVE PRICE)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statPill("90%", "Accuracy"),
              _statPill("10K+", "Traders"),
              _statPill("MT5", "Platform"),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Price Row (MADE SMALLER)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatPrice(basePriceStandard),
                style: _displayFont(
                    size: 26, // Reduced from 38 to make stats look larger
                    color: kCyan,
                    weight: FontWeight.w900),
              ),
              const SizedBox(width: 10),
              Text(
                _formatPrice(oldPriceStandard),
                style: _bodyFont(size: 13, color: kMuted).copyWith(
                  decoration: TextDecoration.lineThrough,
                  decorationColor: kMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 4. Discount Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kGold.withOpacity(0.3)),
            ),
            child: Text(
              "67% OFF — LIMITED TIME",
              style: _displayFont(
                  size: 9,
                  color: kGold,
                  weight: FontWeight.w800,
                  spacing: 1),
            ),
          ),
          const SizedBox(height: 28),

          // 5. Activate Button (With Animated Zoom)
          AnimatedScale(
            scale: _activateScale,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            child: _glowButton(
              label: "ACTIVATE APEX ACCOUNT",
              icon: Icons.vpn_key_rounded,
              color: kGold,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InformationPage(
                    price: _formatPrice(1290.0),
                    kshAmount: 1290.0,
                    productName: "Activation Fee",
                    initialUser: widget.user,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 6. Trust Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_outlined, color: kGreen, size: 14),
              const SizedBox(width: 6),
              Text("One-time payment · Lifetime access",
                  style: _bodyFont(size: 12, color: kMuted)),
            ],
          ),
        ],
      ),
    );
  }





  Widget _statPill(String value, String label) => Column(children: [
    Text(value,
        style: _displayFont(
            size: 20,
            color: kCyan,
            weight: FontWeight.w900)),
    Text(label, style: _bodyFont(size: 10, color: kMuted)),
  ]);


  //how can we place white border lin on GET FUNDED ACCOUNT button?
  Widget _buildTelegramVIPSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(24),
          // Using Gold border to indicate Premium "Direct Buy" status
          border: Border.all(color: kGold.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: kGold.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          children: [
            // Premium badge - Updated Name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kGold, Color(0xFFFF8F00)]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: kGold.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Text("💎 INSTANT BUNDLE", // <--- New Name
                  style: _displayFont(
                      size: 11,
                      color: kNavy, // Dark text on gold looks premium
                      weight: FontWeight.w900,
                      spacing: 1.1)),
            ),
            const SizedBox(height: 20),

            // Icon pair
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _iconCircle(Icons.auto_graph_rounded, kCyan),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text("+",
                      style: _displayFont(
                          size: 28,
                          color: kGold,
                          weight: FontWeight.w200)),
                ),
                _iconCircle(Icons.telegram, kTelegram),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              "Full Indicator Access + VIP Signal Community",
              textAlign: TextAlign.center,
              style: _displayFont(
                  size: 17,
                  color: kTelegram,
                  weight: FontWeight.w900,
                  spacing: -0.3),
            ),
            const SizedBox(height: 10),

            // Emphasize DIRECT BUY in the description
            Text(
              "Skip the activation process. Purchase the full indicator suite "
                  "and get added to the VIP Community instantly.",
              textAlign: TextAlign.center,
              style: _bodyFont(size: 12, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Pricing
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(_formatPrice(basePriceVIP),
                    style: _displayFont(
                        size: 24, color: kCyan, weight: FontWeight.w900)),
                const SizedBox(width: 10),
                Text(
                  _formatPrice(oldPriceVIP),
                  style: _bodyFont(size: 13, color: kMuted).copyWith(
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // MAIN CTA: BUY DIRECTLY
            _glowButton(
              label: "BUY BUNDLE & JOIN NOW", // <--- Emphasizing immediate action
              icon: Icons.shopping_cart_checkout_rounded,
              color: kBlue,
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => FractionallySizedBox(
                  heightFactor: 0.85,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    child: TelegramDrawer(
                      user: widget.user,
                      currencySymbol: _selectedCurrency["symbol"],
                      exchangeRate: _selectedCurrency["rate"],
                      primaryBlue: kBlue,
                      deepBlue: kNavy,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Secondary option
            _glowButton(
              label: "GET FUNDED ACCOUNT",
              icon: Icons.account_balance_wallet_rounded,
              color: kCardLight,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FundPage()),
                );
                if (result == "jump_to_activation") {
                  _triggerActivationJump();
                }
              },
            ),



          ],
        ),
      ),
    );
  }








  Widget _iconCircle(IconData icon, Color color) => Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      shape: BoxShape.circle,
      border:
      Border.all(color: color.withOpacity(0.4)),
      boxShadow: [
        BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12)
      ],
    ),
    child: Icon(icon, color: color, size: 28),
  );




  // ─── Video Demo ────────────────────────────────────────────────
  Widget _buildAutoPlayVideoSection() {
    return VisibilityDetector(
      key: const Key('home-video-player'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          if (_isVideoInitialized &&
              !_videoController.value.isPlaying)
            _videoController.play();
        } else {
          if (_isVideoInitialized &&
              _videoController.value.isPlaying)
            _videoController.pause();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 10),
        decoration:
        _glowCard(border: kCyan, glowIntensity: 0.15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              _isVideoInitialized
                  ? AspectRatio(
                  aspectRatio:
                  _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController))
                  : const SizedBox(
                height: 200,
                child: Center(
                    child: CircularProgressIndicator(
                        color: kCyan)),
              ),
              if (_isVideoInitialized)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: CircleAvatar(
                    backgroundColor: kNavy.withOpacity(0.7),
                    child: IconButton(
                      icon: Icon(
                        _isMuted
                            ? Icons.volume_off
                            : Icons.volume_up,
                        color: kCyan,
                        size: 18,
                      ),
                      onPressed: () => setState(() {
                        _isMuted = !_isMuted;
                        _videoController
                            .setVolume(_isMuted ? 0.0 : 1.0);
                      }),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── More Details ──────────────────────────────────────────────
  Widget _buildMoreDetails() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(22),
      decoration: _glowCard(border: kBlue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _sectionLabel("MORE INDICATOR DETAILS")),
          const SizedBox(height: 16),
          Text(
            "Trade X Indicator is a high-performance technical tool designed "
                "for MetaTrader 5. It simplifies market analysis and helps traders "
                "make faster, more confident decisions.",
            textAlign: TextAlign.center,
            style: _bodyFont(size: 13, color: kMuted),
          ),
          const SizedBox(height: 22),
          _sectionLabel("CORE FEATURES"),
          const SizedBox(height: 10),
          _bullet("User-friendly interface with quick and easy installation."),
          _bullet("High-precision signals for better entry and exit points."),
          _bullet("Real-time alerts to keep you updated on market movements."),
          const SizedBox(height: 22),
          _sectionLabel("PERFORMANCE BENEFITS"),
          const SizedBox(height: 10),
          _bullet("Improves trading consistency by reducing guesswork."),
          _bullet("Minimizes emotional trading decisions."),
          _bullet("Optimized for fast performance and quick signal delivery."),
          const SizedBox(height: 22),
          _sectionLabel("COMPATIBILITY"),
          const SizedBox(height: 10),
          _bullet("Supports multiple timeframes for flexible trading."),
          _bullet("Works across forex, crypto, and indices."),
          _bullet("Customizable settings to match your trading strategy."),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: _displayFont(
        size: 12,
        color: kCyan,
        weight: FontWeight.w800,
        spacing: 2),
  );

  Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
              color: kCyan, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(text,
                style:
                _bodyFont(size: 13, color: Colors.white))),
      ],
    ),
  );

  // ─── Installation Guide ────────────────────────────────────────
  Widget _buildInstallationGuide() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration:
      _glowCard(border: kBlue, radius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _sectionLabel("INDICATOR INSTALLATION GUIDE")),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/images/two.png',
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                height: 180,
                color: kCardLight,
                child: const Center(
                    child:
                    Icon(Icons.image, color: kCyan, size: 50)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: OutlinedButton.icon(
              onPressed: _downloadGuide,
              icon: const Icon(Icons.file_download_outlined,
                  color: kCyan),
              label: Text("DOWNLOAD GUIDE",
                  style: _displayFont(
                      size: 12,
                      color: kCyan,
                      weight: FontWeight.w700,
                      spacing: 1)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kCyan, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _installStep("Save the Indicator File"),
          _installStep("Open B.T.A Sniper entries file",
              subText: "Click B.T.A Sniper entries file"),
          _installStep("Open B.T.A Optimal trade zone",
              subText: "Click B.T.A Optimal trade zone"),
          _installStep("Go to trading platform (MT5)"),
          _installStep("Select Indicators on Insert Option"),
          _installStep("Open B.T.A Sniper entries file",
              isHeader: true,
              bullets: [
                "Go to inputs and put password",
                "Double tap okay"
              ]),
          _installStep("Open B.T.A Optimal trade zone file",
              isHeader: true,
              bullets: [
                "Go to inputs and put password",
                "Double tap okay"
              ]),
          _installStep("Start Trading",
              isHeader: true,
              bullets: [
                "Watch real-time signals on your chart",
                "Follow the entry and exit points provided",
                "Manage your risk properly for best results",
              ]),
          const SizedBox(height: 20),
          Divider(color: kDivider),
          const SizedBox(height: 12),
          Center(
            child: Text(
              "You're all set! Monitor the signals, make your entries, "
                  "and trade with confidence. Good luck! 🚀",
              textAlign: TextAlign.center,
              style: _bodyFont(size: 13, color: kCyan)
                  .copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _installStep(
      String title, {
        String? subText,
        List<String>? bullets,
        bool isHeader = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: kCyan, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: _bodyFont(
                        size: 14,
                        color: kWhite,
                        weight: isHeader
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    if (subText != null)
                      Text("~ $subText",
                          style:
                          _bodyFont(size: 12, color: kMuted)),
                  ],
                ),
              ),
            ],
          ),
          if (bullets != null)
            Padding(
              padding:
              const EdgeInsets.only(left: 30, top: 6),
              child: Column(
                children: bullets
                    .map((b) => Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 2),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text("– ",
                          style: _bodyFont(
                              size: 12,
                              color: kCyan)),
                      Expanded(
                          child: Text(b,
                              style: _bodyFont(
                                  size: 12,
                                  color: kMuted))),
                    ],
                  ),
                ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ─── FAQ ───────────────────────────────────────────────────────
  Widget _buildFAQSection() {
    final faqs = [
      {
        "q": "What is Trade X Indicator?",
        "a": "It's an AI-powered trading tool for MT5 that provides high-accuracy signals, predictive trend analysis, and deep market pattern recognition."
      },


      {
        "q": "What services does Apex Trades provide?",
        "a": "We provide a complete trading ecosystem including the AI-powered Trade X Indicator and a VIP Telegram signal community."
      },

      {
        "q": "How do I get started with a Funded Account?",
        "a": "Go to the 'Get Funded Account' section, choose your preferred account size (from 5K to 250K) and trading platform. Once you pass the evaluation, you can trade with company capital and keep up to 90% of the profits."
      },

      {
        "q": "How does it improve my trading?",
        "a": "It reduces emotional decision-making, improves consistency, and helps both scalpers and swing traders maximize winning opportunities."
      },

      {
        "q": "What is the difference between Activation and the Instant Bundle?",
        "a": "Activation is the standard process to verify your account and unlock features. The 'Instant Bundle' is a premium direct-buy option that lets you skip the activation queue and get immediate access to all tools and the VIP community."
      },


      {
        "q": "Which platforms does indicator work on?",
        "a": "Compatible with MetaTrader 5 (MT5)."
      },


      {
        "q": "Do I need a subscription?",
        "a": "No monthly fees. Pay once and get lifetime access with free updates."
      },


      {
        "q": "Can I use indicator on any asset?",
        "a": "Works on any asset available on MT5 including forex, stocks, indices, and commodities."
      },

      {
        "q": "How accurate are the signals?",
        "a": "Designed for high precision, with many users reporting consistent win rates and improved strategies."
      },

      {
        "q": "Can I install indicator myself?",
        "a": "Yes. A step-by-step installation guide is included, and support is available if needed."
      },

    ];

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(22),
      decoration: _glowCard(border: kBlue),
      child: Column(
        children: [
          _sectionLabel("FREQUENTLY ASKED QUESTIONS"),
          const SizedBox(height: 16),
          Theme(
            data: Theme.of(context)
                .copyWith(dividerColor: Colors.transparent),
            child: Column(
              children: faqs
                  .map((faq) => ExpansionTile(
                iconColor: kCyan,
                collapsedIconColor: kMuted,
                tilePadding: EdgeInsets.zero,
                title: Text(faq['q']!,
                    style: _bodyFont(
                        size: 14,
                        color: kWhite,
                        weight: FontWeight.w600)),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 12),
                    child: Text(faq['a']!,
                        style: _bodyFont(
                            size: 13, color: kMuted)),
                  ),
                ],
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Reviews ───────────────────────────────────────────────────
  Widget _buildReviewsSection() {
    final displayed = _isReviewsExpanded
        ? _userReviews
        : _userReviews.take(8).toList();
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(22),
      decoration: _glowCard(border: kBlue),
      child: Column(
        children: [
          _sectionLabel("CUSTOMER REVIEWS"),
          const SizedBox(height: 20),
          ...displayed.map((r) => _reviewItem(
              r['name'] as String,
              r['comment'] as String,
              r['stars'] as int)),
          if (_userReviews.length > 8)
            IconButton(
              icon: Icon(
                _isReviewsExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: kCyan,
                size: 30,
              ),
              onPressed: () => setState(
                      () => _isReviewsExpanded = !_isReviewsExpanded),
            ),
          const SizedBox(height: 10),
          _glowButton(
            label: "ADD REVIEW",
            icon: Icons.add,
            color: kBlue,
            onTap: _showAddReviewDialog,
          ),
        ],
      ),
    );
  }

  Widget _reviewItem(String name, String comment, int stars) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: kBlue.withOpacity(0.2),
              child: Text(name[0].toUpperCase(),
                  style: _displayFont(size: 14, color: kCyan)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(name,
                              style: _bodyFont(
                                  size: 12,
                                  color: kWhite,
                                  weight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis)),
                      Row(
                          children: List.generate(
                              stars,
                                  (_) => const Icon(Icons.star,
                                  color: kGold, size: 12))),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(comment,
                      style: _bodyFont(size: 12, color: kMuted)),
                  Divider(color: kDivider, height: 20),
                ],
              ),
            ),
          ],
        ),
      );

  void _showAddReviewDialog() {
    final controller  = TextEditingController();
    int selectedStars = 5;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Write a Review",
                  style: _displayFont(size: 18, color: kWhite)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    5,
                        (i) => IconButton(
                      icon: Icon(
                        i < selectedStars
                            ? Icons.star
                            : Icons.star_border,
                        color: kGold,
                        size: 32,
                      ),
                      onPressed: () => setSheet(
                              () => selectedStars = i + 1),
                    )),
              ),
              TextField(
                controller: controller,
                style: _bodyFont(color: kWhite),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Share your experience...",
                  hintStyle: _bodyFont(color: kMuted),
                  filled: true,
                  fillColor: kCardLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    BorderSide(color: kDivider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    BorderSide(color: kDivider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: kCyan, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _glowButton(
                label: "SUBMIT REVIEW",
                icon: Icons.send_rounded,
                color: kBlue,
                onTap: () {
                  if (controller.text.isNotEmpty) {
                    setState(() {
                      _userReviews.insert(0, {
                        "name":    widget.user.email,
                        "comment": controller.text,
                        "stars":   selectedStars,
                      });
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Review posted!",
                              style: _bodyFont()),
                          backgroundColor: kBlue),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Left Drawer ───────────────────────────────────────────────
  Widget _buildLeftDrawer() => Drawer(
    backgroundColor: kCard,
    child: Column(
      children: [
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(
            color: kCardLight,
            border:
            Border(bottom: BorderSide(color: kDivider)),
          ),
          accountName: Text(widget.user.fullName,
              style: _displayFont(size: 15, color: kWhite)),
          accountEmail: Text(widget.user.email,
              style: _bodyFont(size: 12, color: kMuted)),
          currentAccountPicture: CircleAvatar(
            backgroundColor: kBlue.withOpacity(0.2),
            child: Text(
              widget.user.fullName.isNotEmpty
                  ? widget.user.fullName[0].toUpperCase()
                  : "T",
              style: _displayFont(size: 22, color: kCyan),
            ),
          ),
        ),
      ],
    ),
  );

  // ─── Footer ────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: kCard,
        border: Border(top: BorderSide(color: kDivider)),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_graph_rounded,
              color: kCyan, size: 28),
          const SizedBox(height: 8),
          Text("Trade X Indicator",
              style: _displayFont(
                  size: 14,
                  color: kWhite,
                  weight: FontWeight.w800,
                  spacing: 1)),
          const SizedBox(height: 6),
          Text("© Apex Markets Shop. All Rights Reserved.",
              style: _bodyFont(size: 11, color: kMuted)),
        ],
      ),
    );
  }

  // ─── Shared: Glow Button ───────────────────────────────────────
  Widget _glowButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool fullWidth = true,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 6))
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: kWhite, size: 18),
        label: Text(label,
            style: _displayFont(
                size: 13,
                color: kWhite,
                weight: FontWeight.w900,
                spacing: 1)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize:
          Size(fullWidth ? double.infinity : 140, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }
}
// ─── end _HomePageState ────────────────────────────────────────────────────────

// ═══════════════════════════════════════════════════════════════════════════════
//  PulseDot — standalone helper widget
// ═══════════════════════════════════════════════════════════════════════════════
class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
            color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

