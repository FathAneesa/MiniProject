import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart'; // contains apiBaseUrl
import '../theme/app_theme.dart';
import '../theme/theme_helpers.dart';

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
      ThemeHelpers.showThemedSnackBar(
        context,
        message: "Enter Admission No",
        isError: true,
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
      ThemeHelpers.showThemedSnackBar(
        context,
        message: "Student not found",
        isError: true,
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
      ThemeHelpers.showThemedSnackBar(
        context,
        message: "Student updated successfully",
        backgroundColor: AppTheme.successColor,
      );
      Navigator.pop(context); // go back after update
    } else {
      ThemeHelpers.showThemedSnackBar(
        context,
        message: "Failed to update student",
        isError: true,
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
      appBar: AppBar(
        title: Row(
          children: [
            ThemeHelpers.themedAvatar(
              size: 40,
              icon: Icons.edit_outlined, // Edit icon
            ),
            const SizedBox(width: 12),
            Text(
              "Edit Student",
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ],
        ),
      ),
      body: ThemeHelpers.gradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Step 1: Admission No field
              ThemeHelpers.themedTextField(
                controller: _admissionNoController,
                labelText: "Enter Admission No",
              ),
              const SizedBox(height: 16),
              ThemeHelpers.themedButton(
                text: "Fetch Student",
                onPressed: fetchStudent,
                style: AppButtonStyles.blueButton,
              ),

              const SizedBox(height: 20),

              if (isLoading) 
                Center(child: ThemedWidgets.loadingIndicator(message: 'Loading student...')),

              // Step 2: Editable form
              if (studentData != null)
                Expanded(
                  child: ThemeHelpers.themedCard(
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
                        ThemeHelpers.themedButton(
                          text: "Save Changes",
                          onPressed: updateStudent,
                          style: AppButtonStyles.tealButton,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}