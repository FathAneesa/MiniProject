import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart'; // Provides apiBaseUrl

class StoreStud extends StatefulWidget {
  const StoreStud({super.key});

  @override
  State<StoreStud> createState() => _StoreStudState();
}

class _StoreStudState extends State<StoreStud> {
  late Future<List<dynamic>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _fetchStudents();
  }

  Future<List<dynamic>> _fetchStudents() async {
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
        title: Text("Stored Student Details", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
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
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No student data found."));
          }

          final studentList = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.blue.shade100),
                columns: const [
                  DataColumn(label: Text("Student Name")),
                  DataColumn(label: Text("Admission No")),
                  DataColumn(label: Text("Department")),
                  DataColumn(label: Text("Academic Year")),
                  DataColumn(label: Text("Semester")),
                  DataColumn(label: Text("Phone Number")),
                  DataColumn(label: Text("Gender")),
                  DataColumn(label: Text("DOB")),
                  DataColumn(label: Text("Father's Name")),
                  DataColumn(label: Text("Mother's Name")),
                  DataColumn(label: Text("Address")),
                  DataColumn(label: Text("Parent's Phone")),
                  DataColumn(label: Text("Guardian Name")),
                  DataColumn(label: Text("Guardian Phone")),
                  DataColumn(label: Text("User ID")),
                ],
                rows: studentList.map((student) {
                  return DataRow(cells: [
                    DataCell(Text(student["Student Name"]?.toString() ?? "")),
                    DataCell(Text(student["Admission No"]?.toString() ?? "")),
                    DataCell(Text(student["Department"]?.toString() ?? "")),
                    DataCell(Text(student["Academic Year"]?.toString() ?? "")),
                    DataCell(Text(student["Semester"]?.toString() ?? "")),
                    DataCell(Text(student["Phone"]?.toString() ?? "")),
                    DataCell(Text(student["Gender"]?.toString() ?? "")),
                    DataCell(Text(student["DOB"]?.toString() ?? "")),
                    DataCell(Text(student["Father Name"]?.toString() ?? "")),
                    DataCell(Text(student["Mother Name"]?.toString() ?? "")),
                    DataCell(Text(student["Address"]?.toString() ?? "")),
                    DataCell(Text(student["Parent Phone"]?.toString() ?? "")),
                    DataCell(Text(student["Guardian Name"]?.toString() ?? "")),
                    DataCell(Text(student["Guardian Phone"]?.toString() ?? "")),
                    DataCell(Text(student["UserID"]?.toString() ?? "")),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}