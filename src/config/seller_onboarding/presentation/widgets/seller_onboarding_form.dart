import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:society_seva/features/profile/presentation/providers/profile_provider.dart';
import 'package:society_seva/features/seller_onboarding/data/models/seller_profile_request.dart';
import 'package:society_seva/features/seller_onboarding/domain/entities/seller_profile_entity.dart';
import 'package:society_seva/features/seller_onboarding/presentation/providers/seller_onboarding_provider.dart';
import 'package:society_seva/features/seller_onboarding/presentation/widgets/seller_onboarding_image_grid.dart';

class SellerOnboardingForm extends ConsumerStatefulWidget {
  const SellerOnboardingForm({super.key, this.initial});

  /// The user's existing seller profile, if any. When present the form is
  /// pre-filled and Save/Submit act on that draft instead of creating a new
  /// one (seeded into `sellerOnboardingActionProvider` by the parent screen).
  final SellerProfileEntity? initial;

  @override
  ConsumerState<SellerOnboardingForm> createState() => _SellerOnboardingFormState();
}

class _SellerOnboardingFormState extends ConsumerState<SellerOnboardingForm> {
  static const _sellerTypes = [
    'FOOD_SELLER',
    'SERVICE_PROVIDER',
    'PRODUCT_SELLER',
    'CONSULTANT',
    'TRAINER',
    'FREE_HELP_PROVIDER',
    'MIXED',
  ];

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _displayName = TextEditingController();
  final _businessName = TextEditingController();
  final _bio = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _country = TextEditingController();
  final _pincode = TextEditingController();
  final _deliveryRadius = TextEditingController();
  final _targetArea = TextEditingController();
  final _fssaiCertificateId = TextEditingController();
  final _socialMediaLinks = TextEditingController();
  final _websiteUrl = TextEditingController();
  final _legalCompliance = TextEditingController();

  String _sellerType = _sellerTypes.first;
  bool _fssaiRequired = true;

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    if (s == null) return;

    _displayName.text = s.displayName;
    _businessName.text = s.businessName ?? '';
    _bio.text = s.bio ?? '';
    _address.text = s.address;
    _city.text = s.city;
    _state.text = s.state;
    _country.text = s.country;
    _pincode.text = s.pinCode;
    _deliveryRadius.text = s.deliveryRadiusKm?.toString() ?? '';
    _targetArea.text = s.targetArea ?? '';
    _fssaiCertificateId.text = s.fssaiCertificateId ?? '';
    _socialMediaLinks.text = s.socialMediaLinks ?? '';
    _websiteUrl.text = s.websiteUrl ?? '';
    _legalCompliance.text = s.legalCompliance ?? '';
    if (_sellerTypes.contains(s.sellerType)) _sellerType = s.sellerType;
    _fssaiRequired = s.fssaiRequired;
  }

  @override
  void dispose() {
    _displayName.dispose();
    _businessName.dispose();
    _bio.dispose();
    _address.dispose();
    _city.dispose();
    _state.dispose();
    _country.dispose();
    _pincode.dispose();
    _deliveryRadius.dispose();
    _targetArea.dispose();
    _fssaiCertificateId.dispose();
    _socialMediaLinks.dispose();
    _websiteUrl.dispose();
    _legalCompliance.dispose();
    super.dispose();
  }

  String get _userId => ref.read(profileControllerProvider).profile?.id.toString() ?? '';

  Future<({double lat, double lng})?> _geocode() async {
    final fullAddress =
        '${_address.text.trim()}, ${_city.text.trim()}, ${_state.text.trim()}, '
        '${_pincode.text.trim()}, ${_country.text.trim()}';
    try {
      final results = await Geocoding().locationFromAddress(fullAddress);
      if (results.isEmpty) return null;
      return (lat: results.first.latitude, lng: results.first.longitude);
    } catch (_) {
      return null;
    }
  }

  /// Validates the form, geocodes the address, and builds the request. Shows
  /// a friendly error and returns null instead of throwing, so a bad address
  /// or a not-yet-loaded user profile can't crash Save/Submit.
  Future<SellerProfileRequest?> _buildRequest() async {
    if (!_formKey.currentState!.validate()) return null;

    final userId = _userId;
    if (userId.isEmpty) {
      _showError('Your profile is still loading. Please try again in a moment.');
      return null;
    }

    final coordinates = await _geocode();
    if (coordinates == null) {
      _showError('Could not find this address. Please check it and try again.');
      return null;
    }

    return SellerProfileRequest(
      userId: userId,
      displayName: _displayName.text.trim(),
      sellerType: _sellerType,
      address: _address.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      country: _country.text.trim(),
      pinCode: _pincode.text.trim(),
      bio: _bio.text.trim(),
      businessName: _businessName.text.trim(),
      fssaiCertificateId: _fssaiCertificateId.text.trim(),
      fssaiRequired: _fssaiRequired,
      latitude: coordinates.lat,
      longitude: coordinates.lng,
      legalCompliance: _legalCompliance.text.trim(),
      socialMediaLinks: _socialMediaLinks.text.trim(),
      websiteUrl: _websiteUrl.text.trim(),
      deliveryRadiusKm: double.tryParse(_deliveryRadius.text.trim()),
      targetArea: _targetArea.text.trim(),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onSavePressed() async {
    final request = await _buildRequest();
    if (request == null) return;

    final ok = await ref.read(sellerOnboardingActionProvider.notifier).saveDraft(request);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved')));
    }
  }

  Future<void> _onSubmitPressed() async {
    final request = await _buildRequest();
    if (request == null) return;

    final ok = await ref.read(sellerOnboardingActionProvider.notifier).submitDraft(request);
    if (ok && mounted) Navigator.pop(context, true);
  }

  Future<void> _onAddPhotosPressed() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const HugeIcon(icon: HugeIcons.strokeRoundedCamera01),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const HugeIcon(icon: HugeIcons.strokeRoundedImageAdd01),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return; // dismissed

    final notifier = ref.read(sellerOnboardingActionProvider.notifier);
    if (source == ImageSource.camera) {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1600,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (file != null) notifier.addPendingImage(file);
    } else {
      final files = await _picker.pickMultiImage(imageQuality: 80, maxWidth: 1600);
      for (final file in files) {
        notifier.addPendingImage(file);
      }
    }
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  Widget _textField(
    TextEditingController controller,
    String label, {
    bool required = true,
    TextInputType? keyboardType,
    List<List<dynamic>>? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: keyboardType == null
            ? TextCapitalization.words
            : TextCapitalization.none,
        validator: required ? _required : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon == null ? null : Padding(padding: const EdgeInsets.all(12), child: HugeIcon(icon: icon, size: 20)),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required List<List<dynamic>> icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(icon: icon, size: 20, color: Theme.of(context).colorScheme.primary),
                const Gap(8),
                Text(
                  title,
                  style: GoogleFonts.hind(textStyle: Theme.of(context).textTheme.titleMedium),
                ),
              ],
            ),
            const Gap(12),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Object?>(sellerOnboardingActionProvider.select((s) => s.error), (previous, error) {
      if (error == null) return; // cleared at the start of each action
      _showError(error.toString());
    });

    final action = ref.watch(sellerOnboardingActionProvider);
    final isBusy = action.isBusy;
    final isPending = widget.initial?.approvalStatus.toUpperCase() == 'PENDING';

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionCard(
            icon: HugeIcons.strokeRoundedStore01,
            title: 'Business details',
            children: [
              _textField(_displayName, 'Display Name', icon: HugeIcons.strokeRoundedIdentification),
              _textField(_businessName, 'Business Name', icon: HugeIcons.strokeRoundedBriefcase01),
              _textField(_bio, 'Bio', required: false, icon: HugeIcons.strokeRoundedNote01),
              DropdownButtonFormField<String>(
                initialValue: _sellerType,
                decoration: InputDecoration(
                  labelText: 'Seller Type',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: HugeIcon(icon: HugeIcons.strokeRoundedTaxes, size: 20),
                  ),
                ),
                items: _sellerTypes
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(_label(t), style: GoogleFonts.hind()),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _sellerType = v ?? _sellerType),
              ),
            ],
          ),
          _sectionCard(
            icon: HugeIcons.strokeRoundedShieldCheck,
            title: 'Compliance',
            children: [
              DropdownButtonFormField<bool>(
                initialValue: _fssaiRequired,
                decoration: InputDecoration(
                  labelText: 'FSSAI Required',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: HugeIcon(icon: HugeIcons.strokeRoundedShieldCheck, size: 20),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: true, child: Text('Yes', style: GoogleFonts.hind())),
                  DropdownMenuItem(value: false, child: Text('No', style: GoogleFonts.hind())),
                ],
                onChanged: (v) => setState(() => _fssaiRequired = v ?? _fssaiRequired),
              ),
              const Gap(16),
              _textField(
                _fssaiCertificateId,
                'FSSAI Certificate Id',
                required: _fssaiRequired,
                icon: HugeIcons.strokeRoundedCertificate01,
              ),
              _textField(
                _legalCompliance,
                'Legal Compliance',
                required: false,
                icon: HugeIcons.strokeRoundedScale,
              ),
            ],
          ),
          _sectionCard(
            icon: HugeIcons.strokeRoundedGlobe02,
            title: 'Online presence',
            children: [
              _textField(
                _socialMediaLinks,
                'Social Media Links',
                required: false,
                icon: HugeIcons.strokeRoundedShare01,
              ),
              _textField(
                _websiteUrl,
                'Website Url',
                required: false,
                icon: HugeIcons.strokeRoundedGlobe02,
              ),
            ],
          ),
          _sectionCard(
            icon: HugeIcons.strokeRoundedPinLocation01,
            title: 'Address & delivery',
            children: [
              _textField(_address, 'Address', icon: HugeIcons.strokeRoundedPinLocation01),
              _textField(_city, 'City', icon: HugeIcons.strokeRoundedBuilding02),
              _textField(_state, 'State'),
              _textField(_country, 'Country'),
              _textField(
                _pincode,
                'Pincode',
                keyboardType: TextInputType.number,
                icon: HugeIcons.strokeRoundedMapPin,
              ),
              _textField(
                _deliveryRadius,
                'Delivery Radius (km)',
                required: false,
                keyboardType: TextInputType.number,
                icon: HugeIcons.strokeRoundedDeliveryTruck01,
              ),
              _textField(
                _targetArea,
                'Target Area',
                required: false,
                icon: HugeIcons.strokeRoundedTarget01,
              ),
            ],
          ),
          _sectionCard(
            icon: HugeIcons.strokeRoundedCameraAdd01,
            title: 'Photos',
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: isBusy ? null : _onAddPhotosPressed,
                  icon: action.isUploadingImages
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const HugeIcon(icon: HugeIcons.strokeRoundedCameraAdd01, size: 18),
                  label: const Text('Add photos'),
                ),
              ),
              const Gap(4),
              const SellerOnboardingImageGrid(),
            ],
          ),
          const Gap(8),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  label: 'Save as draft',
                  icon: HugeIcons.strokeRoundedFloppyDisk,
                  isLoading: action.isSaving,
                  disabled: isBusy || isPending,
                  onPressed: _onSavePressed,
                  filled: false,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _actionButton(
                  label: isPending ? 'Pending approval' : 'Submit',
                  icon: isPending ? HugeIcons.strokeRoundedHourglass : HugeIcons.strokeRoundedSend,
                  isLoading: action.isSubmitting,
                  disabled: isBusy || isPending,
                  onPressed: _onSubmitPressed,
                  filled: true,
                ),
              ),
            ],
          ),
          const Gap(24),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required List<List<dynamic>> icon,
    required bool isLoading,
    required bool disabled,
    required VoidCallback onPressed,
    required bool filled,
  }) {
    final child = isLoading
        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
        : HugeIcon(icon: icon, size: 18);

    if (filled) {
      return FilledButton.icon(
        onPressed: disabled ? null : onPressed,
        icon: child,
        label: Text(label, style: GoogleFonts.hind()),
      );
    }
    return OutlinedButton.icon(
      onPressed: disabled ? null : onPressed,
      icon: child,
      label: Text(label, style: GoogleFonts.hind()),
    );
  }

  String _label(String value) {
    final s = value.toLowerCase().replaceAll('_', ' ');
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }
}
