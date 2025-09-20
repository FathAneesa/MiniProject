import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart'; // Import the centralized config

class ViewAcademicPage extends StatefulWidget {
  final String studentId;

  const ViewAcademicPage({super.key, required this.studentId});

  @override
  _ViewAcademicPageState createState() => _ViewAcademicPageState();
}

class _ViewAcademicPageState extends State<ViewAcademicPage> {
  List<Map<String, dynamic>> subjects = [];
  int? focusLevel;
  int? studyHours;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAcademicData();
  }

Future<void> fetchAcademicData() async {
  try {
    final response = await http.get(
      Uri.parse("$apiBaseUrl/academics/latest/${widget.studentId}"),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      if (decoded["status"] == "success" && decoded["data"] != null) {
        final record = decoded["data"];

        setState(() {
          subjects = List<Map<String, dynamic>>.from(record["subjects"]);
          focusLevel = int.tryParse(record["focusLevel"].toString());
          studyHours = int.tryParse(record["studyHours"].toString());
          isLoading = false;
        });
      } else {
        setState(() {
          subjects = [];
          isLoading = false;
        });
      }
    } else {
      setState(() => isLoading = false);
    }
  } catch (e) {
    setState(() => isLoading = false);
    debugPrint("❌ Error fetching academics: $e");
  }
}


  Future<void> deleteSubject(int index) async {
  try {
    final response = await http.delete(
      Uri.parse("$apiBaseUrl/academics/${widget.studentId}/subjects/$index"),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded["status"] == "success") {
        setState(() {
          subjects.removeAt(index);
        });
      }
    } else {
      debugPrint("❌ Failed to delete subject: ${response.body}");
    }
  } catch (e) {
    debugPrint("❌ Error deleting subject: $e");
  }
}


Future<void> editSubject(int index) async {
  final subject = subjects[index];
  final nameController = TextEditingController(text: subject["name"]);
  final markController = TextEditingController(text: subject["mark"].toString());

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Edit Subject"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Subject Name"),
          ),
          TextField(
            controller: markController,
            decoration: const InputDecoration(labelText: "Marks"),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final updatedSubject = {
              "name": nameController.text,
              "mark": int.tryParse(markController.text) ?? 0,
            };

            try {
              // ✅ Send PUT request to backend
              final response = await http.put(
                Uri.parse("$apiBaseUrl/academics/${widget.studentId}/subjects/$index"),
                headers: {"Content-Type": "application/json"},
                body: json.encode(updatedSubject),
              );

              if (response.statusCode == 200) {
                final decoded = json.decode(response.body);
                if (decoded["status"] == "success") {
                  // ✅ Update UI
                  setState(() {
                    subjects[index] = updatedSubject;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Subject updated successfully")),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to update: ${response.body}")),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error updating subject: $e")),
              );
            }
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 221, 124, 224),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 219, 32, 236),
        title: Text(
          'View Academic Data',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : subjects.isEmpty
                ? Center(
                    child: Text(
                      "No academic data found.",
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              "Subjects",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Marks",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: subjects.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.white,
                              elevation: 5,
                              shadowColor: Colors.blueAccent.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                title: Text(
                                  subjects[index]["name"] ?? "",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        subjects[index]["mark"].toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromARGB(255, 65, 2, 63),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () => editSubject(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => deleteSubject(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (studyHours != null || focusLevel != null)
                        Card(
                          color: Colors.yellow[50],
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Study Hours: ${studyHours ?? "N/A"}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Focus Level: ${focusLevel ?? "N/A"} / 10",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}