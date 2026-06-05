import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
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
/// - Photo upload (required)
/// - Weight estimation
/// - Address input with location
/// - Phone number for contact
/// - Time slot selection
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
  final _phoneController = TextEditingController();
  final _imagePicker = ImagePicker();
  final List<XFile> _selectedPhotos = [];
  
  WasteCategory? _selectedCategory;
  PickupTimeSlot? _selectedTimeSlot;
  double? _pickedLatitude;
  double? _pickedLongitude;
  bool _locating = false;

  @override
  void dispose() {
    _weightController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _phoneController.dispose();
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

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required so the collector can contact you';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s-]{7,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location permission denied'),
            backgroundColor: AppColors.error,
          ));
        }
        return;
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please enable location services'),
            backgroundColor: AppColors.warning,
          ));
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Reverse geocode using OpenStreetMap Nominatim (free, no API key needed)
      String address =
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      try {
        final dio = Dio();
        final response = await dio.get(
          'https://nominatim.openstreetmap.org/reverse',
          queryParameters: {
            'lat': position.latitude,
            'lon': position.longitude,
            'format': 'json',
            'addressdetails': 1,
          },
          options: Options(
            headers: {'User-Agent': 'FeloNa/1.0 (felona.app)'},
            receiveTimeout: const Duration(seconds: 8),
          ),
        );
        final data = response.data as Map<String, dynamic>?;
        if (data != null) {
          // Use display_name for full address, or build from parts
          final addr = data['address'] as Map<String, dynamic>?;
          if (addr != null) {
            final parts = <String>[
              if (addr['road'] != null) addr['road'] as String,
              if (addr['suburb'] != null) addr['suburb'] as String
              else if (addr['neighbourhood'] != null) addr['neighbourhood'] as String,
              if (addr['city'] != null) addr['city'] as String
              else if (addr['town'] != null) addr['town'] as String
              else if (addr['village'] != null) addr['village'] as String,
              if (addr['state'] != null) addr['state'] as String,
            ];
            if (parts.isNotEmpty) address = parts.join(', ');
          } else if (data['display_name'] != null) {
            address = (data['display_name'] as String)
                .split(',')
                .take(4)
                .join(',')
                .trim();
          }
        }
      } catch (_) {
        // Nominatim failed — keep coordinates as fallback
      }

      if (mounted) {
        setState(() {
          _pickedLatitude = position.latitude;
          _pickedLongitude = position.longitude;
          _addressController.text = address;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not get location: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
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

    if (_selectedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one photo of the waste'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a preferred time slot'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Include phone number in notes for collector contact
    final phone = _phoneController.text.trim();
    final userNotes = _notesController.text.trim();
    final notesWithPhone = 'Contact: $phone${userNotes.isNotEmpty ? '\n$userNotes' : ''}';

    // Submit pickup request
    context.read<PickupBloc>().add(
          CreatePickupRequested(
            category: _selectedCategory!,
            estimatedWeight: double.parse(_weightController.text),
            address: _addressController.text.trim(),
            latitude: _pickedLatitude,
            longitude: _pickedLongitude,
            notes: notesWithPhone,
            timeSlot: _selectedTimeSlot,
          ),
        );
  }

  Future<void> _pickPhotos() async {
    try {
      final images = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (images.isNotEmpty && mounted) {
        setState(() {
          _selectedPhotos.addAll(images.take(5 - _selectedPhotos.length));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not pick images'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (image != null && mounted) {
        setState(() {
          if (_selectedPhotos.length < 5) {
            _selectedPhotos.add(image);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not take photo'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
          'Schedule a rescue 🚛',
          style: TextStyle(
            fontFamily: 'Finlandica',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: BlocListener<PickupBloc, PickupState>(
        listener: (context, state) {
          if (state is PickupCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Pickup request created! You\'ll earn eco points when the pickup is completed.',
                ),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 4),
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
                        color: AppColors.primaryGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryGreen.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.eco,
                            color: AppColors.primaryGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "We'll make sure it doesn't end up in a landfill. Earn eco points for every rescue!",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
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

                    // Photos (required)
                    Text(
                      'Photos of Waste *',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Add photos so the collector knows what to expect',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPhotoSection(isLoading),
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
                      onPressed: (isLoading || _locating) ? null : _useCurrentLocation,
                      icon: _locating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryGreen),
                            )
                          : const Icon(Icons.my_location, size: 18),
                      label: Text(_locating
                          ? 'Getting location...'
                          : 'Use Current Location'),
                    ),
                    const SizedBox(height: 16),

                    // Phone Number (required for collector contact)
                    CustomTextField(
                      label: 'Your Phone Number',
                      hintText: 'e.g. +880 1700 000000',
                      controller: _phoneController,
                      validator: _validatePhone,
                      keyboardType: TextInputType.phone,
                      enabled: !isLoading,
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Text(
                        'The collector will use this number to contact you',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Time Slot Selection
                    Text(
                      'Preferred Time',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'When should the collector come?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTimeSlotGrid(isLoading),
                    const SizedBox(height: 20),

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
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.white,
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

  Widget _buildPhotoSection(bool isLoading) {
    return Column(
      children: [
        // Photo grid
        if (_selectedPhotos.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedPhotos.length + (_selectedPhotos.length < 5 ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == _selectedPhotos.length) {
                  return _buildAddPhotoButton(isLoading);
                }
                return _buildPhotoThumbnail(index);
              },
            ),
          )
        else
          // Empty state — add photos
          GestureDetector(
            onTap: isLoading ? null : _pickPhotos,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_rounded,
                    size: 32,
                    color: AppColors.primaryGreen.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to add photos',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Text(
                    'Required — up to 5 photos',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPhotoThumbnail(int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: FutureBuilder<Uint8List>(
            future: _selectedPhotos[index].readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Image.memory(
                  snapshot.data!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                );
              }
              return Container(
                width: 100,
                height: 100,
                color: AppColors.surface,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryGreen,
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => setState(() => _selectedPhotos.removeAt(index)),
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _pickPhotos,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 24, color: AppColors.primaryGreen),
            SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotGrid(bool isLoading) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PickupTimeSlot.values.map((slot) {
        final isSelected = _selectedTimeSlot == slot;
        return GestureDetector(
          onTap: isLoading
              ? null
              : () => setState(() => _selectedTimeSlot = slot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryGreen.withValues(alpha: 0.12)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primaryGreen : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  slot.displayName,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  slot.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
