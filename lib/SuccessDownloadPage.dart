
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'email_service.dart';

class SuccessDownloadPage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const SuccessDownloadPage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<SuccessDownloadPage> createState() => _SuccessDownloadPageState();
}

class _SuccessDownloadPageState extends State<SuccessDownloadPage> {
  final String rarPassword = "131f8e1f207002dab77feea8a77805455827ae08dd";
  final String downloadLink = "https://drive.google.com/uc?export=download&id=1dIRJ-RC369HoQSkpCeu8tnBbSlzM1T7z";

  bool _isSending = true;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _deliverEmail();
  }

  Future<void> _deliverEmail() async {
    setState(() => _isSending = true);
    bool result = await EmailService.sendIndicatorEmail(
      userName: widget.userName,
      userEmail: widget.userEmail,
      rarPassword: rarPassword,
      downloadLink: downloadLink,
    );
    if (mounted) {
      setState(() {
        _isSending = false;
        _success = result;
      });
    }
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard!"), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFE),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [

                const Icon(Icons.stars_rounded, color: Colors.green, size: 90),
                const SizedBox(height: 10),
                const Text("PAYMENT RECEIVED", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0083B0))),

                // Delivery Status
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: _success ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isSending
                      ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 12), Text("Sending files to email...")])
                      : Row(
                    children: [
                      Icon(_success ? Icons.email_outlined : Icons.error_outline, color: _success ? Colors.green : Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_success ? "Files sent to ${widget.userEmail}. Check Inbox/Spam." : "Email delivery failed. Please copy details below or GET FILES ON WHATSAPP.", style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                ),

                _buildCopyCard("EXTRACTION PASSWORD", rarPassword, Icons.lock_outline),
                const SizedBox(height: 15),
                _buildCopyCard("DOWNLOAD LINK(Paste In Browser)", downloadLink, Icons.link),

                const SizedBox(height: 30),

                // WhatsApp Fallback (The Ultimate Solution if email fails)
                ElevatedButton.icon(
                  onPressed: () => launchUrl(Uri.parse("https://wa.me/14482035533?text=Hi, I paid for TradeX but didn't get the email. My email is: ${widget.userEmail}")),
                  icon: const Icon(Icons.chat, color: Colors.white),
                  label: const Text("GET FILES ON WHATSAPP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),

                const SizedBox(height: 15),

                if (!_success && !_isSending)
                  TextButton(onPressed: _deliverEmail, child: const Text("Retry Sending Email")),

                const SizedBox(height: 30),
                TextButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text("Return to Home", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCopyCard(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.black.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 14, color: Colors.blueGrey), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey))]),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)), child: Text(content, style: const TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))),
              const SizedBox(width: 8),
              IconButton(onPressed: () => _copy(content), icon: const Icon(Icons.copy, color: Color(0xFF0083B0), size: 20)),
            ],
          ),
        ],
      ),
    );
  }
}

