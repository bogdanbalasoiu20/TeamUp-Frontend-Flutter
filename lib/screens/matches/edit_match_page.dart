import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team_up_fe_new/exceptions/api_exception.dart';
import 'package:team_up_fe_new/exceptions/api_service.dart';
import 'package:team_up_fe_new/models/match_info.dart';

class EditMatchPage extends StatefulWidget {
  final MatchInfo match;

  const EditMatchPage({super.key, required this.match});

  @override
  State<EditMatchPage> createState() => _EditMatchPageState();
}

class _EditMatchPageState extends State<EditMatchPage> {
  late TextEditingController titleController;
  late TextEditingController notesController;
  late TextEditingController durationController;
  late TextEditingController maxPlayersController;
  late TextEditingController priceController;

  DateTime? startsAt;
  DateTime? joinDeadline;

  bool updating = false;
  String visibility = "PUBLIC";

  final Color _bgDark = const Color(0xFF091210);
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);

  @override
  void initState() {
    super.initState();
    final m = widget.match;

    titleController = TextEditingController(text: m.title);
    notesController = TextEditingController(text: m.notes);
    durationController = TextEditingController(text: "${m.durationMinutes}");
    maxPlayersController = TextEditingController(text: "${m.maxPlayers}");
    priceController = TextEditingController(text: "${m.totalPrice}");

    startsAt = m.startsAt;
    joinDeadline = m.joinDeadline;
    visibility = m.visibility;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart ? (startsAt ?? now) : (joinDeadline ?? now);

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _accentGreen,
              onPrimary: Colors.black,
              surface: _cardSurface,
              onSurface: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: _cardSurface,
              dialBackgroundColor: _bgDark,
              dialHandColor: _accentGreen,
              hourMinuteTextColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      if (isStart) {
        startsAt = dt;
      } else {
        joinDeadline = dt;
      }
    });
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade900,
      ),
    );
  }

  Future<void> _updateMatch() async {
    setState(() => updating = true);

    final payload = {
      "title": titleController.text,
      "notes": notesController.text,
      "startsAt": startsAt?.toUtc().toIso8601String(),
      "durationMinutes": int.tryParse(durationController.text),
      "maxPlayers": int.tryParse(maxPlayersController.text),
      "joinDeadline": joinDeadline?.toUtc().toIso8601String(),
      "totalPrice": double.tryParse(priceController.text),
      "visibility": visibility
    };

    try {
      await ApiService.patch("/api/matches/${widget.match.id}", payload);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Match updated successfully!", style: TextStyle(color: Colors.black)),
          backgroundColor: _accentGreen,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      showError(e is ApiException ? e.toString() : "Unexpected error");
    }

    if (mounted) setState(() => updating = false);
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
                        "Edit Match",
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
                        _buildSectionHeader("Logistics"),

                        _buildReadOnlyField(
                          icon: Icons.location_on_outlined,
                          label: "Venue (Fixed)",
                          value: widget.match.venueName,
                        ),
                        const SizedBox(height: 16),

                        _buildClickableInput(
                          icon: Icons.calendar_month_outlined,
                          label: "Start Time",
                          value: startsAt == null
                              ? "Select start time"
                              : DateFormat("yyyy-MM-dd HH:mm").format(startsAt!),
                          onTap: () => _pickDate(isStart: true),
                        ),
                        const SizedBox(height: 16),

                        _buildModernInput(
                          controller: durationController,
                          label: "Duration - Minutes",
                          icon: Icons.timer_outlined,
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 32),
                        _buildSectionHeader("Rules & Cost"),

                        Row(
                          children: [
                            Expanded(
                              child: _buildModernInput(
                                controller: maxPlayersController,
                                label: "Max Players",
                                icon: Icons.group_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildModernInput(
                                controller: priceController,
                                label: "Total Price",
                                icon: Icons.payments_outlined,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildClickableInput(
                          icon: Icons.lock_clock_outlined,
                          label: "Join Deadline",
                          value: joinDeadline == null
                              ? "No deadline set"
                              : DateFormat("yyyy-MM-dd HH:mm").format(joinDeadline!),
                          onTap: () => _pickDate(isStart: false),
                        ),

                        const SizedBox(height: 32),
                        _buildSectionHeader("Information"),

                        _buildModernInput(
                          controller: titleController,
                          label: "Match Title",
                          icon: Icons.sports_soccer_outlined,
                        ),
                        const SizedBox(height: 16),

                        _buildModernInput(
                          controller: notesController,
                          label: "Notes / Description",
                          icon: Icons.description_outlined,
                          maxLines: 4,
                        ),

                        const SizedBox(height: 40),


                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: updating ? null : _updateMatch,
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
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _textSecondary.withOpacity(0.7)),
          floatingLabelStyle: TextStyle(color: _accentGreen),
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: maxLines > 1 ? 40 : 0),
            child: Icon(icon, color: _accentGreen.withOpacity(0.8), size: 22),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildClickableInput({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
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
            label,
            style: TextStyle(
              color: _textSecondary.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          subtitle: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(Icons.edit, color: _textSecondary, size: 18),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white38, size: 22),
        title: Text(
          label,
          style: TextStyle(
            color: _textSecondary.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.lock_outline, color: Colors.white24, size: 18),
      ),
    );
  }
}