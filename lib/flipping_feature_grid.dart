import 'dart:async';
import 'package:flutter/material.dart';

class FlippingFeatureGrid extends StatefulWidget {
  final Color primaryBlue;
  final Color deepBlue;

  const FlippingFeatureGrid({
    super.key,
    required this.primaryBlue,
    required this.deepBlue,
  });

  @override
  State<FlippingFeatureGrid> createState() => _FlippingFeatureGridState();
}

class _FlippingFeatureGridState extends State<FlippingFeatureGrid> {
  late ScrollController _scrollController;
  Timer? _timer;

  static const List<Map<String, dynamic>> _featurePool = [
    {"icon": Icons.bolt, "label": "AI Accuracy"},
    {"icon": Icons.analytics, "label": "Trend Analysis"},
    {"icon": Icons.verified_user, "label": "90% Accurate Trades"},
    {"icon": Icons.sentiment_very_satisfied, "label": "Trading made easy"},
    {"icon": Icons.show_chart, "label": "Improve consistency"},
    {"icon": Icons.notification_add, "label": "Never miss signals"},
    {"icon": Icons.sensors, "label": "Real-time signals"},
    {"icon": Icons.face, "label": "Beginner-friendly"},
    {"icon": Icons.speed, "label": "Fast & Responsive"},
    {"icon": Icons.psychology, "label": "Less Emotional"},
    {"icon": Icons.settings_suggest, "label": "No complex setup"},
    {"icon": Icons.auto_graph, "label": "Auto Buy/Sell"},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Start the scrolling animation after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    // Speed control: pixels per second
    const double step = 0.5;

    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.offset;

        // If we reach the end, jump back to start to create an infinite loop
        if (currentScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(currentScroll + step);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We double the list to make the loop seamless
    final items = [..._featurePool, ..._featurePool];

    return Container(
      height: 60, // Fixed height for the ticker
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(), // User can't interrupt the auto-scroll
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildFeatureItem(items[index]);
        },
      ),
    );
  }

  Widget _buildFeatureItem(Map<String, dynamic> feature) {
    // Create highlight color based on your primary blue
    final highlightBlue = HSVColor.fromColor(widget.primaryBlue)
        .withValue(1.0)
        .toColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            highlightBlue.withOpacity(0.8),
            widget.primaryBlue,
            widget.deepBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15), // Rounded pill shape
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.deepBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            feature['icon'],
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            feature['label'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}