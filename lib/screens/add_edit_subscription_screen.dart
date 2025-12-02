import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../models/preset_service.dart';
import '../providers/providers.dart';
import '../core/constants/app_colors.dart';

class AddEditSubscriptionScreen extends ConsumerStatefulWidget {
  final String? subscriptionId;

  const AddEditSubscriptionScreen({super.key, this.subscriptionId});

  @override
  ConsumerState<AddEditSubscriptionScreen> createState() =>
      _AddEditSubscriptionScreenState();
}

class _AddEditSubscriptionScreenState
    extends ConsumerState<AddEditSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String? _selectedPresetName;
  final _serviceNameController = TextEditingController();
  final _costController = TextEditingController();
  final _currencyController = TextEditingController();
  String? _customColorHex;
  String? _logoUrl; // Added logoUrl state

  BillingCycle _billingCycle = BillingCycle.monthly;
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));
  bool _isAutoRenew = true;
  bool _isCustomEntry = false;
  bool _isLoading = false;
  bool _showAllPresets = false;

  @override
  void initState() {
    super.initState();
    _loadExistingSubscription();
  }

  // ... (existing code)

  Widget _buildPresetGrid() {
    final displayedPresets = _showAllPresets
        ? presetServices
        : presetServices.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select a Service',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _showAllPresets = !_showAllPresets;
                });
              },
              child: Text(
                _showAllPresets ? 'Show Less' : 'See All',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8, // Reduced gap
            mainAxisSpacing: 8, // Reduced gap
            childAspectRatio: 1.0, // More compact vertical layout
          ),
          itemCount: displayedPresets.length,
          itemBuilder: (context, index) {
            final preset = displayedPresets[index];
            final isSelected = _selectedPresetName == preset.name;
            final brandColor = _parseColor(preset.colorHex);

            return InkWell(
              onTap: () => _selectPreset(preset),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? brandColor.withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? brandColor.withOpacity(0.5)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52, // Slightly smaller to fit better
                      height: 52,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? brandColor.withOpacity(0.1)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: brandColor.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: preset.logoUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  preset.logoUrl!,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      preset.name[0],
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? brandColor
                                            : AppColors.textSecondary,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                preset.name[0],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? brandColor
                                      : AppColors.textSecondary,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8), // Reduced spacing
                    // Service Name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        preset.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1, // Limit to 1 line for compactness
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _loadExistingSubscription() {
    if (widget.subscriptionId != null) {
      final subscription = ref
          .read(subscriptionListProvider.notifier)
          .getSubscription(widget.subscriptionId!);

      if (subscription != null) {
        setState(() {
          _isCustomEntry = true;
          _serviceNameController.text = subscription.serviceName;
          _costController.text = subscription.cost.toString();
          _currencyController.text = subscription.currency;
          _billingCycle = subscription.billingCycle;
          _nextBillingDate = subscription.nextBillingDate;
          _isAutoRenew = subscription.isAutoRenew;
          _customColorHex = subscription.colorHex;
          _logoUrl = subscription.logoUrl; // Load existing logo URL
        });
      }
    }
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _costController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.subscriptionId == null
              ? 'Add Subscription'
              : 'Edit Subscription',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.subscriptionId == null) ...[
                      // Custom Segmented Control
                      _buildEntryModeSelector(),
                      const SizedBox(height: 32),

                      if (!_isCustomEntry) ...[
                        // Preset service grid
                        _buildPresetGrid(),
                        const SizedBox(height: 32),
                      ],
                    ],

                    // Form fields
                    _buildFormFields(),

                    const SizedBox(height: 40),

                    // Save button
                    _buildSaveButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEntryModeSelector() {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30), // Fully rounded
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        children: [
          // Sliding Active Indicator
          AnimatedAlign(
            alignment: !_isCustomEntry
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Solid white
                  borderRadius: BorderRadius.circular(
                    24,
                  ), // Fully rounded inner
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Text Labels
          Row(
            children: [
              _buildSelectorButton('Preset Services', !_isCustomEntry),
              _buildSelectorButton('Custom Entry', _isCustomEntry),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorButton(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isCustomEntry = label == 'Custom Entry';
            if (!_isCustomEntry) _selectedPresetName = null;
          });
        },
        child: Container(
          color: Colors.transparent, // Hit test area
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontFamily: 'Roboto', // Ensure font consistency
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Colors.black
                  : AppColors.textSecondary, // Black text when selected
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    String currencyCode,
    String symbol,
  ) {
    return PopupMenuItem<String>(
      value: currencyCode,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                symbol,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            currencyCode,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _serviceNameController,
          label: 'Service Name',
          icon: Icons.subscriptions_rounded,
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _costController,
                label: 'Cost',
                icon: Icons.attach_money_rounded,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _currencyController.text = value;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: AppColors.surface,
                  offset: const Offset(0, 60),
                  itemBuilder: (context) => [
                    _buildPopupMenuItem('IDR', 'Rp'),
                    _buildPopupMenuItem('USD', '\$'),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _currencyController.text == 'IDR'
                                      ? 'Rp'
                                      : '\$',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _currencyController.text,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Billing cycle
        const Text(
          'Billing Cycle',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildCycleOption('Monthly', BillingCycle.monthly)),
            const SizedBox(width: 16),
            Expanded(child: _buildCycleOption('Yearly', BillingCycle.yearly)),
          ],
        ),
        const SizedBox(height: 24),

        // Next billing date
        _buildDateSelector(),
        const SizedBox(height: 24),

        // Auto-renew toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Auto-Renewal',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            activeColor: AppColors.success,
            value: _isAutoRenew,
            onChanged: (value) {
              setState(() => _isAutoRenew = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white), // Changed to white
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (keyboardType ==
                const TextInputType.numberWithOptions(decimal: true) &&
            double.tryParse(value) == null) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  Widget _buildCycleOption(String label, BillingCycle value) {
    final isSelected = _billingCycle == value;
    return GestureDetector(
      onTap: () => setState(() => _billingCycle = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.surface,
          borderRadius: BorderRadius.circular(30), // More rounded (Pill shape)
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.black
                  : AppColors.textSecondary, // Black text on white
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Billing Date',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMMM dd, yyyy').format(_nextBillingDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 50, // Reduced height
      decoration: BoxDecoration(
        color: Colors.white, // Solid white
        borderRadius: BorderRadius.circular(30), // Fully rounded
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _saveSubscription,
          borderRadius: BorderRadius.circular(30),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.black, // Black loader on white
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Save Subscription',
                    style: TextStyle(
                      color: Colors.black, // Black text on white
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _selectPreset(PresetService preset) {
    setState(() {
      _selectedPresetName = preset.name;
      _serviceNameController.text = preset.name;
      _currencyController.text = preset.defaultCurrency;
      if (preset.suggestedPrice != null) {
        _costController.text = preset.suggestedPrice.toString();
      }
      _customColorHex = preset.colorHex;
      _logoUrl = preset.logoUrl; // Set logo URL from preset
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextBillingDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.background,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _nextBillingDate = picked);
    }
  }

  Future<void> _saveSubscription() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final subscription = Subscription(
        id:
            widget.subscriptionId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        serviceName: _serviceNameController.text,
        cost: double.parse(_costController.text),
        currency: _currencyController.text,
        billingCycle: _billingCycle,
        startDate: widget.subscriptionId == null
            ? DateTime.now()
            : DateTime.now(),
        nextBillingDate: _nextBillingDate,
        colorHex: _customColorHex,
        isAutoRenew: _isAutoRenew,
        logoUrl: _logoUrl, // Save logo URL
      );

      if (widget.subscriptionId == null) {
        await ref
            .read(subscriptionListProvider.notifier)
            .addSubscription(subscription);
      } else {
        await ref
            .read(subscriptionListProvider.notifier)
            .updateSubscription(widget.subscriptionId!, subscription);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.subscriptionId == null
                  ? 'Subscription added successfully'
                  : 'Subscription updated successfully',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return AppColors.primary;
    }
  }
}
