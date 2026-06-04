import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/services/gemini_service.dart';
import 'package:felo_na/core/widgets/buttons/primary_button.dart';
import 'package:felo_na/core/widgets/inputs/custom_text_field.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_event.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_state.dart';

/// Draft data holder — survives screen pop but not app restart.
class _ListingDraft {
  final String title;
  final String description;
  final String price;
  final ListingCategory? category;

  const _ListingDraft({
    required this.title,
    required this.description,
    required this.price,
    required this.category,
  });
}

/// Create listing screen for adding new marketplace items.
///
/// Features:
/// - Image picker (up to 5 images)
/// - Title, description, price inputs
/// - Category selection
/// - Form validation
/// - BLoC integration
/// - Save draft (in-memory, persists across navigations within the session)
class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  // Session-level draft — shared across screen instances
  static _ListingDraft? _savedDraft;

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imagePicker = ImagePicker();
  
  final List<XFile> _selectedImages = [];
  ListingCategory? _selectedCategory;
  final int _maxImages = 5;
  bool _isSuggestingPrice = false;
  String? _priceSuggestion;

  @override
  void initState() {
    super.initState();
    // Restore saved draft if one exists
    final draft = CreateListingScreen._savedDraft;
    if (draft != null) {
      _titleController.text = draft.title;
      _descriptionController.text = draft.description;
      _priceController.text = draft.price;
      _selectedCategory = draft.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveDraft() {
    CreateListingScreen._savedDraft = _ListingDraft(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: _priceController.text.trim(),
      category: _selectedCategory,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved — it\'ll be here when you return'),
        backgroundColor: AppColors.info,
      ),
    );
    Navigator.pop(context);
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

  Future<void> _suggestPrice() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a title first so AI can suggest a price'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isSuggestingPrice = true;
      _priceSuggestion = null;
    });

    try {
      final gemini = GeminiService();
      final condition = 'Used'; // default; could be a field in the future
      final category = _selectedCategory?.displayName ?? 'General';
      final suggestion = await gemini.suggestPrice(title, condition, category);
      setState(() => _priceSuggestion = suggestion);
      if (mounted) {
        _showPriceSuggestionDialog(suggestion);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Price suggestion failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSuggestingPrice = false);
    }
  }

  void _showPriceSuggestionDialog(String suggestion) {
    // Extract numeric value if present, e.g. "Estimated: ৳500 - ৳800"
    final regex = RegExp(r'৳(\d+)');
    final matches = regex.allMatches(suggestion).toList();
    final avgPrice = matches.isNotEmpty
        ? ((int.tryParse(matches.first.group(1) ?? '') ?? 0) +
                (matches.length > 1
                    ? (int.tryParse(matches.last.group(1) ?? '') ?? 0)
                    : 0)) ~/
            (matches.length > 1 ? 2 : 1)
        : null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome,
                  color: AppColors.primaryGreen, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'AI Price Suggestion',
              style: TextStyle(
                fontFamily: 'Finlandica',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              suggestion,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss',
                style: TextStyle(color: AppColors.textTertiary)),
          ),
          if (avgPrice != null && avgPrice > 0)
            TextButton(
              onPressed: () {
                _priceController.text = avgPrice.toString();
                Navigator.pop(context);
              },
              child: const Text(
                'Use This Price',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Give it a second life',
          style: TextStyle(
            fontFamily: 'Finlandica',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveDraft,
            child: const Text('Save Draft'),
          ),
        ],
      ),
      body: BlocListener<MarketplaceBloc, MarketplaceState>(
        listener: (context, state) {
          if (state is ListingCreated) {
            // Clear any saved draft on successful publish
            CreateListingScreen._savedDraft = null;
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
                    // Subtitle
                    const Text(
                      'Someone out there needs exactly this',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),

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
                      label: 'Price (৳)',
                      hintText: 'Enter price in Taka',
                      controller: _priceController,
                      validator: _validatePrice,
                      keyboardType: TextInputType.number,
                      enabled: !isLoading,
                      prefixIcon: const Icon(Icons.currency_exchange),
                    ),
                    const SizedBox(height: 8),
                    // AI price suggestion button
                    GestureDetector(
                      onTap: isLoading || _isSuggestingPrice
                          ? null
                          : _suggestPrice,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryGreen
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isSuggestingPrice)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryGreen,
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              const Icon(Icons.auto_awesome,
                                  color: AppColors.primaryGreen, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              _isSuggestingPrice
                                  ? 'Getting AI suggestion…'
                                  : '✨ Suggest price with AI',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
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
          return FutureBuilder<Uint8List>(
            future: _selectedImages[index].readAsBytes(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: MemoryImage(snapshot.data!),
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
