import 'package:flutter/material.dart';
import 'package:society_seva/features/common/presentation/screens/common_modules_screen.dart';

class SellerModulesScreen extends StatelessWidget {
  const SellerModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholderScreen(
      title: 'Seller',
      modules: [
        'Seller profile',
        'Seller and kitchen images',
        'Seller KYC',
        'Seller certificates',
        'Listings',
        'Food details',
        'Listing images',
        'Service details',
        'Accept and process orders',
        'Delivery details',
        'Accept cash payment',
        'Reply to reviews',
        'Reject review',
      ],
    );
  }
}
