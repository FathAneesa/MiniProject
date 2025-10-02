import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart'; // Import the centralized config
import '../theme/app_theme.dart';
import '../theme/theme_helpers.dart';

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
    // Show confirmation dialog before deleting
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Confirm Delete",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this subject? This action cannot be undone.",
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: AppTheme.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Delete",
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );

    // If user didn't confirm, return early
    if (confirm != true) return;

    // Proceed with deletion
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
          ThemeHelpers.showThemedSnackBar(
            context,
            message: "Subject deleted successfully",
          );
        } else {
          ThemeHelpers.showThemedSnackBar(
            context,
            message: "Failed to delete subject: ${decoded["message"] ?? "Unknown error"}",
            isError: true,
          );
        }
      } else {
        debugPrint("❌ Failed to delete subject: ${response.body}");
        ThemeHelpers.showThemedSnackBar(
          context,
          message: "Failed to delete subject. Server error.",
          isError: true,
        );
      }
    } catch (e) {
      debugPrint("❌ Error deleting subject: $e");
      ThemeHelpers.showThemedSnackBar(
        context,
        message: "Error deleting subject: $e",
        isError: true,
      );
    }
  }

Future<void> editSubject(int index) async {
  final subject = subjects[index];
  final nameController = TextEditingController(text: subject["name"]);
  final markController = TextEditingController(text: subject["mark"].toString());

  // Show custom dialog with themed text fields
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        "Edit Subject",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: "Subject Name",
              labelStyle: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: markController,
            decoration: InputDecoration(
              labelText: "Marks (0-100)",
              labelStyle: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            // Validate marks input
            final markText = markController.text;
            final mark = int.tryParse(markText);
            
            if (mark == null || mark < 0 || mark > 100) {
              ThemeHelpers.showThemedSnackBar(
                context,
                message: "Marks must be a number between 0 and 100",
                isError: true,
              );
              return;
            }

            final updatedSubject = {
              "name": nameController.text,
              "mark": mark,
            };

            try {
              final response = await http.put(
                Uri.parse("$apiBaseUrl/academics/${widget.studentId}/subjects/$index"),
                headers: {"Content-Type": "application/json"},
                body: json.encode(updatedSubject),
              );

              if (response.statusCode == 200) {
                final decoded = json.decode(response.body);
                if (decoded["status"] == "success") {
                  setState(() {
                    subjects[index] = updatedSubject;
                  });
                  Navigator.pop(context); // Close the dialog
                  ThemeHelpers.showThemedSnackBar(
                    context,
                    message: "Subject updated successfully",
                  );
                }
              } else {
                Navigator.pop(context); // Close the dialog
                ThemeHelpers.showThemedSnackBar(
                  context,
                  message: "Failed to update subject",
                  isError: true,
                );
              }
            } catch (e) {
              Navigator.pop(context); // Close the dialog
              ThemeHelpers.showThemedSnackBar(
                context,
                message: "Error updating subject: $e",
                isError: true,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: AppTheme.textOnPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            "Save",
            style: GoogleFonts.poppins(),
          ),
        ),
      ],
    ),
  );
}

Future<void> editStudyInfo() async {
  final studyHoursController = TextEditingController(text: studyHours?.toString() ?? "");
  final focusLevelController = TextEditingController(text: focusLevel?.toString() ?? "");

  // Show custom dialog with themed text fields
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        "Edit Study Information",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: studyHoursController,
            decoration: InputDecoration(
              labelText: "Study Hours (per day)",
              labelStyle: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: focusLevelController,
            decoration: InputDecoration(
              labelText: "Focus Level (out of 10)",
              labelStyle: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            // Validate inputs
            final studyHoursText = studyHoursController.text;
            final focusLevelText = focusLevelController.text;
            
            final studyHoursValue = double.tryParse(studyHoursText);
            final focusLevelValue = double.tryParse(focusLevelText);
            
            if (studyHoursValue == null || studyHoursValue < 0) {
              ThemeHelpers.showThemedSnackBar(
                context,
                message: "Study hours must be a positive number",
                isError: true,
              );
              return;
            }
            
            if (focusLevelValue == null || focusLevelValue < 0 || focusLevelValue > 10) {
              ThemeHelpers.showThemedSnackBar(
                context,
                message: "Focus level must be a number between 0 and 10",
                isError: true,
              );
              return;
            }

            try {
              // Update study info using the new endpoint
              final response = await http.put(
                Uri.parse("$apiBaseUrl/academics/${widget.studentId}/study-info"),
                headers: {"Content-Type": "application/json"},
                body: json.encode({
                  "studentId": widget.studentId,
                  "studyHours": studyHoursValue.toString(),
                  "focusLevel": focusLevelValue.toString(),
                  "subjects": subjects,
                  "overallMark": _calculateOverallMark(),
                }),
              );

              debugPrint("Response status: ${response.statusCode}");
              debugPrint("Response body: ${response.body}");

              if (response.statusCode == 200) {
                final decoded = json.decode(response.body);
                if (decoded["status"] == "success") {
                  setState(() {
                    studyHours = studyHoursValue.toInt();
                    focusLevel = focusLevelValue.toInt();
                  });
                  Navigator.pop(context); // Close the dialog
                  ThemeHelpers.showThemedSnackBar(
                    context,
                    message: "✅ Academic data saved! Your recommendations will be updated.",
                  );
                  // Refresh the data to ensure consistency
                  fetchAcademicData();
                } else {
                  Navigator.pop(context); // Close the dialog
                  ThemeHelpers.showThemedSnackBar(
                    context,
                    message: "Failed to update study information: ${decoded["message"] ?? "Unknown error"}",
                    isError: true,
                  );
                }
              } else {
                Navigator.pop(context); // Close the dialog
                ThemeHelpers.showThemedSnackBar(
                  context,
                  message: "Failed to update study information. Server error: ${response.statusCode}",
                  isError: true,
                );
              }
            } catch (e) {
              debugPrint("Error updating study information: $e");
              Navigator.pop(context); // Close the dialog
              ThemeHelpers.showThemedSnackBar(
                context,
                message: "Error updating study information: $e",
                isError: true,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: AppTheme.textOnPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            "Save",
            style: GoogleFonts.poppins(),
          ),
        ),
      ],
    ),
  );
}

int _calculateOverallMark() {
  if (subjects.isEmpty) return 0;
  
  int total = 0;
  int count = 0;
  
  for (var subject in subjects) {
    var mark = subject["mark"];
    if (mark is int) {
      total += mark;
      count++;
    } else if (mark is String) {
      int? markValue = int.tryParse(mark);
      if (markValue != null) {
        total += markValue;
        count++;
      }
    }
  }
  
  return count > 0 ? (total ~/ count) : 0;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemeHelpers.dashboardBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header section with themed avatar and title
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.textOnPrimary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ThemeHelpers.themedAvatar(
                      size: 50,
                      icon: Icons.school_outlined, // Academic/education icon
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'View Academic Data',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textOnPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content section
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: isLoading
                        ? Center(
                            child: ThemedWidgets.loadingIndicator(
                              message: 'Loading academic data...',
                            ),
                          )
                        : subjects.isEmpty
                            ? ThemedWidgets.emptyState(
                                title: "No Academic Data Found",
                                subtitle: "No academic data available for this student.",
                                icon: Icons.school_outlined,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header row
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.primaryColor.withOpacity(0.1),
                                          AppTheme.secondaryColor.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            "Subjects",
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "Marks",
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 80), // Space for action buttons
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Subjects list
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: subjects.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: const EdgeInsets.symmetric(vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppTheme.cardBackground.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: AppTheme.primaryColor.withOpacity(0.2),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTheme.primaryColor.withOpacity(0.08),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            title: Text(
                                              subjects[index]["name"] ?? "",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 12, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        AppTheme.primaryColor.withOpacity(0.1),
                                                        AppTheme.secondaryColor.withOpacity(0.1),
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: AppTheme.primaryColor.withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    subjects[index]["mark"].toString(),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.primaryColor,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: AppTheme.primaryColor,
                                                    size: 20,
                                                  ),
                                                  onPressed: () => editSubject(index),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: AppTheme.errorColor,
                                                    size: 20,
                                                  ),
                                                  onPressed: () => deleteSubject(index),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // Study info section
                                  if (studyHours != null || focusLevel != null)
                                    Container(
                                      margin: const EdgeInsets.only(top: 16),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.primaryColor.withOpacity(0.1),
                                            AppTheme.secondaryColor.withOpacity(0.1),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppTheme.primaryColor.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Study Information",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primaryColor,
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: AppTheme.primaryColor,
                                                  size: 20,
                                                ),
                                                onPressed: editStudyInfo,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.schedule,
                                                color: AppTheme.primaryColor,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "Study Hours: ${studyHours ?? "N/A"} hours/day",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.psychology,
                                                color: AppTheme.primaryColor,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "Focus Level: ${focusLevel ?? "N/A"} / 10",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
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