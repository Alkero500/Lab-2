import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';

import '../../features/transactions/data/datasources/pro_local_datasource.dart';

class UpgradePage extends StatelessWidget {
  const UpgradePage({super.key});

  static const String proPrice = '4.99';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mejorar a Pro")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "FinanzaTrack Pro (pago único)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Desbloquea: Exportar reportes PDF (demo)."),
            const SizedBox(height: 16),
            Text("Total: \$$proPrice USD"),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PaypalCheckoutView(
                        sandboxMode: true,
                        clientId: "AayPkHxALhWughD6uLuFwhNctiYTg_8WN17PIF2jHXPA_LI3UcF_5V3rBPZJKbogmEeFHRvx6jH8Uvdb",
                        secretKey: "EORZJPZCgkNKdCCC9QCKhnIbz32wW0FCVXMauUJ9MzgKOwLu6FoX_uABukYUIaLXwavF4zU-RWwAk3gw",
                        transactions: const [
                          {
                            "amount": {
                              "total": proPrice,
                              "currency": "USD",
                              "details": {"subtotal": proPrice, "shipping": "0"}
                            },
                            "description": "FinanzaTrack Pro - Pago único",
                            "item_list": {
                              "items": [
                                {
                                  "name": "FinanzaTrack Pro",
                                  "quantity": 1,
                                  "price": proPrice,
                                  "currency": "USD"
                                }
                              ]
                            }
                          }
                        ],
                        note: "Pago de prueba",
                        onSuccess: (Map params) async {
                          log("PayPal success: $params");

                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("No hay usuario activo. Inicia sesión."),
                                ),
                              );
                            }
                            return;
                          }

                          await ProLocalDataSource().setPro(uid, true);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Pro activado")),
                            );
                            Navigator.pop(context);
                            Navigator.pop(context, true);
                          }
                        },
                        onError: (error) {
                          log("PayPal error: $error");
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Pago falló")),
                          );
                        },
                        onCancel: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Pago cancelado")),
                          );
                        },
                      ),
                    ),
                  );
                },
                child: const Text("Pagar con PayPal"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}