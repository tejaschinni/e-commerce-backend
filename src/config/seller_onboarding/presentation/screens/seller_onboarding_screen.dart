import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:society_seva/features/seller_onboarding/presentation/providers/seller_onboarding_provider.dart';
import 'package:society_seva/features/seller_onboarding/presentation/widgets/seller_onboarding_form.dart';

class SellerOnboardingScreen extends ConsumerWidget {
  const SellerOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(sellerOnboardingProfileProvider);

    // Once the user's existing profile (if any) loads, seed its id into the
    // action notifier so Save/Submit know a draft already exists instead of
    // trying to create a second one. `seed` no-ops once the id is already
    // set, so re-running this on every build is harmless.
    final existingId = profileAsync.valueOrNull?.id;
    if (existingId != null) {
      Future.microtask(
        () => ref.read(sellerOnboardingActionProvider.notifier).seed(existingId),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Register as seller', style: GoogleFonts.hind())),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => const SellerOnboardingForm(initial: null),
        data: (profile) => SellerOnboardingForm(initial: profile),
      ),
    );
  }
}
