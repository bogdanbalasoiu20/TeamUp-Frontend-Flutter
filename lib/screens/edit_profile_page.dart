import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../exceptions/api_exception.dart';
import '../exceptions/api_service.dart';
import '../utils/app_colors.dart';

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
    );
    if (date == null) return;

    setState(() => birthday = date);
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );

      Navigator.pop(context, true);

    } catch (e) {
      showError(e is ApiException ? e.toString() : "Unexpected error");
    }

    setState(() => updating = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF003B2F),
                  AppColors.primaryGreenDark,
                  AppColors.primaryGreenLight,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          // TITLE
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 70, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 42,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    shadows: [
                      Shadow(
                        blurRadius: 12,
                        color: Colors.black54,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Update your info • Save",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),

          // WHITE SHEET
          Positioned(
            top: size.height * 0.28,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(26, 32, 26, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),

              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ------------------- BIRTHDAY -------------------
                    _iconPickerBox(
                      icon: Icons.cake_outlined,
                      label: "Birthday",
                      text: birthday == null
                          ? "Select birthday"
                          : DateFormat("yyyy-MM-dd").format(birthday!),
                      onTap: _pickBirthday,
                    ),
                    const SizedBox(height: 20),

                    // ------------------- PHONE -------------------
                    _iconTextField(
                      "Phone Number",
                      phoneController,
                      Icons.phone_outlined,
                    ),
                    const SizedBox(height: 20),

                    // ------------------- CITY -------------------
                    _iconTextField(
                      "City",
                      cityController,
                      Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 20),

                    // ------------------- DESCRIPTION -------------------
                    _iconTextField(
                      "Description",
                      descriptionController,
                      Icons.description_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // ------------------- POSITION -------------------
                    const Text(
                      "Position",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF003B2F),
                      ),
                    ),
                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: position,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: positions.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Text(
                                p,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => position = v),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ------------------- SAVE BUTTON -------------------
                    GestureDetector(
                      onTap: updating ? null : _saveChanges,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF003B2F),
                              Color(0xFF0A6F4A),
                              Color(0xFF46C264),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: updating
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "SAVE CHANGES",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------
  // GENERIC UI COMPONENTS (same style)
  // ---------------------------------------

  Widget _iconPickerBox({
    required IconData icon,
    required String label,
    required String text,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF003B2F),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.black87),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconTextField(
      String label,
      TextEditingController controller,
      IconData icon, {
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF003B2F),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black87),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: maxLines,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
