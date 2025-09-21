import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart'; // Import for apiBaseUrl
import '../theme/app_theme.dart';
import '../theme/theme_helpers.dart';

class AddStud extends StatefulWidget {
  const AddStud({super.key});

  @override
  State<AddStud> createState() => _AddStudState();
}

class _AddStudState extends State<AddStud> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _admissionNoController = TextEditingController();
  final TextEditingController _academicYearController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // Added Email
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _parentPhoneController = TextEditingController();
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _guardianPhoneController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedSemester;
  String? _selectedGender;

  final List<String> departments = ['MCA', 'MBA'];
  final List<String> semesters = ['1', '2', '3', '4'];
  final List<String> genders = ['Male', 'Female', 'Other'];
Future<void> _saveStudent() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    final studentData = {
      "Student Name": _studentNameController.text.trim(),
      "Admission No": _admissionNoController.text.trim(),
      "Academic Year": _academicYearController.text.trim(),
      "Phone": _phoneController.text.trim(),
      "Email": _emailController.text.trim(),
      "dob": _dobController.text.trim(),   // 👈 match backend key (lowercase)
      "Father Name": _fatherNameController.text.trim(),
      "Mother Name": _motherNameController.text.trim(),
      "Address": _addressController.text.trim(),
      "Parent Phone": _parentPhoneController.text.trim(),
      "Guardian Name": _guardianNameController.text.trim(),
      "Guardian Phone": _guardianPhoneController.text.trim(),
      "Department": _selectedDepartment ?? '',
      "Semester": _selectedSemester ?? '',
      "Gender": _selectedGender ?? '',
    };

    final url = Uri.parse('$apiBaseUrl/Students/add'); // 👈 backend route (case-sensitive!)
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(studentData),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // ✅ Use backend-generated credentials
        String username = data['username'];
        String password = data['password'];

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ThemeHelpers.themedAvatar(
                  size: 80,
                  icon: Icons.check_circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.successColor, AppTheme.successColor.withOpacity(0.7)],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Student Saved Successfully!",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  "User ID: $username",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  "Password: $password",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                ThemeHelpers.themedButton(
                  text: "OK",
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to admin dash
                  },
                ),
              ],
            ),
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        ThemeHelpers.showThemedSnackBar(
          context,
          message: "Error: ${error['detail'] ?? 'Could not save student'}",
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ThemeHelpers.showThemedSnackBar(
        context,
        message: "Network Error: $e",
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}


  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool isMultiline = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: isMultiline ? 3 : 1,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? 'Please select $label' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
              icon: Icons.person_add_outlined, // Add student icon
            ),
            const SizedBox(width: 12),
            Text(
              "Add Student",
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ],
        ),
      ),
      body: ThemeHelpers.gradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ThemeHelpers.themedCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              _buildTextField(
                "Institution Name",
                TextEditingController(text: "KMCT School of Business"),
                readOnly: true,
              ),
              _buildTextField("Student Name", _studentNameController),
              _buildTextField(
                "Admission Number",
                _admissionNoController,
                isNumber: true,
              ),
              _buildDropdown(
                "Department",
                _selectedDepartment,
                departments,
                (val) => setState(() => _selectedDepartment = val),
              ),
              _buildTextField("Academic Year", _academicYearController),
              _buildDropdown(
                "Semester",
                _selectedSemester,
                semesters,
                (val) => setState(() => _selectedSemester = val),
              ),
              _buildTextField("Phone Number", _phoneController, isNumber: true),
              _buildTextField("Email ID", _emailController), // Added Email Field
              _buildDropdown(
                "Gender",
                _selectedGender,
                genders,
                (val) => setState(() => _selectedGender = val),
              ),
              _buildTextField(
                "Date of Birth",
                _dobController,
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1980),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    _dobController.text =
                        "${picked.day}-${picked.month}-${picked.year}";
                  }
                },
              ),
              _buildTextField("Father's Name", _fatherNameController),
              _buildTextField("Mother's Name", _motherNameController),
              _buildTextField("Address", _addressController, isMultiline: true),
              _buildTextField(
                "Parent's Phone Number",
                _parentPhoneController,
                isNumber: true,
              ),
              _buildTextField("Guardian Name", _guardianNameController),
              _buildTextField(
                "Guardian Phone Number",
                _guardianPhoneController,
                isNumber: true,
              ),
              const SizedBox(height: 20),
              Center(
                child: ThemeHelpers.themedButton(
                  text: "Save Student",
                  onPressed: _isLoading ? () {} : _saveStudent,
                  style: _isLoading 
                    ? AppButtonStyles.primaryButton.copyWith(
                        backgroundColor: MaterialStateProperty.all(
                          AppTheme.primaryColor.withOpacity(0.6)
                        ),
                      ) 
                    : AppButtonStyles.primaryButton,
                ),
              ),
              if (_isLoading) ...[
                const SizedBox(height: 16),
                Center(
                  child: ThemedWidgets.loadingIndicator(message: 'Saving student...'),
                ),
              ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}