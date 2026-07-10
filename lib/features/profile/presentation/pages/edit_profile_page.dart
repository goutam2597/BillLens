import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/router/context_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/data/repositories/user_repository.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final UserRepository _userRepo = getIt<UserRepository>();

  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _businessCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _zipCtrl;

  File? _pickedImage;
  bool _isSaving = false;
  bool _populated = false;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _businessCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _stateCtrl = TextEditingController();
    _zipCtrl = TextEditingController();
  }

  void _populateFromUser(UserEntity user) {
    if (_populated) return;
    _populated = true;
    _firstNameCtrl.text = user.firstName ?? user.name.split(' ').first;
    _lastNameCtrl.text = user.lastName ??
        (user.name.split(' ').length > 1 ? user.name.split(' ').last : '');
    _emailCtrl.text = user.email;
    _phoneCtrl.text = user.phone ?? '';
    _businessCtrl.text = user.businessName ?? '';
    _addressCtrl.text = user.address ?? '';
    _cityCtrl.text = user.city ?? '';
    _stateCtrl.text = user.state ?? '';
    _zipCtrl.text = user.zip ?? '';
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _businessCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85, maxWidth: 512);
    if (file != null) {
      setState(() => _pickedImage = File(file.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    final user = context.read<AuthBloc>().state;
    if (user is! Authenticated) return;

    setState(() => _isSaving = true);

    try {
      // Upload avatar if picked
      if (_pickedImage != null) {
        await _userRepo.uploadAvatar(
          userId: user.user.id,
          filePath: _pickedImage!.path,
        );
      }

      // Update profile
      final result = await _userRepo.updateProfile(
        userId: user.user.id,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        businessName: _businessCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        zip: _zipCtrl.text.trim(),
      );

      result.fold(
        (failure) {
          if (mounted) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        (updatedUser) {
          // Refresh auth state with updated user
          context.read<AuthBloc>().add(CheckAuthStatus());
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Profile updated'),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
            context.safePop(AppRoutes.profile);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is Authenticated ? state.user : null;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        _populateFromUser(user);

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          appBar: AppPageBar(
            title: 'Edit Profile',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.safePop(AppRoutes.profile),
            ),
            actions: [
              TextButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with image picker
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.surface,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2563EB)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              image: _pickedImage != null
                                  ? DecorationImage(
                                      image: FileImage(_pickedImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              gradient: _pickedImage == null
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF2563EB),
                                        Color(0xFF10B981)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                            ),
                            child: _pickedImage == null
                                ? Center(
                                    child: Text(
                                      user.initials,
                                      style: GoogleFonts.outfit(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Text(
                        'Tap to change photo',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: const Color(0xFF2563EB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const AppSectionHeader(title: 'Personal information'),
                  const SizedBox(height: 8),
                  AppGroupedSurface(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'First name',
                                controller: _firstNameCtrl,
                                prefixIcon: const Icon(Icons.person_outline),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Required'
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                label: 'Last name',
                                controller: _lastNameCtrl,
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Email address',
                          controller: _emailCtrl,
                          prefixIcon: const Icon(Icons.email_outlined),
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Phone number',
                          controller: _phoneCtrl,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const AppSectionHeader(title: 'Business details'),
                  const SizedBox(height: 8),
                  AppGroupedSurface(
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Business name',
                          controller: _businessCtrl,
                          prefixIcon: const Icon(Icons.business_outlined),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Street address',
                          controller: _addressCtrl,
                          prefixIcon: const Icon(Icons.location_on_outlined),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: AppTextField(
                                label: 'City',
                                controller: _cityCtrl,
                                prefixIcon:
                                    const Icon(Icons.location_city_outlined),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                label: 'State',
                                controller: _stateCtrl,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                label: 'ZIP',
                                controller: _zipCtrl,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Save changes',
                    onPressed: _isSaving ? null : _save,
                    isLoading: _isSaving,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
