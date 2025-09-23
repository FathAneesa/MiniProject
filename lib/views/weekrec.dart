import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import '../config.dart';
import '../theme/app_theme.dart';
import '../theme/theme_helpers.dart';

class WeeklyProgressPage extends StatefulWidget {
  final String studentId;
  const WeeklyProgressPage({super.key, required this.studentId});

  @override
  State<WeeklyProgressPage> createState() => _WeeklyProgressPageState();
}

class _WeeklyProgressPageState extends State<WeeklyProgressPage> {
  bool isLoading = true;
  Map<String, dynamic>? weeklyData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchWeeklyData();
  }

  Future<void> fetchWeeklyData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Fetch data from the recommendations endpoint which contains both academic and wellness data
      final url = Uri.parse('$apiBaseUrl/recommendations/${widget.studentId}');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        setState(() {
          weeklyData = {
            'analytics': {
              'currentMark': data['currentMark'] ?? 0,
              'currentStudyHours': data['currentStudyHours'] ?? 0,
              'currentFocusLevel': data['currentFocusLevel'] ?? 0,
              'avgScreenTime': data['avgScreenTime'] ?? 0,
              'avgNightUsage': data['avgNightUsage'] ?? 0,
              'avgAcademicAppRatio': data['avgAcademicAppRatio'] ?? 0,
            }
          };
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        // Student not found or no academic data
        setState(() {
          errorMessage = 'No academic data found. Please enter your academic performance in the dashboard first.';
          isLoading = false;
        });
      } else {
        // Other HTTP errors - fallback to mock data
        print('Server error ${response.statusCode}, falling back to demo data');
        generateMockData();
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Network error - fallback to mock data for demonstration
      generateMockData();
    }
  }

  void generateMockData() {
    print('Generating mock weekly progress data...');
    
    setState(() {
      weeklyData = {
        'analytics': {
          'currentMark': 85,
          'currentStudyHours': 4,
          'currentFocusLevel': 7.5,
          'avgScreenTime': 6.2,
          'avgNightUsage': 1.8,
          'avgAcademicAppRatio': 0.65,
        }
      };
      isLoading = false;
      print('Mock data generated successfully');
    });
  }

  Widget _buildAcademicChart() {
    if (weeklyData?['analytics'] == null) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'No academic data available',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    final analytics = weeklyData!['analytics'];
    final currentMark = (analytics['currentMark'] ?? 0).toDouble();
    final studyHours = (analytics['currentStudyHours'] ?? 0).toDouble();
    final focusLevel = (analytics['currentFocusLevel'] ?? 0).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppTheme.primaryColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              List<String> labels = ['Marks', 'Study Hours', 'Focus Level'];
              List<double> values = [currentMark, studyHours * 10, focusLevel * 10]; // Scale study hours and focus level
              
              final index = group.x.toInt();
              if (index >= 0 && index < labels.length) {
                return BarTooltipItem(
                  '${labels[index]}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '${values[index].toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }
              return null;
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                List<String> labels = ['Marks', 'Study\nHours', 'Focus\nLevel'];
                final index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
          ),
        ),
        gridData: const FlGridData(show: true),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: currentMark,
                color: AppTheme.primaryColor.withOpacity(0.7),
                width: 20,
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: studyHours * 10, // Scale to 0-100 range
                color: AppTheme.secondaryColor.withOpacity(0.7),
                width: 20,
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: focusLevel * 10, // Scale to 0-100 range
                color: AppTheme.accentTeal.withOpacity(0.7),
                width: 20,
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessChart() {
    if (weeklyData?['analytics'] == null) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'No wellness data available',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    final analytics = weeklyData!['analytics'];
    final focusLevel = (analytics['currentFocusLevel'] ?? 0).toDouble();
    final screenTime = (analytics['avgScreenTime'] ?? 0).toDouble();
    final nightUsage = (analytics['avgNightUsage'] ?? 0).toDouble();

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: AppTheme.primaryColor,
            value: focusLevel * 10, // Scale to 0-100
            title: 'Focus',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: AppTheme.secondaryColor,
            value: screenTime * 4, // Scale to 0-100 (assuming max 24 hours)
            title: 'Screen Time',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: AppTheme.accentTeal,
            value: nightUsage * 10, // Scale to 0-100 (assuming max 10 hours)
            title: 'Night Usage',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildCombinedChart() {
    if (weeklyData?['analytics'] == null) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'No data available for combined chart',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    final analytics = weeklyData!['analytics'];
    final currentMark = (analytics['currentMark'] ?? 0).toDouble();
    final focusLevel = (analytics['currentFocusLevel'] ?? 0).toDouble();
    final screenTime = (analytics['avgScreenTime'] ?? 0).toDouble();
    final nightUsage = (analytics['avgNightUsage'] ?? 0).toDouble();

    // Prepare line chart data
    List<FlSpot> academicSpots = [
      const FlSpot(0, 75),
      const FlSpot(1, 80),
      const FlSpot(2, 78),
      FlSpot(3, currentMark),
      const FlSpot(4, 82),
      const FlSpot(5, 88),
      const FlSpot(6, 90),
    ];
    
    List<FlSpot> wellnessSpots = [
      const FlSpot(0, 60),
      const FlSpot(1, 65),
      const FlSpot(2, 70),
      FlSpot(3, focusLevel * 10), // Scale focus level to 0-100
      const FlSpot(4, 72),
      const FlSpot(5, 75),
      const FlSpot(6, 80),
    ];

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: academicSpots,
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          LineChartBarData(
            spots: wellnessSpots,
            isCurved: true,
            color: AppTheme.accentTeal,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: AppTheme.accentTeal.withOpacity(0.3)),
          ),
        ],
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                final index = value.toInt();
                if (index >= 0 && index < days.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      days[index],
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
          ),
        ),
        gridData: const FlGridData(show: true),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 100,
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
              icon: Icons.bar_chart_outlined,
            ),
            const SizedBox(width: 12),
            Text(
              'Weekly Progress',
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchWeeklyData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: ThemeHelpers.gradientBackground(
        child: isLoading
            ? Center(
                child: ThemedWidgets.loadingIndicator(
                  message: 'Loading weekly progress data...',
                ),
              )
            : errorMessage != null
                ? ThemedWidgets.emptyState(
                    title: 'Unable to Load Data',
                    subtitle: errorMessage!,
                    icon: Icons.error_outline,
                    action: ThemeHelpers.themedButton(
                      text: 'Retry',
                      onPressed: fetchWeeklyData,
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Academic Performance Chart
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Academic Performance',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 250,
                                child: _buildAcademicChart(),
                              ),
                            ],
                          ),
                        ),
                        
                        // Wellness Metrics Chart
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Wellness Metrics',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 250,
                                child: _buildWellnessChart(),
                              ),
                            ],
                          ),
                        ),
                        
                        // Combined Progress Chart
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weekly Progress Trend',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 250,
                                child: _buildCombinedChart(),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
      ),
    );
  }
}