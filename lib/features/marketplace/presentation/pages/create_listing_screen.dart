import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/widgets/buttons/primary_button.dart';
import 'package:felo_na/core/widgets/inputs/custom_text_field.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_event.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_state.dart';

/// Create listing screen for adding new marketplace items.
///
/// Features:
/// - Image picker (up to 5 images)
/// - Title, description, price inputs
/// - Category selection
/// - Form validation
/// - BLoC integration
class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imagePicker = ImagePicker();
  
  List<XFile> _selectedImages = [];
  ListingCategory? _selectedCategory;
  final int _maxImages = 5;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (_selectedImages.length >= _maxImages) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maximum $_maxImages images allowed'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary500),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary500),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    }
    if (value.length < 3) {
      return 'Title must be at least 3 characters';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a description';
    }
    if (value.length < 10) {
      return 'Description must be at least 10 characters';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a price';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Please enter a valid price';
    }
    return null;
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Submit listing
    context.read<MarketplaceBloc>().add(
          CreateListingRequested(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            price: double.parse(_priceController.text),
            category: _selectedCategory!,
            imagePaths: _selectedImages.map((img) => img.path).toList(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        foregroundColor: AppColors.gray900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Listing',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.gray900,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Save as draft
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Draft saved!'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            child: const Text('Save Draft'),
          ),
        ],
      ),
      body: BlocListener<MarketplaceBloc, MarketplaceState>(
        listener: (context, state) {
          if (state is ListingCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Listing created successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          } else if (state is MarketplaceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<MarketplaceBloc, MarketplaceState>(
          builder: (context, state) {
            final isLoading = state is CreatingListing;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Picker Section
                    Text(
                      'Photos',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add up to $_maxImages photos',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildImagePicker(),
                    const SizedBox(height: 32),

                    // Title
                    CustomTextField(
                      label: 'Title',
                      hintText: 'Enter item title',
                      controller: _titleController,
                      validator: _validateTitle,
                      enabled: !isLoading,
                      prefixIcon: const Icon(Icons.title),
                    ),
                    const SizedBox(height: 16),

                    // Category
                    Text(
                      'Category',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.gray700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCategorySelection(isLoading),
                    const SizedBox(height: 16),

                    // Price
                    CustomTextField(
                      label: 'Price (USD)',
                      hintText: 'Enter price',
                      controller: _priceController,
                      validator: _validatePrice,
                      keyboardType: TextInputType.number,
                      enabled: !isLoading,
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    CustomTextField(
                      label: 'Description',
                      hintText: 'Describe your item',
                      controller: _descriptionController,
                      validator: _validateDescription,
                      maxLines: 5,
                      enabled: !isLoading,
                      prefixIcon: const Icon(Icons.description),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    PrimaryButton(
                      text: 'Publish Listing',
                      onPressed: isLoading ? null : _handleSubmit,
                      isLoading: isLoading,
                      icon: Icons.publish,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length + 1,
        itemBuilder: (context, index) {
          if (index == _selectedImages.length) {
            // Add image button
            return GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.gray300,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 40,
                      color: AppColors.gray500,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add Photo',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Image thumbnail
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: FileImage(File(_selectedImages[index].path)),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySelection(bool isLoading) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ListingCategory.values.map((category) {
        final isSelected = _selectedCategory == category;
        return GestureDetector(
          onTap: isLoading
              ? null
              : () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary500 : AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.primary500 : AppColors.gray300,
                width: 1,
              ),
            ),
            child: Text(
              category.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.white : AppColors.gray700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
