import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpoddemo/features/profile_form/presentation/controllers/form_controller.dart';
import 'package:riverpoddemo/features/profile_form/presentation/controllers/form_state.dart';
import 'package:riverpoddemo/features/profile_form/presentation/views/widgets/image_picker_preview_widget.dart';

class FormScreen extends ConsumerStatefulWidget {
  const FormScreen({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends ConsumerState<FormScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  // Text fields are only seeded once, right after the initial load - after
  // that, edits flow one-way from the controllers into the notifier so the
  // cursor/selection is never disturbed by state rebuilds.
  bool _fieldsSeeded = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _seedControllers(ProfileFormState state) {
    if (_fieldsSeeded) return;
    _fullNameController.text = state.fullName;
    _emailController.text = state.email;
    _phoneController.text = state.phoneNumber;
    _bioController.text = state.bio;
    _fieldsSeeded = true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = formControllerProvider(widget.userId);
    final asyncState = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    ref.listen(provider, (previous, next) {
      final previousError = previous?.valueOrNull?.errorMessage;
      final nextState = next.valueOrNull;
      if (nextState == null) return;

      if (nextState.errorMessage != null && nextState.errorMessage != previousError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(nextState.errorMessage!)));
      }

      final wasSubmitted = previous?.valueOrNull?.isSubmitted ?? false;
      if (nextState.isSubmitted && !wasSubmitted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Form submitted successfully.')));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Failed to load form: $error')),
        data: (state) {
          _seedControllers(state);
          return _FormBody(
            state: state,
            notifier: notifier,
            fullNameController: _fullNameController,
            emailController: _emailController,
            phoneController: _phoneController,
            bioController: _bioController,
          );
        },
      ),
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.state,
    required this.notifier,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.bioController,
  });

  final ProfileFormState state;
  final FormController notifier;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController bioController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ImagePickerPreviewWidget(
              localImageFile: state.localImageFile,
              remoteImageUrl: state.remoteImageUrl,
              isUploading: state.isUploadingImage,
              onTap: state.isBusy ? null : notifier.pickImage,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: fullNameController,
            decoration: const InputDecoration(labelText: 'Full name'),
            onChanged: notifier.updateFullName,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            onChanged: notifier.updateEmail,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: 'Phone number'),
            keyboardType: TextInputType.phone,
            onChanged: notifier.updatePhoneNumber,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bioController,
            decoration: const InputDecoration(labelText: 'Bio'),
            maxLines: 3,
            onChanged: notifier.updateBio,
          ),
          const SizedBox(height: 16),
          _DraftStatus(state: state),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: state.isBusy ? null : notifier.saveDraft,
                  child: state.isSavingDraft
                      ? const _ButtonSpinner()
                      : const Text('Save Draft'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: state.isBusy ? null : notifier.submit,
                  child: state.isSubmitting
                      ? const _ButtonSpinner(color: Colors.white)
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DraftStatus extends StatelessWidget {
  const _DraftStatus({required this.state});

  final ProfileFormState state;

  @override
  Widget build(BuildContext context) {
    if (state.isSubmitted) {
      return const Text('Submitted', style: TextStyle(color: Colors.green));
    }
    if (state.isDraftSaved) {
      return Text('Draft saved', style: TextStyle(color: Theme.of(context).colorScheme.primary));
    }
    return const Text('Unsaved changes', style: TextStyle(color: Colors.orange));
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner({this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      width: 16,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }
}
