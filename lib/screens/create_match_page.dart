import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team_up_fe_new/screens/map_page.dart';
import 'package:team_up_fe_new/screens/notifications_page.dart';
import 'package:team_up_fe_new/services/notifications_api.dart';
import 'package:team_up_fe_new/utils/app_colors.dart';
import 'package:team_up_fe_new/widgets/left_menu_modal.dart';
import 'package:team_up_fe_new/widgets/navbar.dart';
import '../exceptions/api_exception.dart';
import '../exceptions/api_service.dart';
import '../models/venue.dart';
import '../widgets/mini_map_widget.dart';
import '../widgets/top_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CreateMatchPage extends StatefulWidget {
  const CreateMatchPage({super.key});

  @override
  State<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  // Controllers
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
  int unseenCount = 0;

  Future<void> _loadUnseen() async {
    try {
      final all = await NotificationsApi.fetchAll();
      final count = all.where((n) => !n.isSeen).length;
      setState(() => unseenCount = count);
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _loadUnseen();
  }

  // PICK DATE
  Future<void> _pickDate({required bool isStart}) async {
    DateTime now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(2030),
      initialDate: now,
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dt =
    DateTime(date.year, date.month, date.day, time.hour, time.minute);

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
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  // CREATE MATCH
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Match created successfully")),
      );

      Navigator.pop(context,true);
    } catch (e) {
      if (e is ApiException) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Unexpected error")));
      }
    }

    setState(() => creating = false);
  }

  // UI
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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

          //TOPBAR
          TopSheetBar(
            unseenCount: unseenCount,
            onNotificationsTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );

              _loadUnseen();
            },
            onMenuTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final loggedUser = prefs.getString("username");

              if (loggedUser != null) {
                showLeftMenuModal(context, loggedUser);
              } else {
                print("Eroare: username not stored in prefs");
              }
            },
          ),


          // TITLE
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 125, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Create Match",
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
                  "Choose field • Set time • Have fun",
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
            top: size.height * 0.32,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(26, 32, 26, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 25,
                    color: Colors.black.withOpacity(0.15),
                    offset: const Offset(0, -3),
                  )
                ],
              ),

              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // MINI MAP
                    MiniMapWidget(
                      selectedVenue: selectedVenue,
                      onTap: () async {
                        final venue = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MapPage()),
                        );

                        if (venue != null) {
                          setState(() => selectedVenue = venue);
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    if (selectedVenue != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selected field:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF003B2F),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            selectedVenue!.name,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),

                    // ---------------------- ICON FIELDS -----------------------

                    _iconPickerBox(
                      icon: Icons.schedule,
                      label: "Start Time",
                      text: startsAt == null
                          ? "Select date & time"
                          : DateFormat("yyyy-MM-dd HH:mm").format(startsAt!),
                      onTap: () => _pickDate(isStart: true),
                    ),
                    const SizedBox(height: 20),

                    _iconPickerBox(
                      icon: Icons.lock_clock,
                      label: "Join Deadline (optional)",
                      text: joinDeadline == null
                          ? "Select deadline"
                          : DateFormat("yyyy-MM-dd HH:mm")
                          .format(joinDeadline!),
                      onTap: () => _pickDate(isStart: false),
                    ),
                    const SizedBox(height: 20),

                    _iconTextField(
                        "Duration (minutes)", durationController, Icons.timer),
                    const SizedBox(height: 20),

                    _iconTextField("Maximum players", maxPlayersController,
                        Icons.people),
                    const SizedBox(height: 20),

                    _iconTextField(
                        "Total price", priceController, Icons.payments),
                    const SizedBox(height: 20),

                    _iconTextField(
                        "Title", titleController, Icons.sports_soccer),
                    const SizedBox(height: 20),

                    _iconTextField(
                        "Notes", notesController, Icons.note_alt,
                        maxLines: 3),

                    const SizedBox(height: 40),

                    // BUTTON
                    GestureDetector(
                      onTap: creating ? null : _createMatch,
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
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 12,
                              color: Colors.greenAccent.withOpacity(0.4),
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Center(
                          child: creating
                              ? const CircularProgressIndicator(
                              color: Colors.white)
                              : const Text(
                            "CREATE MATCH",
                            style: TextStyle(
                              fontSize: 19,
                              color: Colors.white,
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

          TeamUpNavBar(
            currentIndex: 2,
            onTabSelected: (index) {
              // TODO: navigate către alte pagini
            },
          ),
        ],
      ),
    );
  }

  // ------------------ ICON WIDGETS ------------------

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
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                    style: const TextStyle(fontSize: 15),
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
      String label, TextEditingController controller, IconData icon,
      {int maxLines = 1}) {
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
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
                  decoration:
                  const InputDecoration(border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
