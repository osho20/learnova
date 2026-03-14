import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final box = Hive.box('settings');
  final hasProfile = box.get('hasProfile', defaultValue: false);

  return GoRouter(
    initialLocation: hasProfile ? '/home' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});