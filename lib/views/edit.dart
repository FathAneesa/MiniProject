import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart'; // contains apiBaseUrl

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _admissionNoController = TextEditingController();
  Map<String, dynamic>? studentData;
  bool isLoading = false;

  // 🔹 Fetch student by Admission No
  Future<void> fetchStudent() async {
    if (_admissionNoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter Admission No")),
      );
      return;
    }

    setState(() => isLoading = true);

    final response = await http.get(
      Uri.parse('$apiBaseUrl/student/${_admissionNoController.text.trim()}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        studentData = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Student not found")),
      );
    }

    setState(() => isLoading = false);
  }

  // 🔹 Update student
  Future<void> updateStudent() async {
    if (studentData == null) return;

    // prepare body without admission no / username / password
    final body = {
      "Student Name": studentData!["Student Name"],
      "Academic Year": studentData!["Academic Year"],
      "Phone": studentData!["Phone"],
      "Email": studentData!["Email"],
      "dob": studentData!["dob"],
      "Father Name": studentData!["Father Name"],
      "Mother Name": studentData!["Mother Name"],
      "Address": studentData!["Address"],
      "Parent Phone": studentData!["Parent Phone"],
      "Guardian Name": studentData!["Guardian Name"],
      "Guardian Phone": studentData!["Guardian Phone"],
      "Department": studentData!["Department"],
      "Semester": studentData!["Semester"],
      "Gender": studentData!["Gender"],
    };

    final response = await http.put(
      Uri.parse('$apiBaseUrl/student/${_admissionNoController.text.trim()}'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Student updated successfully")),
      );
      Navigator.pop(context); // go back after update
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update student")),
      );
    }
  }

  // 🔹 Build input field
  Widget buildInputField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: TextEditingController(text: studentData![key] ?? "")
          ..selection = TextSelection.collapsed(
              offset: (studentData![key] ?? "").toString().length),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (val) => studentData![key] = val,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Edit Student", style: GoogleFonts.poppins(fontSize: 20)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Step 1: Admission No field
            TextField(
              controller: _admissionNoController,
              decoration: InputDecoration(
                labelText: "Enter Admission No",
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: fetchStudent,
              child: Text("Fetch Student",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 20),

            if (isLoading) CircularProgressIndicator(),

            // Step 2: Editable form
            if (studentData != null)
              Expanded(
                child: ListView(
                  children: [
                    buildInputField("Student Name", "Student Name"),
                    buildInputField("Academic Year", "Academic Year"),
                    buildInputField("Phone", "Phone"),
                    buildInputField("Email", "Email"),
                    buildInputField("Date of Birth", "dob"),
                    buildInputField("Father Name", "Father Name"),
                    buildInputField("Mother Name", "Mother Name"),
                    buildInputField("Address", "Address"),
                    buildInputField("Parent Phone", "Parent Phone"),
                    buildInputField("Guardian Name", "Guardian Name"),
                    buildInputField("Guardian Phone", "Guardian Phone"),
                    buildInputField("Department", "Department"),
                    buildInputField("Semester", "Semester"),
                    buildInputField("Gender", "Gender"),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: updateStudent,
                      child: Text("Save Changes",
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
