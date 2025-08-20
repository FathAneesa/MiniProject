import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';

class EditStud extends StatefulWidget {
  const EditStud({super.key});

  @override
  State<EditStud> createState() => _EditStudState();
}

class _EditStudState extends State<EditStud> {
  final _formKey = GlobalKey<FormState>();
  final _admissionNoController = TextEditingController();

  Map<String, dynamic>? _studentData;
  bool _loading = false;
  bool _searching = false;

  Future<void> _searchStudent() async {
    if (_admissionNoController.text.isEmpty) return;

    setState(() {
      _searching = true;
    });

    final url = Uri.parse('$apiBaseUrl/student/${_admissionNoController.text}');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      setState(() {
        _studentData = jsonDecode(res.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student not found")),
      );
      setState(() {
        _studentData = null;
      });
    }

    setState(() {
      _searching = false;
    });
  }

  Future<void> _updateStudent() async {
    if (_studentData == null) return;

    setState(() => _loading = true);

    final admissionNo = _studentData!["Admission No"];
    final url = Uri.parse('$apiBaseUrl/student/$admissionNo');

    final res = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(_studentData),
    );

    setState(() => _loading = false);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student updated successfully")),
      );
      Navigator.pop(context, true); // Pass "true" back
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: ${res.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF497B6), // Orchid Pink background
      appBar: AppBar(
        title: Text(
          "Edit Student",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFA96CE7), // Deep Orchid
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextFormField(
              controller: _admissionNoController,
              decoration: InputDecoration(
                labelText: "Enter Admission No",
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _searching ? null : _searchStudent,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC28FF7), // Amethyst Glow
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _searching
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "Search",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
            ),
            const Divider(thickness: 1, height: 20),
            _studentData != null
                ? Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: _studentData!.keys
                            .where((key) => key != "UserID" && key != "Admission No")
                            .map((key) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: TextFormField(
                              initialValue: _studentData![key]?.toString() ?? "",
                              decoration: InputDecoration(
                                labelText: key,
                                labelStyle: GoogleFonts.poppins(),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (val) => _studentData![key] = val,
                            ),
                          );
                        }).toList()
                          ..insert(
                            0,
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: TextFormField(
                                enabled: false,
                                initialValue: _studentData!["Admission No"] ?? "",
                                decoration: InputDecoration(
                                  labelText: "Admission No",
                                  labelStyle: GoogleFonts.poppins(),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  filled: true,
                                  fillColor: const Color.fromARGB(255, 251, 251, 251),
                                ),
                              ),
                            ),
                          ),
                      ),
                    ),
                  )
                : Text(
                    "Enter admission number to search.",
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
            if (_studentData != null)
              ElevatedButton(
                onPressed: _loading ? null : _updateStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 133, 52, 90),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Color.fromARGB(255, 142, 127, 127))
                    : Text(
                        "Update",
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
              )
          ],
        ),
      ),
    );
  }
}
