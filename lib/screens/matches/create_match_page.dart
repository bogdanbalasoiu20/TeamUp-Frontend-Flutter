import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team_up_fe_new/screens/map/map_page.dart';
import '../../exceptions/api_exception.dart';
import '../../exceptions/api_service.dart';
import '../../models/venue.dart';
import '../../widgets/mini_map_widget.dart';

class CreateMatchPage extends StatefulWidget {
  const CreateMatchPage({super.key});

  @override
  State<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  final titleController = TextEditingController();
  final notesController = TextEditingController();
  final durationController = TextEditingController(text: "60");
  final maxPlayersController = TextEditingController(text: "10");
  final priceController = TextEditingController(text: "0");

  DateTime? startsAt;
  DateTime? joinDeadline;
  Venue? selectedVenue;
  bool creating = false;
  String visibility = "PUBLIC";

  final Color _bgDark = const Color(0xFF091210);
  final Color _cardSurface = const Color(0xFF13241E);
  final Color _accentGreen = const Color(0xFF00E676);
  final Color _textSecondary = const Color(0xFF8A9E96);

  Future<void> _pickDate({required bool isStart}) async {
    DateTime now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(2030),
      initialDate: now,
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

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
                backgroundColor: _bgDark,
                dialBackgroundColor: _cardSurface,
                hourMinuteColor: _cardSurface,
                hourMinuteTextColor: _accentGreen,
              )
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
          backgroundColor: Colors.red.shade900
      ),
    );
  }

  Future<void> _createMatch() async {
    if (selectedVenue == null) {
      showError("Select a field on the map");
      return;
    }
    if (startsAt == null) {
      showError("Select the start time");
      return;
    }

    final payload = {
      "venueId": selectedVenue!.id,
      "startsAt": startsAt!.toUtc().toIso8601String(),
      "durationMinutes": int.tryParse(durationController.text),
      "maxPlayers": int.tryParse(maxPlayersController.text),
      "joinDeadline": joinDeadline?.toUtc().toIso8601String(),
      "title": titleController.text,
      "notes": notesController.text,
      "totalPrice": double.tryParse(priceController.text),
      "visibility": visibility,
    };

    setState(() => creating = true);

    try {
      await ApiService.post("/api/matches", payload);

      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Match created successfully", style: TextStyle(color: Colors.black)),
          backgroundColor: _accentGreen,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      showError(e is ApiException ? e.toString() : "Unexpected error");
    } finally {
      if(mounted) setState(() => creating = false);
    }
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Row(
              children: [
                const Text(
                  "Create",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Match",
                  style: TextStyle(
                    color: _accentGreen,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 44),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0A6F4A).withOpacity(0.2),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _buildTopBar(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const SizedBox(height: 20),

                        _buildSectionLabel("Venue Location"),
                        const SizedBox(height: 8),
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: _accentGreen, width: 2.5),
                            color: _cardSurface,
                            boxShadow: [
                              BoxShadow(
                                color: _accentGreen.withOpacity(0.25),
                                blurRadius: 15,
                                spreadRadius: 1,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(21.5),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                MiniMapWidget(
                                  selectedVenue: selectedVenue,
                                  onTap: () async {
                                    final venue = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const MapPage()),
                                    );
                                    if (venue != null) setState(() => selectedVenue = venue);
                                  },
                                ),
                                if (selectedVenue == null)
                                  IgnorePointer(
                                    child: Container(
                                      color: Colors.black.withOpacity(0.3),
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: _bgDark.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: _accentGreen.withOpacity(0.5)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.touch_app, color: _accentGreen, size: 20),
                                              const SizedBox(width: 8),
                                              const Text(
                                                "Tap to select field",
                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        if (selectedVenue != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, color: _accentGreen, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    selectedVenue!.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 32),

                        _buildSectionLabel("Game Info"),
                        const SizedBox(height: 8),

                        _buildModernInput(
                          controller: titleController,
                          hint: "Match Title (e.g. Wednesday Night)",
                          icon: Icons.sports_soccer,
                        ),
                        const SizedBox(height: 16),

                        _buildClickableInput(
                          icon: Icons.calendar_month,
                          value: startsAt == null
                              ? "Select Start Time"
                              : DateFormat("yyyy-MM-dd HH:mm").format(startsAt!),
                          onTap: () => _pickDate(isStart: true),
                          isPlaceholder: startsAt == null,
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildModernInput(
                                controller: durationController,
                                hint: "Min",
                                icon: Icons.timer_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildModernInput(
                                controller: maxPlayersController,
                                hint: "Players",
                                icon: Icons.people_outline,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        _buildModernInput(
                          controller: priceController,
                          hint: "Total Price (RON)",
                          icon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 32),

                        _buildSectionLabel("Optional Details"),
                        const SizedBox(height: 8),

                        _buildClickableInput(
                          icon: Icons.lock_clock_outlined,
                          value: joinDeadline == null
                              ? "Join Deadline (Optional)"
                              : DateFormat("yyyy-MM-dd HH:mm").format(joinDeadline!),
                          onTap: () => _pickDate(isStart: false),
                          isPlaceholder: joinDeadline == null,
                        ),

                        const SizedBox(height: 16),

                        _buildModernInput(
                          controller: notesController,
                          hint: "Notes / Instructions",
                          icon: Icons.note_alt_outlined,
                          maxLines: 3,
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: creating ? null : _createMatch,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentGreen,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              disabledBackgroundColor: _cardSurface,
                            ),
                            child: creating
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                            )
                                : const Text(
                              "CREATE MATCH",
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

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: _textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String hint,
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
          hintText: hint,
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

  Widget _buildClickableInput({
    required IconData icon,
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
          trailing: Icon(Icons.arrow_drop_down, color: _textSecondary),
        ),
      ),
    );
  }
}