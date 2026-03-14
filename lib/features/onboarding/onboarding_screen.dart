import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _collegeIdController = TextEditingController();
  final _collegeNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final box = Hive.box('settings');
    await box.put('userName', _nameController.text.trim());
    await box.put('collegeId', _collegeIdController.text.trim());
    await box.put('collegeName', _collegeNameController.text.trim());
    await box.put('hasProfile', true);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF1565C0)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: const Icon(Icons.school_rounded, size: 50, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        Text('StudyAI',
                            style: GoogleFonts.poppins(
                                fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
                        Text('Your AI Study Companion',
                            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Let\'s get started!',
                            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF1A237E))),
                        const SizedBox(height: 6),
                        Text('Tell us about yourself',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                        const SizedBox(height: 28),
                        _buildLabel('Your Full Name'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration('e.g. Abhinav Kumar', Icons.person_rounded),
                          validator: (v) => v!.isEmpty ? 'Please enter your name' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('College ID / Roll Number'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _collegeIdController,
                          decoration: _inputDecoration('e.g. CS2024001', Icons.badge_rounded),
                          validator: (v) => v!.isEmpty ? 'Please enter your college ID' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('College / University Name'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _collegeNameController,
                          decoration: _inputDecoration('e.g. MIT College', Icons.account_balance_rounded),
                          validator: (v) => v!.isEmpty ? 'Please enter your college name' : null,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A237E),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text('Start Learning',
                                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text('Inspired by Osho • Built with love',
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.white60)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A237E)));
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF1A237E), size: 20),
      filled: true,
      fillColor: const Color(0xFFF4F6FF),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2)),
    );
  }
}
