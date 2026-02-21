import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/offer_service.dart';

// Minimal, compile-safe Offer Management screen.
class OfferManagementScreen extends StatelessWidget {
  const OfferManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offer Management')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Offer management UI coming soon'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Placeholder action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Open offer editor (TBD)')),
                );
              },
              child: const Text('Manage Offers'),
            ),
          ],
        ),
      ),
    );
  }
}
