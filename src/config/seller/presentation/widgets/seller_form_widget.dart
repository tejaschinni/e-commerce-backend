import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:society_seva/features/profile/presentation/providers/profile_provider.dart';
import 'package:society_seva/features/seller/data/models/seller_profile_request.dart';
import 'package:society_seva/features/seller/domain/entities/seller_profile_entity.dart';
import 'package:society_seva/features/seller/presentation/provider/seller_provider.dart';
import 'package:society_seva/features/seller/presentation/on_boarding/widgets/image_grid_widget.dart';

class SellerForm extends ConsumerStatefulWidget {
  const SellerForm({this.initial, this.isEdit});
  final SellerProfileEntity? initial;
  final bool? isEdit;

  @override
  ConsumerState<SellerForm> createState() => SellerFormState();
}

class SellerFormState extends ConsumerState<SellerForm> {
  static const _sellerTypes = [
    'FOOD_SELLER',
    'SERVICE_PROVIDER',
    'PRODUCT_SELLER',
    'CONSULTANT',
    'TRAINER',
    'FREE_HELP_PROVIDER',
    'MIXED',
  ];
  static const _isFassaiRequired = [true, false];

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final _displayName = TextEditingController();
  late final _address = TextEditingController();
  late final _city = TextEditingController();
  late final _state = TextEditingController();
  late final _country = TextEditingController();
  late final _pincode = TextEditingController();
  late final _deliveryRadius = TextEditingController();
  late final _targetArea = TextEditingController();

  late final _businessName = TextEditingController();
  late final _bio = TextEditingController();
  late final _fassiCertificateID = TextEditingController();
  late final _socialMediaLinks = TextEditingController();
  late final _websiteUrl = TextEditingController();
  late final _legelCompliances = TextEditingController();
  String _sellerType = _sellerTypes.first;
  bool _isFassaiStatus = true;

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    if (s == null) return;
    // Adjust property names to match SellerProfileEntity.
    _displayName.text = s.displayName;
    _address.text = s.address;
    _city.text = s.city;
    _state.text = s.state;
    _country.text = s.country;
    _pincode.text = s.pinCode;
    _bio.text = s.bio.toString();
    _businessName.text = s.businessName.toString();
    _socialMediaLinks.text = s.socialMediaLinks.toString();
    _websiteUrl.text = s.websiteUrl.toString();
    _legelCompliances.text = s.legalCompliance.toString();
    _fassiCertificateID.text = s.fssaiCertificateId.toString();

    _deliveryRadius.text = s.deliveryRadiusKm?.toString() ?? '';
    _targetArea.text = s.targetArea ?? '';
    if (_sellerTypes.contains(s.sellerType)) _sellerType = s.sellerType;
    if (_isFassaiRequired.contains(s.fssaiRequired)) _isFassaiStatus = s.fssaiRequired;
  }

  @override
  void dispose() {
    _displayName.dispose();
    _address.dispose();
    _city.dispose();
    _state.dispose();
    _country.dispose();
    _pincode.dispose();
    _deliveryRadius.dispose();
    _targetArea.dispose();
    _businessName.dispose();
    _bio.dispose();
    _fassiCertificateID.dispose();
    _socialMediaLinks.dispose();
    _websiteUrl.dispose();
    _legelCompliances.dispose();
    super.dispose();
  }

  String get _userId => ref.read(profileControllerProvider).profile!.id.toString();

  String get _sellerID => widget.initial != null ? widget.initial!.id.toString() : "";

  Future<bool> _save() async {
    if (!_formKey.currentState!.validate()) return false;
    final fullAddress =
        '${_address.text.trim()}, ${_city.text.trim()}, ${_state.text.trim()}, ${_pincode.toString().trim()}, ${_country.text.trim()}';
    final locations = await Geocoding().locationFromAddress(fullAddress);

    return ref
        .read(sellerActionProvider.notifier)
        .save(
          SellerProfileRequest(
            userId: _userId,
            displayName: _displayName.text.trim(),
            sellerType: _sellerType,
            address: _address.text.trim(),
            city: _city.text.trim(),
            state: _state.text.trim(),
            country: _country.text.trim(),
            pinCode: _pincode.text.trim(),
            bio: _bio.text.trim(),
            businessName: _businessName.text.trim(),
            fssaiCertificateId: _fassiCertificateID.text.trim(),
            fssaiRequired: _isFassaiStatus,
            geofencePolygon: '',
            latitude: locations.first.latitude,
            longitude: locations.first.longitude,
            legalCompliance: _legelCompliances.text.trim(),
            socialMediaLinks: _socialMediaLinks.text.trim(),
            websiteUrl: _websiteUrl.text.trim(),
            // Add these two to SellerProfileRequest - they're not being sent today:
            deliveryRadiusKm: double.tryParse(_deliveryRadius.text.trim()),
            targetArea: _targetArea.text.trim(),
          ),
        );
  }

  Future<void> _onSavePressed() async {
    final ok = await _save();
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved')));
    }
  }

  Future<void> _onUpdateSellerProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final orig = widget.initial!; // the Seller the form was pre-filled from

    // null = unchanged, "" = cleared, otherwise the new value
    String? diff(TextEditingController c, String? original) {
      final now = c.text.trim();
      return now == (original ?? '').trim() ? null : now;
    }

    final address = diff(_address, orig.address);
    final city = diff(_city, orig.city);
    final state = diff(_state, orig.state);
    final country = diff(_country, orig.country);
    final pinCode = diff(_pincode, orig.pinCode);

    // Geocode only when something address-related changed
    double? lat, lng;
    final addressChanged = [address, city, state, country, pinCode].any((v) => v != null);
    if (addressChanged) {
      final fullAddress =
          '${_address.text.trim()}, ${_city.text.trim()}, ${_state.text.trim()}, '
          '${_pincode.text.trim()}, ${_country.text.trim()}';
      final locations = await Geocoding().locationFromAddress(fullAddress);
      if (locations.isNotEmpty) {
        lat = locations.first.latitude;
        lng = locations.first.longitude;
      }
    }

    final radius = double.tryParse(_deliveryRadius.text.trim());

    final request = SellerProfileRequest(
      userId: _userId, // identifier, always sent
      displayName: diff(_displayName, orig.displayName).toString(),
      businessName: diff(_businessName, orig.businessName),
      bio: diff(_bio, orig.bio),
      sellerType: _sellerType != orig.sellerType ? _sellerType : '',
      address: address.toString(),
      city: city.toString(),
      state: state.toString(),
      country: country.toString(),
      pinCode: pinCode.toString(),
      latitude: lat,
      longitude: lng,
      fssaiCertificateId: diff(_fassiCertificateID, orig.fssaiCertificateId),
      fssaiRequired: _isFassaiStatus != orig.fssaiRequired ? _isFassaiStatus : null,
      legalCompliance: diff(_legelCompliances, orig.legalCompliance),
      socialMediaLinks: diff(_socialMediaLinks, orig.socialMediaLinks),
      websiteUrl: diff(_websiteUrl, orig.websiteUrl),
      deliveryRadiusKm: radius != orig.deliveryRadiusKm ? radius : null,
      targetArea: diff(_targetArea, orig.targetArea),
    );

    if (request.isEmpty) {
      // nothing changed, skip the API call
      if (mounted) Navigator.pop(context, false);
      return;
    }

    final ok = await ref
        .read(sellerActionProvider.notifier)
        .updateSellerProfile(request, _sellerID);
    if (ok && mounted) Navigator.pop(context, true);
  }

  Future<void> _onSubmitPressed() async {
    // if (!await _save()) return; // don't submit if validation/save failed

    if (_sellerID != "") {
      final ok = await ref.read(sellerActionProvider.notifier).submitSellerProfile(_sellerID);
      if (ok && mounted) Navigator.pop(context, true);
    } else {
      if (!_formKey.currentState!.validate()) return;
      final fullAddress =
          '${_address.text.trim()}, ${_city.text.trim()}, ${_state.text.trim()}, ${_pincode.toString().trim()}, ${_country.text.trim()}';
      final locations = await Geocoding().locationFromAddress(fullAddress);

      final request = SellerProfileRequest(
        userId: _userId,
        displayName: _displayName.text.trim(),
        sellerType: _sellerType,
        address: _address.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        country: _country.text.trim(),
        pinCode: _pincode.text.trim(),
        bio: _bio.text.trim(),
        businessName: _businessName.text.trim(),
        fssaiCertificateId: _fassiCertificateID.text.trim(),
        fssaiRequired: _isFassaiStatus,
        latitude: locations.first.latitude,
        longitude: locations.first.longitude,
        legalCompliance: _legelCompliances.text.trim(),
        socialMediaLinks: _socialMediaLinks.text.trim(),
        websiteUrl: _websiteUrl.text.trim(),
        deliveryRadiusKm: double.tryParse(_deliveryRadius.text.trim()),
        targetArea: _targetArea.text.trim(),
      );
      final ok = await ref.read(sellerActionProvider.notifier).saveAndSubmit(request);
      if (ok && mounted) Navigator.pop(context, true);
    }
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
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return; // dismissed

    await _pickPhotos(source);
  }

  Future<void> _pickPhotos(ImageSource source) async {
    final notifier = ref.read(sellerActionProvider.notifier);

    if (source == ImageSource.camera) {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1600,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (file == null) return; // user cancelled
      notifier.addPendingImage(file);
    } else {
      final files = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1600,
        // limit: 10, // optional: cap how many can be selected at once
      );
      if (files.isEmpty) return; // user cancelled
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: keyboardType == null
            ? TextCapitalization.words
            : TextCapitalization.none,
        autovalidateMode: .always,
        validator: required ? _required : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Object?>(sellerActionProvider.select((s) => s.error), (prev, error) {
      if (error == null) return; // cleared at the start of each action
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.toString())));
    });

    final action = ref.watch(sellerActionProvider); // SellerActionState
    final isBusy = action.isBusy;
    final isPending = widget.initial?.approvalStatus == 'PENDING';

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _textField(_displayName, 'Display Name'),
          _textField(_businessName, 'Business Name', required: true),
          _textField(_bio, 'Bio'),
          DropdownButtonFormField<String>(
            initialValue: _sellerType,
            decoration: const InputDecoration(labelText: 'Seller Type'),
            items: _sellerTypes
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(_label(t.replaceAll('_', ' ')), style: GoogleFonts.hind()),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _sellerType = v ?? _sellerType),
          ),
          const Gap(20),
          DropdownButtonFormField<bool>(
            initialValue: _isFassaiStatus,
            decoration: const InputDecoration(labelText: 'FSSAI Required'),
            items: [
              DropdownMenuItem(value: true, child: Text('Yes', style: GoogleFonts.hind())),
              DropdownMenuItem(value: false, child: Text('No', style: GoogleFonts.hind())),
            ],
            onChanged: (v) => setState(() => _isFassaiStatus = v ?? _isFassaiStatus),
          ),
          const Gap(20),
          _textField(_fassiCertificateID, 'Fssai Certificate Id', required: _isFassaiStatus),
          _textField(_socialMediaLinks, 'Social Media Links', required: false),
          _textField(_websiteUrl, 'Website Url', required: false),
          _textField(_legelCompliances, 'Legal Compliance', required: false),
          _textField(_address, 'Address'),
          _textField(_city, 'City'),
          _textField(_state, 'State'),
          _textField(_country, 'Country'),
          _textField(_pincode, 'Pincode', keyboardType: TextInputType.number),
          _textField(_deliveryRadius, 'Delivery Radius', keyboardType: TextInputType.number),
          _textField(_targetArea, 'Target Area'),
          Row(
            children: [
              const Expanded(
                child: Text('Photos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final isBusy = ref.watch(sellerActionProvider.select((s) => s.isBusy));
                  final isUploading = ref.watch(sellerActionProvider.select((s) => s.isUploading));
                  return TextButton.icon(
                    onPressed: isBusy ? null : _onAddPhotosPressed,
                    icon: isUploading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Add photos'),
                  );
                },
              ),
            ],
          ),
          if (_sellerID == '')
            Text(
              'Save as draft to enable photo upload',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const Gap(28),
          if (_sellerID != '') ...[ImageGridWidget(sellerId: _sellerID)],
          const Gap(28),

          if (widget.isEdit == false) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // buttons stay on the left
              children: [
                _actionButton(
                  label: 'Save',
                  isLoading: action.isSaving, // spinner only while saving
                  disabled: isBusy || isPending,
                  onPressed: _onSavePressed,
                ),
                const Gap(12),
                _actionButton(
                  label: isPending ? 'Pending approval' : 'Submit',
                  isLoading: action.isSubmitting, // spinner only while submitting
                  disabled: isBusy || isPending,
                  onPressed: _onSubmitPressed,
                ),
              ],
            ),
          ],

          if (widget.isEdit == true) ...[
            _actionButton(
              label: 'Update',
              isLoading: action.isSubmitting, // spinner only while submitting
              disabled: isBusy || isPending,
              onPressed: _onUpdateSellerProfile,
            ),
          ],

          const Gap(28),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required bool isLoading,
    required bool disabled,
    required VoidCallback onPressed,
  }) {
    return FilledButton(
      onPressed: disabled ? null : onPressed,
      child: isLoading
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(label, style: GoogleFonts.hind()),
    );
  }

  String _label(String value) {
    final s = value.toLowerCase().replaceAll('_', ' ');
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }
}
