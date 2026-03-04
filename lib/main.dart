import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/auth/auth_gate.dart';
import 'core/session/inactivity_wrapper.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FinanzaTrackApp());
}

class FinanzaTrackApp extends StatelessWidget {
  const FinanzaTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'FinanzaTrack',
      home: InactivityWrapper(
        navigatorKey: navigatorKey,
        child: const AuthGate(),
      ),
    );
  }
}