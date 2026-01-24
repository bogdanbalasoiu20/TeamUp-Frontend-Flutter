import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../exceptions/api_exception.dart';
import '../../exceptions/api_service.dart';

class EditProfilePage extends StatefulWidget {
  final DateTime? birthday;
  final String? phone;
  final String? city;
  final String? description;
  final String? position;

  const EditProfilePage({
    super.key,
    this.birthday,
    this.phone,
    this.city,
    this.description,
    this.position,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController phoneController;
  late TextEditingController cityController;
  late TextEditingController descriptionController;

  DateTime? birthday;
  String? position;
  bool updating = false;

  // --- THEME COLORS ---
  final Color _bgDark = const Color(0xFF091210);
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);

  final List<String> positions = [
    "GOALKEEPER",
    "DEFENDER",
    "MIDFIELDER",
    "FORWARD"
  ];

  @override
  void initState() {
    super.initState();
    birthday = widget.birthday;
    position = widget.position;

    phoneController = TextEditingController(text: widget.phone ?? "");
    cityController = TextEditingController(text: widget.city ?? "");
    descriptionController = TextEditingController(text: widget.description ?? "");
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: birthday ?? DateTime(now.year - 18),
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _accentGreen,
              onPrimary: Colors.black,
              surface: _cardSurface,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: _bgDark,
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;
    setState(() => birthday = date);
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade900
      ),
    );
  }

  Future<void> _saveChanges() async {
    setState(() => updating = true);

    final payload = {
      "birthday": birthday?.toIso8601String(),
      "phoneNumber": phoneController.text.trim().isEmpty
          ? null
          : phoneController.text.trim(),
      "position": position,
      "city": cityController.text.trim(),
      "description": descriptionController.text.trim(),
    };

    try {
      await ApiService.patch("/api/users/me", payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Profile updated successfully!", style: TextStyle(color: Colors.black)),
          backgroundColor: _accentGreen,
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {
      showError(e is ApiException ? e.toString() : "Unexpected error");
    } finally {
      if (mounted) setState(() => updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0A6F4A).withOpacity(0.3),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentGreen.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // CUSTOM APP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.05),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        _buildSectionHeader("Personal Info"),

                        // BIRTHDAY PICKER
                        _buildClickableInput(
                          icon: Icons.cake_outlined,
                          label: "Birthday",
                          value: birthday == null
                              ? "Select your birthday"
                              : DateFormat("yyyy-MM-dd").format(birthday!),
                          onTap: _pickBirthday,
                          isPlaceholder: birthday == null,
                        ),

                        const SizedBox(height: 16),

                        // PHONE
                        _buildModernInput(
                          controller: phoneController,
                          label: "Phone Number",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),

                        const SizedBox(height: 16),

                        // CITY
                        _buildModernInput(
                          controller: cityController,
                          label: "City",
                          icon: Icons.location_city_outlined,
                        ),

                        const SizedBox(height: 32),
                        _buildSectionHeader("Player Details"),

                        // POSITION DROPDOWN
                        _buildModernDropdown(),

                        const SizedBox(height: 16),

                        // DESCRIPTION
                        _buildModernInput(
                          controller: descriptionController,
                          label: "Bio / Description",
                          icon: Icons.description_outlined,
                          maxLines: 4,
                        ),

                        const SizedBox(height: 40),

                        // SAVE BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: updating ? null : _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentGreen,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              disabledBackgroundColor: _cardSurface,
                            ),
                            child: updating
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                            )
                                : const Text(
                              "SAVE CHANGES",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: _textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  // Standard Text Input
  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: _textSecondary.withOpacity(0.7)),
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: maxLines > 1 ? 40 : 0),
            child: Icon(icon, color: _accentGreen.withOpacity(0.8), size: 22),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  // Clickable Input (for DatePicker)
  Widget _buildClickableInput({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    bool isPlaceholder = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        decoration: BoxDecoration(
          color: _cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: ListTile(
          leading: Icon(icon, color: _accentGreen.withOpacity(0.8), size: 22),
          title: Text(
            value,
            style: TextStyle(
              color: isPlaceholder ? _textSecondary.withOpacity(0.7) : Colors.white,
              fontSize: 16,
            ),
          ),
          trailing: Icon(Icons.calendar_today, color: _textSecondary, size: 18),
        ),
      ),
    );
  }

  // Dropdown for Position
  Widget _buildModernDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: position,
          hint: Text(
            "Select Position",
            style: TextStyle(color: _textSecondary.withOpacity(0.7)),
          ),
          isExpanded: true,
          dropdownColor: _cardSurface,
          icon: Icon(Icons.arrow_drop_down, color: _accentGreen),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          items: positions.map((p) => DropdownMenuItem(
            value: p,
            child: Row(
              children: [
                Icon(Icons.sports_soccer, size: 18, color: _accentGreen.withOpacity(0.7)),
                const SizedBox(width: 12),
                Text(p),
              ],
            ),
          )).toList(),
          onChanged: (v) => setState(() => position = v),
        ),
      ),
    );
  }
}