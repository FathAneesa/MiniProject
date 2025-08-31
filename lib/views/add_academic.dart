import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart'; // Provides apiBaseUrl

class AddAcademicPage extends StatefulWidget {
  final String studentId;
  const AddAcademicPage({super.key, required this.studentId});

  @override
  State<AddAcademicPage> createState() => _AddAcademicPageState();
}

class _AddAcademicPageState extends State<AddAcademicPage> {
  List<Map<String, dynamic>> subjects = [
    {"name": "", "mark": ""}
  ];
  TextEditingController studyHoursController = TextEditingController();
  TextEditingController focusLevelController = TextEditingController();
  int overallMark = 0;
  bool _isConfirming = false;

  void calculateOverallMark() {
    int total = 0;
    int count = 0;
    for (var subj in subjects) {
      if (subj["mark"].toString().isNotEmpty) {
        int? mark = int.tryParse(subj["mark"].toString());
        if (mark != null) {
          total += mark;
          count++;
        }
      }
    }
    setState(() {
      overallMark = (count > 0) ? (total ~/ count) : 0;
    });
  }
Future<void> saveAcademicData() async {
  try {
    final url = Uri.parse("$apiBaseUrl/academics/add"); // ✅ fixed endpoint

    final Map<String, dynamic> data = {
      "studentId": widget.studentId, // ✅ backend expects studentId in body
      "subjects": subjects,
      "studyHours": studyHoursController.text,
      "focusLevel": focusLevelController.text,
      "overallMark": overallMark, 
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Academic data saved successfully!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to Save: ${response.body}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Add Academic Data',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Subjects & Marks",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Dynamic Subject List
            Column(
              children: List.generate(subjects.length, (index) {
                return Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: "Subject",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              subjects[index]["name"] = val;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Mark",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              subjects[index]["mark"] = val;
                              calculateOverallMark();
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              subjects.removeAt(index);
                              calculateOverallMark();
                            });
                          },
                        )
                      ],
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  subjects.add({"name": "", "mark": ""});
                });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              child: Text("Add Another Subject",
                  style: GoogleFonts.poppins(color: Colors.white)),
            ),

            const SizedBox(height: 20),
            Text("Study Hours (per day)",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: studyHoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: "Enter study hours"),
            ),

            const SizedBox(height: 20),
            Text("Focus Level (out of 10)",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: focusLevelController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: "Enter focus level"),
            ),

            const SizedBox(height: 20),
            Text("Overall Marks",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200]),
              child: Text(
                overallMark.toString(),
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 20),
            Center(
  child: ElevatedButton(
    onPressed: _isConfirming
        ? null
        : () async {
            setState(() => _isConfirming = true);
            await saveAcademicData();   // ✅ call the correct function
            setState(() => _isConfirming = false);
          },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
    ),
    child: _isConfirming
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ))
        : Text("Confirm",
            style: GoogleFonts.poppins(color: Colors.white)),
  ),
),

          ],
        ),
      ),
    );
  }
}
