import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';
import 'package:felo_na/core/widgets/buttons/primary_button.dart';
import 'package:felo_na/core/widgets/inputs/custom_text_field.dart';
import 'package:felo_na/features/auth/domain/entities/user.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_event.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_state.dart';

/// Profile screen displaying user information and allowing edits.
///
/// Features:
/// - Displays user profile picture, name, email, role, phone number
/// - Allows editing name and phone number
/// - Image picker for profile picture upload (JPEG/PNG, max 5MB)
/// - Wired to AuthBloc for state management
/// - Logout functionality
///
/// Requirements: 3.1, 3.2, 3.3
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _isEditing = false;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final state = context.read<AuthBloc>().state;
    if (state is Authenticated) {
      _fullNameController.text = state.user.fullName;
      _phoneController.text = state.user.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    final phoneRegex = RegExp(r'^\+?[\d\s-]{7,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates the selected image file.
  /// Only JPEG and PNG formats are allowed, with a max size of 5MB.
  bool _validateImage(XFile file) {
    final extension = file.path.split('.').last.toLowerCase();
    final allowedExtensions = ['jpg', 'jpeg', 'png'];

    if (!allowedExtensions.contains(extension)) {
      _showError('Only JPEG and PNG images are allowed');
      return false;
    }

    return true;
  }

  /// Validates image file size asynchronously.
  /// Returns true if the file is within the 5MB limit.
  Future<bool> _validateImageSize(XFile file) async {
    final fileSize = await file.length();
    const maxSize = 5 * 1024 * 1024; // 5MB

    if (fileSize > maxSize) {
      _showError('Image must be less than 5MB');
      return false;
    }

    return true;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      // Validate format
      if (!_validateImage(image)) return;

      // Validate size
      if (!await _validateImageSize(image)) return;

      setState(() {
        _selectedImagePath = image.path;
      });

      // Upload the image via AuthBloc
      if (mounted) {
        context.read<AuthBloc>().add(
              UploadProfilePictureRequested(imagePath: image.path),
            );
      }
    } catch (e) {
      _showError('Failed to pick image. Please try again.');
    }
  }

  void _handleSaveProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            UpdateProfileRequested(
              fullName: _fullNameController.text.trim(),
              phoneNumber: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
            ),
          );
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Log Out',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.gray900),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.gray500),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            child: Text(
              'Log Out',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gray900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.gray900),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary500),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.gray500),
              onPressed: () {
                setState(() => _isEditing = false);
                _initializeFields();
              },
            ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            _showError(state.message);
          } else if (state is ProfileUpdated) {
            _showSuccess('Profile updated successfully');
          } else if (state is ProfilePictureUploaded) {
            _showSuccess('Profile picture updated');
            setState(() {
              _selectedImagePath = null;
            });
          } else if (state is Unauthenticated) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        buildWhen: (previous, current) {
          // Rebuild on Authenticated, AuthLoading, ProfilePictureUploading states
          return current is Authenticated ||
              current is AuthLoading ||
              current is ProfilePictureUploading;
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary500,
              ),
            );
          }

          User? user;
          if (state is Authenticated) {
            user = state.user;
          }

          if (user == null) {
            return const Center(
              child: Text(
                'Unable to load profile',
                style: AppTextStyles.bodyLarge,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Picture Section
                  _buildProfilePicture(user, state),
                  const SizedBox(height: 24),

                  // User Info Section
                  _buildUserInfoSection(user),
                  const SizedBox(height: 32),

                  // Edit Form or Display Section
                  if (_isEditing) ...[
                    _buildEditForm(user),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: 'Save Changes',
                      onPressed: _handleSaveProfile,
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Logout Button
                  _buildLogoutButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfilePicture(User user, AuthState state) {
    final isUploading = state is ProfilePictureUploading;

    return Center(
      child: Stack(
        children: [
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary500,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary500.withValues(alpha: 0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: _buildProfileImage(user),
            ),
          ),

          // Upload indicator
          if (isUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.black.withValues(alpha: 0.5),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              ),
            ),

          // Camera button
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: isUploading ? null : _pickImage,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary500,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.black,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(User user) {
    if (_selectedImagePath != null) {
      return Image.file(
        File(_selectedImagePath!),
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      );
    }

    if (user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty) {
      return Image.network(
        user.profilePictureUrl!,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderAvatar(user),
      );
    }

    return _buildPlaceholderAvatar(user);
  }

  Widget _buildPlaceholderAvatar(User user) {
    return Container(
      width: 100,
      height: 100,
      color: AppColors.gray100,
      child: Center(
        child: Text(
          user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
          style: AppTextStyles.displayLarge.copyWith(
            color: AppColors.primary500,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(User user) {
    return Column(
      children: [
        // Name
        Text(
          user.fullName,
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.gray900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // Role Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary500.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            user.role.displayName,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary500,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Info Cards
        _buildInfoCard(
          icon: Icons.email_outlined,
          label: 'Email',
          value: user.email,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: user.phoneNumber ?? 'Not set',
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          icon: Icons.eco_outlined,
          label: 'Eco Points',
          value: '${user.ecoPoints} pts',
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gray300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary500, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edit Profile',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 16),

        // Full Name (editable)
        CustomTextField(
          label: 'Full Name',
          hintText: 'Enter your full name',
          controller: _fullNameController,
          validator: _validateFullName,
          prefixIcon: const Icon(Icons.person_outline),
        ),
        const SizedBox(height: 16),

        // Email (read-only)
        CustomTextField(
          label: 'Email',
          hintText: user.email,
          controller: TextEditingController(text: user.email),
          enabled: false,
          prefixIcon: const Icon(Icons.email_outlined),
        ),
        const SizedBox(height: 16),

        // Phone Number (editable)
        CustomTextField(
          label: 'Phone Number',
          hintText: 'Enter your phone number',
          controller: _phoneController,
          validator: _validatePhone,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined),
        ),
        const SizedBox(height: 16),

        // Role (read-only)
        CustomTextField(
          label: 'Role',
          hintText: user.role.displayName,
          controller: TextEditingController(text: user.role.displayName),
          enabled: false,
          prefixIcon: const Icon(Icons.badge_outlined),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: Text(
          'Log Out',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.error,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: AppColors.error,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
