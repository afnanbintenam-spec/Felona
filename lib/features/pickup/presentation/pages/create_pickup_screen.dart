import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/widgets/buttons/primary_button.dart';
import 'package:felo_na/core/widgets/inputs/custom_text_field.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_bloc.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_event.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_state.dart';

/// Create pickup request screen.
///
/// Features:
/// - Waste category selection
/// - Weight estimation
/// - Address input with location
/// - Additional notes
/// - BLoC integration
class CreatePickupScreen extends StatefulWidget {
  const CreatePickupScreen({super.key});

  @override
  State<CreatePickupScreen> createState() => _CreatePickupScreenState();
}

class _CreatePickupScreenState extends State<CreatePickupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  
  WasteCategory? _selectedCategory;

  @override
  void dispose() {
    _weightController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter estimated weight';
    }
    final weight = double.tryParse(value);
    if (weight == null || weight <= 0) {
      return 'Please enter a valid weight';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter pickup address';
    }
    if (value.length < 10) {
      return 'Please enter a complete address';
    }
    return null;
  }

  void _useCurrentLocation() {
    // TODO: Implement location picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location picker coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a waste category'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Submit pickup request
    context.read<PickupBloc>().add(
          CreatePickupRequested(
            category: _selectedCategory!,
            estimatedWeight: double.parse(_weightController.text),
            address: _addressController.text.trim(),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
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
        title: Text(
          'Request Pickup',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.gray900,
          ),
        ),
      ),
      body: BlocListener<PickupBloc, PickupState>(
        listener: (context, state) {
          if (state is PickupCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Pickup request created! You\'ll earn ${(state.pickup.estimatedWeight * 10).toInt()} eco points when completed.',
                ),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 4),
              ),
            );
            Navigator.pop(context);
          } else if (state is PickupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<PickupBloc, PickupState>(
          builder: (context, state) {
            final isLoading = state is CreatingPickup;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.eco,
                            color: AppColors.primary500,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Earn eco points for every pickup! Help the environment and get rewarded.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Waste Category Selection
                    Text(
                      'Waste Category',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryGrid(isLoading),
                    const SizedBox(height: 24),

                    // Estimated Weight
                    CustomTextField(
                      label: 'Estimated Weight (kg)',
                      hintText: 'Enter weight in kilograms',
                      controller: _weightController,
                      validator: _validateWeight,
                      keyboardType: TextInputType.number,
                      enabled: !isLoading,
                      prefixIcon: const Icon(Icons.scale),
                    ),
                    const SizedBox(height: 16),

                    // Address
                    CustomTextField(
                      label: 'Pickup Address',
                      hintText: 'Enter your address',
                      controller: _addressController,
                      validator: _validateAddress,
                      maxLines: 3,
                      enabled: !isLoading,
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: isLoading ? null : _useCurrentLocation,
                      icon: const Icon(Icons.my_location, size: 18),
                      label: const Text('Use Current Location'),
                    ),
                    const SizedBox(height: 16),

                    // Additional Notes
                    CustomTextField(
                      label: 'Additional Notes (Optional)',
                      hintText: 'Any special instructions?',
                      controller: _notesController,
                      maxLines: 3,
                      enabled: !isLoading,
                      prefixIcon: const Icon(Icons.note),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    PrimaryButton(
                      text: 'Submit Request',
                      onPressed: isLoading ? null : _handleSubmit,
                      isLoading: isLoading,
                      icon: Icons.send,
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

  Widget _buildCategoryGrid(bool isLoading) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: WasteCategory.values.map((category) {
        return _buildCategoryCard(category, isLoading);
      }).toList(),
    );
  }

  Widget _buildCategoryCard(WasteCategory category, bool isLoading) {
    final isSelected = _selectedCategory == category;
    final color = Color(int.parse(category.colorHex.replaceFirst('#', '0xFF')));

    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              setState(() {
                _selectedCategory = category;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 40,
              color: isSelected ? color : AppColors.gray500,
            ),
            const SizedBox(height: 8),
            Text(
              category.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? color : AppColors.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(WasteCategory category) {
    switch (category) {
      case WasteCategory.plastic:
        return Icons.water_drop;
      case WasteCategory.metal:
        return Icons.hardware;
      case WasteCategory.paper:
        return Icons.description;
      case WasteCategory.glass:
        return Icons.local_bar;
      case WasteCategory.electronics:
        return Icons.devices;
      case WasteCategory.other:
        return Icons.inventory_2;
    }
  }
}
