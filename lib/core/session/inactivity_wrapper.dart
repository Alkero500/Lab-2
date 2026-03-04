import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InactivityWrapper extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const InactivityWrapper({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<InactivityWrapper> createState() => _InactivityWrapperState();
}

class _InactivityWrapperState extends State<InactivityWrapper> {
  Timer? _timer;
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();

    // Solo corre el timer si hay usuario logueado
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _cancelTimer();
      } else {
        _resetTimer();
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _resetTimer() {
    _cancelTimer();
    _timer = Timer(const Duration(minutes: 10), () async {
      await FirebaseAuth.instance.signOut();

      // Limpia pila de navegación
      widget.navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => widget.child),
        (route) => false,
      );
    });
  }

  void _onUserInteraction() {
    if (FirebaseAuth.instance.currentUser != null) {
      _resetTimer();
    }
  }

  @override
  void dispose() {
    _cancelTimer();
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _onUserInteraction(),
      onPointerMove: (_) => _onUserInteraction(),
      child: widget.child,
    );
  }
}