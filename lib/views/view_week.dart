import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import '../config.dart';
import '../theme/app_theme.dart';
import '../theme/theme_helpers.dart';

class ViewWeeklyAnalysis extends StatefulWidget {
  const ViewWeeklyAnalysis({super.key});

  @override
  State<ViewWeeklyAnalysis> createState() => _ViewWeeklyAnalysisState();
}

class _ViewWeeklyAnalysisState extends State<ViewWeeklyAnalysis> {
  bool isLoading = true;
  List<dynamic> recentLogins = [];
  List<dynamic> dailyEntries = [];
  Map<String, dynamic> statistics = {};
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
      // Fetch recent logins with student names
      final loginsUrl = Uri.parse('$apiBaseUrl/monitor');
      final loginsResponse = await http.get(
        loginsUrl,
        headers: {'Content-Type': 'application/json'},
      );

      // Fetch daily login statistics for the past week
      final statsUrl = Uri.parse('$apiBaseUrl/weekly-app-usage');
      final statsResponse = await http.get(
        statsUrl,
        headers: {'Content-Type': 'application/json'},
      );

      if (loginsResponse.statusCode == 200 && statsResponse.statusCode == 200) {
        final loginsData = jsonDecode(loginsResponse.body);
        final statsData = jsonDecode(statsResponse.body);
        
        setState(() {
          recentLogins = List<dynamic>.from(loginsData['last_logins'] ?? []);
          dailyEntries = List<dynamic>.from(statsData['daily_entries'] ?? []);
          statistics = Map<String, dynamic>.from(statsData['statistics'] ?? {});
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch data from server';
          isLoading = false;
        });
        // Generate mock data as fallback
        generateMockData();
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
      // Generate mock data as fallback
      generateMockData();
    }
  }

  void generateMockData() {
    print('Generating mock weekly analysis data...');
    
    setState(() {
      // Mock recent logins data
      recentLogins = [
        {
          "username": "student001",
          "role": "student",
          "time": "2023-06-15 14:30:22",
          "studentName": "Alice Johnson"
        },
        {
          "username": "student002",
          "role": "student",
          "time": "2023-06-15 13:45:10",
          "studentName": "Bob Smith"
        },
        {
          "username": "student003",
          "role": "student",
          "time": "2023-06-15 12:20:05",
          "studentName": "Carol Davis"
        },
        {
          "username": "student004",
          "role": "student",
          "time": "2023-06-15 11:55:33",
          "studentName": "David Wilson"
        },
        {
          "username": "student005",
          "role": "student",
          "time": "2023-06-15 10:40:17",
          "studentName": "Emma Brown"
        },
        {
          "username": "student006",
          "role": "student",
          "time": "2023-06-15 09:30:45",
          "studentName": "Frank Miller"
        },
        {
          "username": "student007",
          "role": "student",
          "time": "2023-06-15 08:45:21",
          "studentName": "Grace Lee"
        },
        {
          "username": "student008",
          "role": "student",
          "time": "2023-06-14 16:20:11",
          "studentName": "Henry Taylor"
        },
        {
          "username": "student009",
          "role": "student",
          "time": "2023-06-14 15:35:44",
          "studentName": "Ivy Chen"
        },
        {
          "username": "student010",
          "role": "student",
          "time": "2023-06-14 14:50:37",
          "studentName": "Jack Anderson"
        }
      ];

      // Mock daily entries data
      dailyEntries = [
        {"date": "2023-06-09", "entryCount": 12},
        {"date": "2023-06-10", "entryCount": 18},
        {"date": "2023-06-11", "entryCount": 9},
        {"date": "2023-06-12", "entryCount": 25},
        {"date": "2023-06-13", "entryCount": 31},
        {"date": "2023-06-14", "entryCount": 22},
        {"date": "2023-06-15", "entryCount": 28},
      ];

      // Mock statistics
      statistics = {
        "total_entries": 145,
        "average_entries": 20.71,
        "highest_entries": 31
      };

      isLoading = false;
      print('Mock data generated successfully');
    });
  }

  String _timeAgo(String dateTimeString) {
    try {
      final DateTime loginTime = DateTime.parse(dateTimeString);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(loginTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  Widget _buildRecentLoginsTable() {
    return Container(
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
            'Recent Student Logins',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          if (recentLogins.isEmpty)
            Container(
              height: 100,
              alignment: Alignment.center,
              child: Text(
                'No login data available',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                horizontalMargin: 16,
                columns: const [
                  DataColumn(label: Text('Student Name')),
                  DataColumn(label: Text('Username')),
                  DataColumn(label: Text('Login Time')),
                ],
                rows: recentLogins.map((login) {
                  return DataRow(
                    cells: [
                      DataCell(Text(login['studentName'] ?? 'Unknown')),
                      DataCell(Text(login['username'] ?? 'Unknown')),
                      DataCell(Text(_timeAgo(login['time']))),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppUsageChart() {
    if (dailyEntries.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'No daily entry data available',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    // Prepare data for bar chart
    List<BarChartGroupData> barGroups = [];
    List<String> dates = [];
    
    for (int i = 0; i < dailyEntries.length && i < 10; i++) {
      final entry = dailyEntries[i];
      final entryCount = entry['entryCount'] ?? 0;
      // Extract just the day number from the date for display
      final dateStr = entry['date'] ?? '';
      final day = dateStr.split('-').last; // Get the day part
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: entryCount.toDouble(),
              color: _getColorForIndex(i),
              width: 20,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
      );
      
      dates.add(day);
    }

    // Find maximum value for chart scaling
    double maxY = 0;
    if (dailyEntries.isNotEmpty) {
      maxY = dailyEntries.map((e) => e['entryCount'] ?? 0).reduce((a, b) => a > b ? a : b).toDouble();
      maxY = maxY * 1.2; // Add 20% padding at the top
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY > 0 ? maxY : 100, // Default to 100 if no data
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppTheme.primaryColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final index = group.x.toInt();
              if (index >= 0 && index < dailyEntries.length) {
                final entry = dailyEntries[index];
                return BarTooltipItem(
                  '${entry['date']}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '${entry['entryCount']} entries',
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
                final index = value.toInt();
                if (index >= 0 && index < dates.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      dates[index],
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
        barGroups: barGroups,
      ),
    );
  }

  Color _getColorForIndex(int index) {
    List<Color> colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentTeal,
      AppTheme.accentOrange,
      AppTheme.primaryColor.withOpacity(0.7),
      AppTheme.secondaryColor.withOpacity(0.7),
      AppTheme.accentTeal.withOpacity(0.7),
      AppTheme.accentOrange.withOpacity(0.7),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ThemeHelpers.themedAvatar(
              size: 40,
              icon: Icons.analytics_outlined,
            ),
            const SizedBox(width: 12),
            Text(
              'Weekly Analysis',
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
                  message: 'Loading weekly analysis data...',
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
                        // Recent Logins Section
                        _buildRecentLoginsTable(),
                        
                        // Daily Entries Chart
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
                                'Daily Entries (Last 7 Days)',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 300,
                                child: _buildAppUsageChart(),
                              ),
                              // Statistics section
                              if (statistics.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Weekly Statistics',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildStatisticCard(
                                            'Total Entries',
                                            statistics['total_entries']?.toString() ?? '0',
                                            Icons.summarize,
                                          ),
                                          _buildStatisticCard(
                                            'Average/Day',
                                            statistics['average_entries']?.toString() ?? '0',
                                            Icons.bar_chart,
                                          ),
                                          _buildStatisticCard(
                                            'Highest Day',
                                            statistics['highest_entries']?.toString() ?? '0',
                                            Icons.trending_up,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

  Widget _buildStatisticCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}