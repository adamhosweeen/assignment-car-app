import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:assignment/control/app_navigation.dart';
import 'package:assignment/control/auth/auth_repository.dart';
import 'package:assignment/model/profile/profile.dart';
import 'package:assignment/views/app_shell.dart';
import 'package:assignment/views/auth/splash_screen.dart';
import 'package:assignment/views/auth/welcome_screen.dart';

const Duration _splashDuration = Duration(milliseconds: 800);

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<Profile?>? _sub;
  bool _ready = false;
  bool _signedIn = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthRepository>();
    _signedIn = auth.currentUser != null;
    _sub = auth.authState().listen(_onAuthChanged);
    _startSplash();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _startSplash() async {
    await Future<void>.delayed(_splashDuration);
    if (mounted) setState(() => _ready = true);
  }

  void _onAuthChanged(Profile? profile) {
    final signedIn = profile != null;
    if (signedIn == _signedIn || !mounted) return;
    final navigator = context.read<AppNavigator>();
    navigator.popToRoot();
    navigator.tab.value = homeTabBuy;
    setState(() => _signedIn = signedIn);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SplashScreen();
    return _signedIn ? const AppShell() : const WelcomeScreen();
  }
}
