import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewSubjectsPage extends StatelessWidget {
  final List<Map<String, dynamic>> subjects;

  const ViewSubjectsPage({super.key, required this.subjects});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'View Subjects',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text("Subjects",
                        style: GoogleFonts.poppins(
                            fontSize: 20, fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text("Marks",
                        style: GoogleFonts.poppins(
                            fontSize: 20, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(subjects[index]["name"] ?? "",
                                style: GoogleFonts.poppins(fontSize: 16)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(subjects[index]["mark"] ?? "",
                                style: GoogleFonts.poppins(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}