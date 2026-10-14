import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:society_seva/features/seller/presentation/provider/seller_provider.dart';
import 'package:society_seva/features/seller/presentation/widgets/seller_form_widget.dart';

class SellerOnboardingScreen extends ConsumerStatefulWidget {
  final bool? isEdit;
  const SellerOnboardingScreen({super.key, this.isEdit = false});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SellerOnboardingScreenState();
}

class _SellerOnboardingScreenState extends ConsumerState<SellerOnboardingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.invalidate(sellerProvider));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sellerAsync = ref.watch(sellerProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Regsiter as Seller', style: GoogleFonts.hind())),
      body: sellerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => SellerForm(initial: null),
        data: (seller) => SellerForm(initial: seller, isEdit: widget.isEdit),
      ),
    );
  }
}
