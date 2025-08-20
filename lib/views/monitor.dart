import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key});

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  // API base URL → replace with your backend URL if deployed
  static const String apiBaseUrl = "http://10.0.2.2:8000"; // For Android emulator
  // For web/desktop → "http://localhost:8000"

  List<String> lastLogins = [];
  Map<String, int> entriesPerDay = {};
  bool isLoading = true;
  bool showBarChart = true;

  @override
  void initState() {
    super.initState();
    fetchMonitorData();
  }

  Future<void> fetchMonitorData() async {
    try {
      final response = await http.get(Uri.parse("$apiBaseUrl/monitor"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          // ✅ Parse "lastLogins" from backend
          lastLogins = (data["lastLogins"] as List)
              .map((e) => "${e['student']} logged in at ${e['time']}")
              .toList();

          // ✅ Parse "entriesPerDay" safely
          entriesPerDay = Map<String, int>.from(data["entriesPerDay"]);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load monitor data");
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  // 🔹 Bar Chart
  Widget buildBarChart() {
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final days = entriesPerDay.keys.toList();
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Text(
                    days[value.toInt()],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        barGroups: entriesPerDay.entries
            .toList()
            .asMap()
            .entries
            .map(
              (entry) => BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.value.toDouble(),
                    color: Colors.tealAccent,
                    width: 14,
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  // 🔹 Line Chart
  Widget buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final days = entriesPerDay.keys.toList();
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Text(
                    days[value.toInt()],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: entriesPerDay.entries
                .toList()
                .asMap()
                .entries
                .map((entry) =>
                    FlSpot(entry.key.toDouble(), entry.value.value.toDouble()))
                .toList(),
            isCurved: true,
            color: Colors.tealAccent,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.tealAccent.withOpacity(0.3),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: Text(
          "Monitor Data Flow",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ✅ Last 10 Logins
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[800],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Last 10 Logins",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (lastLogins.isEmpty)
                            Text(
                              "No recent logins found.",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ...lastLogins.map(
                            (log) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                log,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ✅ Entries Per Day (Chart)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[800],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Data Entries Per Day",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 220,
                            child: entriesPerDay.isEmpty
                                ? Center(
                                    child: Text(
                                      "No data available",
                                      style: GoogleFonts.poppins(
                                          color: Colors.white70),
                                    ),
                                  )
                                : (showBarChart
                                    ? buildBarChart()
                                    : buildLineChart()),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() => showBarChart = true);
                                },
                                child: const Text(
                                  "Bar Chart",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() => showBarChart = false);
                                },
                                child: const Text(
                                  "Line Chart",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
