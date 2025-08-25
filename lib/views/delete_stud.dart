import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

class DeleteStud extends StatefulWidget {
  const DeleteStud({super.key});

  @override
  State<DeleteStud> createState() => _DeleteStudState();
}

class _DeleteStudState extends State<DeleteStud> {
  final _admissionNoController = TextEditingController();
  bool _loading = false;

  Future<void> _deleteStudent() async {
    if (_admissionNoController.text.isEmpty) return;

    setState(() => _loading = true);

    final url = Uri.parse('$apiBaseUrl/student/${_admissionNoController.text}');
    final res = await http.delete(url);

    setState(() => _loading = false);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student deleted successfully")),
      );
      Navigator.pop(context, true); // Let previous page refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete: ${res.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 166, 209),
      appBar: AppBar(
        title: Text(
          "Delete Student",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color.fromARGB(255, 234, 104, 191),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top header section with bold title
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red[100],
            child: Text(
              "Enter Admission Number to Delete Student Record",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 242, 139, 211),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _admissionNoController,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      labelText: "Admission No",
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 241, 199, 243),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _deleteStudent,
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                    label: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Delete", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 139, 66, 107),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
