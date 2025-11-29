import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../exceptions/api_exception.dart';
import '../exceptions/api_service.dart';
import '../models/venue.dart';
import '../services/map_api.dart';
import '../widgets/mini_map_widget.dart';

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

  List<Venue> venues = [];
  Venue? selectedVenue;
  bool loadingVenues = true;
  bool creating = false;

  String visibility = "PUBLIC";

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  // LOAD VENUES
  Future<void> _loadVenues() async {
    print("### Loading venues from backend...");
    final raw = await MapApi.fetchBBox(44.35, 25.95, 44.55, 26.25);

    print("### RAW venue list length: ${raw.length}");

    setState(() {
      venues = raw.map((v) => Venue.fromJson(v)).toList();
      loadingVenues = false;
    });
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
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  // CREATE MATCH
  Future<void> _createMatch() async {
    // if (selectedVenue == null) {
    //   showError("Selectează un teren");
    //   return;
    // }
    // if (startsAt == null) {
    //   showError("Selectează ora de start");
    //   return;
    // }

    print("### Preparing match creation request...");
    print("### Selected Venue:");
    print("   id = ${selectedVenue!.id}");
    print("   name = ${selectedVenue!.name}");
    print("   lat = ${selectedVenue!.latitude}, lng = ${selectedVenue!.longitude}");

    final payload = {
      "venueId": selectedVenue?.id,
      "startsAt": startsAt?.toUtc().toIso8601String(),
      "durationMinutes": int.tryParse(durationController.text),
      "maxPlayers": int.tryParse(maxPlayersController.text),
      "joinDeadline": joinDeadline?.toUtc().toIso8601String(),
      "title": titleController.text,
      "notes": notesController.text,
      "totalPrice": double.tryParse(priceController.text),
      "visibility": visibility,
    };

    print("### Payload to backend:");
    print(payload);

    setState(() => creating = true);

    try {
      await ApiService.post("/api/matches", payload);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Match created successfully")),
      );

      Navigator.pop(context);

    } catch (e) {
      if (e is ApiException) {
        // afisam mesajul de backend
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Unexpected error")));
      }
    }

    setState(() => creating = false);
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF003B2F),
                  Colors.green.shade800,
                  Colors.green.shade400,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 70, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Create Match",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Choose field • Set time • Have fun",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                )
              ],
            ),
          ),

          // Sheet
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
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
              ),
              child: loadingVenues
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MiniMapWidget(),
                    const SizedBox(height: 20),

                    const Text("Venue"),
                    DropdownButtonFormField<Venue>(
                      value: selectedVenue,
                      isExpanded: true,
                      items: venues
                          .map((v) => DropdownMenuItem(
                        value: v,
                        child: Text(v.name),
                      ))
                          .toList(),
                      onChanged: (v) {
                        print("### Venue selected:");
                        print("   id=${v?.id}");
                        print("   name=${v?.name}");
                        print("   lat=${v?.latitude}, lng=${v?.longitude}");

                        setState(() => selectedVenue = v);
                      },
                    ),

                    const SizedBox(height: 20),

                    const Text("Start Time"),
                    GestureDetector(
                      onTap: () => _pickDate(isStart: true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: boxDecoration(),
                        child: Text(
                          startsAt == null
                              ? "Select date & time"
                              : DateFormat("yyyy-MM-dd HH:mm")
                              .format(startsAt!),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text("Join Deadline (optional)"),
                    GestureDetector(
                      onTap: () => _pickDate(isStart: false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: boxDecoration(),
                        child: Text(
                          joinDeadline == null
                              ? "Select deadline"
                              : DateFormat("yyyy-MM-dd HH:mm")
                              .format(joinDeadline!),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    underlineInput("Duration (minutes)",
                        controller: durationController),

                    const SizedBox(height: 20),

                    underlineInput("Maximum players",
                        controller: maxPlayersController),

                    const SizedBox(height: 20),

                    underlineInput("Total price",
                        controller: priceController),

                    const SizedBox(height: 20),


                    underlineInput("Title",
                        controller: titleController),

                    const SizedBox(height: 20),

                    underlineInput("Notes",
                        controller: notesController, maxLines: 3),

                    const SizedBox(height: 40),

                    GestureDetector(
                      onTap: creating ? null : _createMatch,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF003B2F),
                              Colors.green.shade800,
                              Colors.green.shade400,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: creating
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "CREATE MATCH",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
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

  Widget underlineInput(String label,
      {required TextEditingController controller, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD3D3D3)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00A86B), width: 1.4),
        ),
      ),
    );
  }

  BoxDecoration boxDecoration() {
    return BoxDecoration(
      border: Border.all(color: Colors.black26),
      borderRadius: BorderRadius.circular(12),
    );
  }
}
