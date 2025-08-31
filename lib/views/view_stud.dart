import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiBaseUrl = "http://192.168.29.37:8000"; // Your LAN IP

class ViewStud extends StatefulWidget {
  const ViewStud({super.key});

  @override
  State<ViewStud> createState() => _ViewStudState();
}

class _ViewStudState extends State<ViewStud> {
  late Future<List<dynamic>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = fetchStudents();
  }

  Future<List<dynamic>> fetchStudents() async {
    final url = Uri.parse('$apiBaseUrl/students');
    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load students. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load students: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Student Details",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No student data found."));
          }

          final students = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
                columns: const [
                  DataColumn(label: Text("Student Name")),
                  DataColumn(label: Text("Admission No")),
                  DataColumn(label: Text("Department")),
                  DataColumn(label: Text("Academic Year")),
                  DataColumn(label: Text("Semester")),
                  DataColumn(label: Text("Phone")),
                  DataColumn(label: Text("Email")),
                  DataColumn(label: Text("Gender")),
                  DataColumn(label: Text("DOB")),
                  DataColumn(label: Text("Father Name")),
                  DataColumn(label: Text("Mother Name")),
                  DataColumn(label: Text("Address")),
                  DataColumn(label: Text("Parent Phone")),
                  DataColumn(label: Text("Guardian Name")),
                  DataColumn(label: Text("Guardian Phone")),
                  DataColumn(label: Text("UserID")),
                ],
                rows: students.map((student) {
                  return DataRow(
                    cells: [
                      DataCell(Text(student["Student Name"]?.toString() ?? "")),
                      DataCell(Text(student["Admission No"]?.toString() ?? "")),
                      DataCell(Text(student["Department"]?.toString() ?? "")),
                      DataCell(Text(student["Academic Year"]?.toString() ?? "")),
                      DataCell(Text(student["Semester"]?.toString() ?? "")),
                      DataCell(Text(student["Phone"]?.toString() ?? "")),
                      DataCell(Text(student["Email"]?.toString() ?? "")),
                      DataCell(Text(student["Gender"]?.toString() ?? "")),
                      DataCell(Text(student["dob"]?.toString() ?? "")),
                      DataCell(Text(student["Father Name"]?.toString() ?? "")),
                      DataCell(Text(student["Mother Name"]?.toString() ?? "")),
                      DataCell(Text(student["Address"]?.toString() ?? "")),
                      DataCell(Text(student["Parent Phone"]?.toString() ?? "")),
                      DataCell(Text(student["Guardian Name"]?.toString() ?? "")),
                      DataCell(Text(student["Guardian Phone"]?.toString() ?? "")),
                      DataCell(Text(student["UserID"]?.toString() ?? "")),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
