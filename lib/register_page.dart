
import 'package:flutter/material.dart';
import 'homepage.dart';
import 'main.dart';
import 'terms_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedCountry;
  bool _isAgreed = false;

  final Color primaryBlue = const Color(0xFF00B4DB);
  final Color deepBlue = const Color(0xFF0083B0);

  void _handleRegistration() {
    // Validates form fields, country selection, and terms agreement
    if (_formKey.currentState!.validate() && _isAgreed && _selectedCountry != null) {
      final newUser = UserData(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        country: _selectedCountry!,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(user: newUser),
        ),
      );




    } else if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your country")),
      );
    } else if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the Terms & Conditions")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [deepBlue, Colors.black],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildGlassCard(),
                  const SizedBox(height: 30),
                  _buildRegisterButton(),
                  const SizedBox(height: 20),
                  _buildFooterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: double.infinity),
        Text(
          "Apex Trades",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: primaryBlue,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Access Premium Signals",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w300),
        ),
      ],
    );
  }

  Widget _buildGlassCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("FULL NAME"),
          _buildTextField(
            _nameController,
            "e.g. John Doe",
            Icons.person_outline,
          ),
          const SizedBox(height: 20),

          _buildLabel("EMAIL ADDRESS"),
          _buildTextField(
            _emailController,
            "yourname@gmail.com",
            Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.isEmpty) return "Email is required";
              // Enforce Gmail format
              if (!val.toLowerCase().endsWith("@gmail.com")) {
                return "Only @gmail.com accounts are allowed";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          _buildLabel("COUNTRY"),
          _buildCountryDropdown(),
          const SizedBox(height: 20),

          _buildTermsCheckbox(),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  // Updated to accept an optional custom validator
  Widget _buildTextField(
      TextEditingController controller,
      String hint,
      IconData icon,
      {TextInputType? keyboardType, String? Function(String?)? validator}
      ) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      validator: validator ?? (val) => val!.isEmpty ? "Required field" : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryBlue, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryBlue)),
        errorStyle: const TextStyle(color: Colors.orangeAccent),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountry,
          hint: const Text("Select Country", style: TextStyle(color: Colors.white24, fontSize: 15)),
          dropdownColor: deepBlue,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: primaryBlue),
          style: const TextStyle(color: Colors.white, fontSize: 15),
          onChanged: (val) => setState(() => _selectedCountry = val),

          items: ['Australia','Germany','United Kingdom','Tanzania','Uganda', 'India','Kenya','USA','South Africa','Nigeria', 'Ghana','Canada']


              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          height: 24, width: 24,
          child: Checkbox(
            value: _isAgreed,
            activeColor: primaryBlue,
            side: const BorderSide(color: Colors.white38),
            onChanged: (val) => setState(() => _isAgreed = val!),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            "I agree to the Terms of Service & Privacy Policy",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleRegistration,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text(
          "REGISTER",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildFooterLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TermsPage()),
          );
        },
        child: Text(
          "Terms and Conditions",
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}