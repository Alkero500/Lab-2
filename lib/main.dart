import 'package:flutter/material.dart';
import 'core/constants.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/pages/add_transaction_page.dart';

void main() {
  runApp(const FinanzaTrackApp());
}

class FinanzaTrackApp extends StatelessWidget {
  const FinanzaTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinanzaTrack',
      theme: appTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardPage(),
        '/add-transaction': (context) => const AddTransactionPage(),
      },
    );
  }
}