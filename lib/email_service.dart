import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class EmailService {
  // DOUBLE CHECK THESE IN YOUR EMAILJS DASHBOARD
  static const String serviceId = 'service_k7v4o9a';
  static const String templateId = 'template_v8xnm38';
  static const String publicKey = 'vT9v1j9K-O-C3xZ27';

  static Future<bool> sendIndicatorEmail({
    required String userName,
    required String userEmail,
    required String rarPassword,
    required String downloadLink,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'to_name': userName,
            'to_email': userEmail, // Ensure this variable exists in your EmailJS template
            'rar_password': rarPassword,
            'download_link': downloadLink,
            'my_admin_email': 'amazons7781@gmail.com',
          }
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Email system accepted the request.");
        return true;
      } else {
        // This will print the exact error from EmailJS (e.g. "The user_id is required")
        debugPrint("❌ EmailJS Error: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Connection Error: $e");
      return false;
    }
  }
}