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

  // Validation functions
  String? _validateStudentName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Student name is required';
    }
    if (value.trim().length < 2) {
      return 'Student name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Student name can only contain letters and spaces';
    }
    return null;
  }

  String? _validateAdmissionNo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Admission number is required';
    }
    if (value.trim().length < 4) {
      return 'Admission number must be at least 4 characters';
    }
    return null;
  }

  String? _validateAcademicYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Academic year is required';
    }
    // Format: 2023-2024 or 2023-24
    if (!RegExp(r'^\d{4}-\d{2,4}$').hasMatch(value.trim())) {
      return 'Academic year format: 2023-2024 or 2023-24';
    }
    
    // Extract years from the format
    List<String> parts = value.trim().split('-');
    if (parts.length != 2) {
      return 'Invalid academic year format';
    }
    
    int startYear = int.tryParse(parts[0]) ?? 0;
    int endYear = int.tryParse(parts[1]) ?? 0;
    
    // Handle 2-digit end year (e.g., 23 for 2023)
    if (parts[1].length == 2) {
      // Assume it's in the same century as the start year
      int century = (startYear ~/ 100) * 100;
      endYear = century + endYear;
      
      // Handle century boundary case (e.g., 99 -> 2099, but if start is 2023, it should be 2199 or 2099?)
      // More reasonable: if endYear < startYear, add 100 years
      if (endYear < startYear && startYear - endYear > 50) {
        endYear += 100;
      }
    }
    
    // Validate that start year is less than end year
    if (startYear >= endYear) {
      return 'Start year must be less than end year';
    }
    
    // Validate that the years are reasonable (not too far in the past or future)
    int currentYear = DateTime.now().year;
    if (startYear < currentYear - 10 || startYear > currentYear + 10) {
      return 'Start year is not within a reasonable range';
    }
    
    if (endYear < currentYear - 10 || endYear > currentYear + 10) {
      return 'End year is not within a reasonable range';
    }
    
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim())) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateParentName(String? value, String parentType) {
    if (value == null || value.trim().isEmpty) {
      return '$parentType name is required';
    }
    if (value.trim().length < 2) {
      return '$parentType name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return '$parentType name can only contain letters and spaces';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 10) {
      return 'Address must be at least 10 characters';
    }
    return null;
  }

  String? _validateGuardianName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Guardian name is required';
    }
    if (value.trim().length < 2) {
      return 'Guardian name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Guardian name can only contain letters and spaces';
    }
    return null;
  }

  String? _validateDOB(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date of birth is required';
    }
    
    try {
      // Parse the date from DD-MM-YYYY format
      List<String> parts = value.trim().split('-');
      if (parts.length != 3) {
        return 'Invalid date format';
      }
      
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);
      
      // Validate individual components
      if (day < 1 || day > 31) {
        return 'Invalid day';
      }
      if (month < 1 || month > 12) {
        return 'Invalid month';
      }
      if (year < 1950 || year > DateTime.now().year) {
        return 'Invalid year';
      }
      
      DateTime birthDate = DateTime(year, month, day);
      DateTime today = DateTime.now();
      DateTime minimumBirthDate = DateTime(today.year - 60, today.month, today.day); // Maximum 60 years old
      DateTime maximumBirthDate = DateTime(today.year - 16, today.month, today.day); // Minimum 16 years old
      
      // Check if the birth date is today or in the future
      if (birthDate.isAfter(today) || _isSameDate(birthDate, today)) {
        return 'Date of birth cannot be today or in the future';
      }
      
      // Calculate exact age in years
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || 
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      
      // Check if the student is at least 16 years old
      if (age < 16) {
        return 'Student must be at least 16 years old (currently $age years)';
      }
      
      // Check if the student is not older than 60 years
      if (age > 60) {
        return 'Student age cannot exceed 60 years (currently $age years)';
      }
      
    } catch (e) {
      return 'Invalid date format (DD-MM-YYYY required)';
    }
    
    return null;
  }
  
  // Helper method to check if two dates are the same
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
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
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: isMultiline ? 3 : 1,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        autovalidateMode: AutovalidateMode.onUserInteraction, // Real-time validation
        validator: validator ?? (value) => value!.isEmpty ? 'Please enter $label' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: AppTheme.textSecondary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.errorColor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ))
            .toList(),
        onChanged: onChanged,
        autovalidateMode: AutovalidateMode.onUserInteraction, // Real-time validation
        validator: (val) => val == null ? 'Please select $label' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: AppTheme.textSecondary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.errorColor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        dropdownColor: Colors.white,
        style: GoogleFonts.poppins(
          color: AppTheme.textPrimary,
          fontSize: 16,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: AppTheme.primaryColor,
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
              _buildTextField(
                "Student Name", 
                _studentNameController,
                validator: _validateStudentName,
              ),
              _buildTextField(
                "Admission Number",
                _admissionNoController,
                isNumber: true,
                validator: _validateAdmissionNo,
              ),
              _buildDropdown(
                "Department",
                _selectedDepartment,
                departments,
                (val) => setState(() => _selectedDepartment = val),
              ),
              _buildTextField(
                "Academic Year", 
                _academicYearController,
                validator: _validateAcademicYear,
              ),
              _buildDropdown(
                "Semester",
                _selectedSemester,
                semesters,
                (val) => setState(() => _selectedSemester = val),
              ),
              _buildTextField(
                "Phone Number", 
                _phoneController, 
                isNumber: true,
                validator: _validatePhone,
              ),
              _buildTextField(
                "Email ID", 
                _emailController,
                validator: _validateEmail,
              ),
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
                validator: _validateDOB,
                onTap: () async {
                  DateTime today = DateTime.now();
                  // More restrictive date constraints
                  DateTime minimumDate = DateTime(today.year - 60, 1, 1); // 60 years ago (start of year)
                  DateTime maximumDate = DateTime(today.year - 16, today.month, today.day); // Exactly 16 years ago
                  
                  // Ensure maximum date is not today or in the future
                  if (maximumDate.isAfter(today) || _isSameDate(maximumDate, today)) {
                    maximumDate = DateTime(today.year - 17, today.month, today.day);
                  }
                  
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(today.year - 20, today.month, today.day), // Default to 20 years ago
                    firstDate: minimumDate, // Minimum: 60 years ago
                    lastDate: maximumDate,  // Maximum: at least 16 years ago
                    helpText: 'Select Date of Birth (DD-MM-YYYY)',
                    errorFormatText: 'Enter a valid date',
                    errorInvalidText: 'Student must be 16-60 years old',
                    confirmText: 'SELECT',
                    cancelText: 'CANCEL',
                  );
                  if (picked != null) {
                    // Double-check the selected date is valid
                    DateTime now = DateTime.now();
                    if (picked.isAfter(now) || _isSameDate(picked, now)) {
                      ThemeHelpers.showThemedSnackBar(
                        context,
                        message: "Cannot select today's date or future date as birth date",
                        isError: true,
                      );
                      return;
                    }
                    
                    _dobController.text =
                        "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
                  }
                },
              ),
              _buildTextField(
                "Father's Name", 
                _fatherNameController,
                validator: (value) => _validateParentName(value, "Father's"),
              ),
              _buildTextField(
                "Mother's Name", 
                _motherNameController,
                validator: (value) => _validateParentName(value, "Mother's"),
              ),
              _buildTextField(
                "Address", 
                _addressController, 
                isMultiline: true,
                validator: _validateAddress,
              ),
              _buildTextField(
                "Parent's Phone Number",
                _parentPhoneController,
                isNumber: true,
                validator: _validatePhone,
              ),
              _buildTextField(
                "Guardian Name", 
                _guardianNameController,
                validator: _validateGuardianName,
              ),
              _buildTextField(
                "Guardian Phone Number",
                _guardianPhoneController,
                isNumber: true,
                validator: _validatePhone,
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