import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team_up_fe_new/exceptions/api_exception.dart';
import 'package:team_up_fe_new/exceptions/api_service.dart';
import 'package:team_up_fe_new/models/match_info.dart';
import '../utils/app_colors.dart';

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

    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? (startsAt ?? now) : (joinDeadline ?? now),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? (startsAt ?? now) : (joinDeadline ?? now)),
    );
    if (time == null) return;

    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      if (isStart) startsAt = dt;
      else joinDeadline = dt;
    });
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Match updated successfully")),
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
    final m = widget.match;

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
                  "Edit Match",
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
                  "Adjust details • Save",
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

                    // FIELD (DISABLED) WITH ICONS
                    const Text(
                      "Field (cannot be changed)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF003B2F),
                      ),
                    ),
                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 22, color: Colors.black54),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              m.venueName,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const Icon(Icons.lock, size: 20, color: Colors.black45),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // START TIME
                    _iconPickerBox(
                      icon: Icons.schedule,
                      label: "Start Time",
                      text: startsAt == null
                          ? "Select date & time"
                          : DateFormat("yyyy-MM-dd HH:mm").format(startsAt!),
                      onTap: () => _pickDate(isStart: true),
                    ),
                    const SizedBox(height: 20),

                    // DEADLINE
                    _iconPickerBox(
                      icon: Icons.lock_clock,
                      label: "Join Deadline (optional)",
                      text: joinDeadline == null
                          ? "Select deadline"
                          : DateFormat("yyyy-MM-dd HH:mm").format(joinDeadline!),
                      onTap: () => _pickDate(isStart: false),
                    ),
                    const SizedBox(height: 20),

                    _iconTextField("Duration (minutes)", durationController, Icons.timer),
                    const SizedBox(height: 20),

                    _iconTextField("Maximum players", maxPlayersController, Icons.people),
                    const SizedBox(height: 20),

                    _iconTextField("Total price", priceController, Icons.payments),
                    const SizedBox(height: 20),

                    _iconTextField("Title", titleController, Icons.sports_soccer),
                    const SizedBox(height: 20),

                    _iconTextField("Notes", notesController, Icons.note_alt, maxLines: 3),

                    const SizedBox(height: 40),

                    GestureDetector(
                      onTap: updating ? null : _updateMatch,
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
                  child: Text(text, style: const TextStyle(fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _iconTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
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
