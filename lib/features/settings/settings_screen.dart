import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final box = Hive.box('settings');

  final List<Map<String, dynamic>> _themes = [
    {'name': 'Indigo Blue', 'color': const Color(0xFF1A237E), 'gradient': [const Color(0xFF1A237E), const Color(0xFF3949AB)]},
    {'name': 'Deep Purple', 'color': const Color(0xFF4A148C), 'gradient': [const Color(0xFF4A148C), const Color(0xFF7B1FA2)]},
    {'name': 'Teal Green', 'color': const Color(0xFF004D40), 'gradient': [const Color(0xFF004D40), const Color(0xFF00695C)]},
    {'name': 'Deep Red', 'color': const Color(0xFFB71C1C), 'gradient': [const Color(0xFFB71C1C), const Color(0xFFE53935)]},
    {'name': 'Dark Navy', 'color': const Color(0xFF0D1B2A), 'gradient': [const Color(0xFF0D1B2A), const Color(0xFF1B263B)]},
    {'name': 'Midnight', 'color': const Color(0xFF1A1A2E), 'gradient': [const Color(0xFF1A1A2E), const Color(0xFF16213E)]},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF4F6FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Settings',
                            style: GoogleFonts.poppins(fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text('Customize your experience',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile section
                  _buildSectionTitle('👤 Profile', isDark),
                  const SizedBox(height: 12),
                  _buildProfileCard(isDark),
                  const SizedBox(height: 24),

                  // Appearance
                  _buildSectionTitle('🎨 Appearance', isDark),
                  const SizedBox(height: 12),
                  _buildCard(
                    isDark,
                    child: Column(
                      children: [
                        // Dark mode toggle
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A237E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isDark
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                color: const Color(0xFF1A237E),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Dark Mode',
                                      style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600)),
                                  Text('Switch between light and dark',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Switch(
                              value: themeMode == ThemeMode.dark,
                              onChanged: (value) {
                                ref.read(themeModeProvider.notifier).state =
                                    value ? ThemeMode.dark : ThemeMode.light;
                                box.put('isDark', value);
                              },
                              activeColor: const Color(0xFF1A237E),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Theme colors
                  _buildCard(
                    isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('App Theme Color',
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Choose your preferred color scheme',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.5,
                          ),
                          itemCount: _themes.length,
                          itemBuilder: (context, index) {
                            final theme = _themes[index];
                            final isSelected =
                                box.get('themeIndex', defaultValue: 0) == index;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  box.put('themeIndex', index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${theme['name']} theme applied!',
                                        style: GoogleFonts.poppins()),
                                    backgroundColor:
                                        theme['color'] as Color,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors:
                                        theme['gradient'] as List<Color>,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.white, width: 2.5)
                                      : null,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: (theme['color'] as Color)
                                                .withOpacity(0.4),
                                            blurRadius: 8,
                                          )
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    theme['name'] as String,
                                    style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                                    const SizedBox(height: 24),
                  // API Key section
                  _buildSectionTitle('🤖 AI Configuration', isDark),
                  const SizedBox(height: 12),
                  _buildApiKeyCard(isDark),
                  const SizedBox(height: 24),
                  // About
                  _buildSectionTitle('ℹ️ About', isDark),
                  const SizedBox(height: 12),
                  _buildCard(
                    isDark,
                    child: Column(
                      children: [
                        _buildInfoRow(
                            Icons.apps_rounded, 'App Name', 'StudyAI', isDark),
                        const Divider(height: 24),
                        _buildInfoRow(Icons.info_rounded, 'Version',
                            '1.0.0', isDark),
                        const Divider(height: 24),
                        _buildInfoRow(Icons.code_rounded, 'Built with',
                            'Flutter + Claude AI', isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Credits
                  _buildSectionTitle('🌟 Credits', isDark),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A237E).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 2),
                          ),
                          child: const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 36),
                        ),
                        const SizedBox(height: 16),
                        Text('Designed & Built by',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text('Osho',
                            style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('Made with ❤️ using Flutter & Claude AI',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.white70),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('StudyAI v1.0.0',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).scale(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(title,
        style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A237E)));
  }

  Widget _buildCard(bool isDark, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildProfileCard(bool isDark) {
    final userName = box.get('userName', defaultValue: 'Student');
    final collegeId = box.get('collegeId', defaultValue: '');
    final collegeName = box.get('collegeName', defaultValue: 'Your College');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty
                    ? userName[0].toUpperCase()
                    : 'S',
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName,
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                if (collegeId.isNotEmpty)
                  Text(collegeId,
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: const Color(0xFF1A237E),
                          fontWeight: FontWeight.w500)),
                Text(collegeName,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1A237E), size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(label,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
        ),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
Widget _buildApiKeyCard(bool isDark) {
  final apiKey = Hive.box('settings').get('geminiApiKey', defaultValue: '');
  final controller = TextEditingController(text: apiKey);

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.key_rounded,
                  color: Colors.green, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gemini API Key',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  Text('Free at aistudio.google.com',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          obscureText: true,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Paste your Gemini API key here...',
            hintStyle: GoogleFonts.poppins(
                color: Colors.grey[400], fontSize: 12),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF0D0D1A)
                : const Color(0xFFF4F6FF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.save_rounded, color: Colors.green),
              onPressed: () {
                Hive.box('settings').put('geminiApiKey', controller.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('API Key saved! ✅',
                        style: GoogleFonts.poppins()),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.open_in_new_rounded,
                  color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Text('Get FREE key at aistudio.google.com',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    ),
  );
}}