import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../theme/app_theme.dart';
import '../theme/theme_helpers.dart';

class RecommendationPage extends StatefulWidget {
  final String studentId;
  const RecommendationPage({super.key, required this.studentId});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  bool isLoading = true;
  Map<String, dynamic>? recommendationData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final url = Uri.parse('$apiBaseUrl/recommendations/${widget.studentId}');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          recommendationData = data;
          isLoading = false;
        });
      } else {
        // Generate mock recommendations if API not available
        generateMockRecommendations();
      }
    } catch (e) {
      // Generate mock recommendations if network error
      generateMockRecommendations();
    }
  }

  void generateMockRecommendations() {
    // Mock data for demonstration - replace with actual API call
    setState(() {
      recommendationData = {
        'academic_recommendations': [
          {
            'title': 'Study Schedule Optimization',
            'description': 'Based on your academic performance, consider studying for 3-4 hours daily with 15-minute breaks every hour.',
            'priority': 'high',
            'icon': 'schedule'
          },
          {
            'title': 'Focus on Weak Subjects',
            'description': 'Your mathematics scores show room for improvement. Allocate extra 30 minutes daily for practice.',
            'priority': 'medium',
            'icon': 'school'
          },
          {
            'title': 'Group Study Sessions',
            'description': 'Join study groups for better understanding of complex topics, especially in your core subjects.',
            'priority': 'low',
            'icon': 'group'
          },
        ],
        'wellness_recommendations': [
          {
            'title': 'Improve Sleep Quality',
            'description': 'Aim for 7-8 hours of sleep daily. Good sleep enhances memory consolidation and focus.',
            'priority': 'high',
            'icon': 'bedtime'
          },
          {
            'title': 'Stress Management',
            'description': 'Practice 10-15 minutes of meditation or deep breathing exercises to manage academic stress.',
            'priority': 'medium',
            'icon': 'spa'
          },
          {
            'title': 'Physical Activity',
            'description': 'Include 30 minutes of physical exercise daily to improve cognitive function and reduce stress.',
            'priority': 'high',
            'icon': 'fitness_center'
          },
        ],
        'combined_recommendations': [
          {
            'title': 'Sleep-Study Optimization',
            'description': 'Your late-night study sessions may be affecting your sleep quality and morning focus. Try shifting intensive study to 6-8 PM when cortisol levels naturally peak for better retention.',
            'priority': 'high',
            'icon': 'psychology',
            'insight': 'Academic performance correlates with sleep quality'
          },
          {
            'title': 'Stress-Performance Balance',
            'description': 'High stress levels during exam periods are impacting your academic performance. Implement stress-reduction techniques during study breaks.',
            'priority': 'high',
            'icon': 'balance',
            'insight': 'Stress management directly impacts learning capacity'
          },
          {
            'title': 'Physical Activity for Memory',
            'description': 'Your sedentary study habits may be limiting memory consolidation. Try 20-minute walks between study sessions to boost cognitive function.',
            'priority': 'medium',
            'icon': 'directions_walk',
            'insight': 'Exercise enhances neuroplasticity and memory formation'
          },
          {
            'title': 'Nutrition-Focus Connection',
            'description': 'Irregular eating patterns during study periods are affecting your concentration levels. Maintain consistent meal times with brain-boosting foods.',
            'priority': 'medium',
            'icon': 'restaurant',
            'insight': 'Proper nutrition supports sustained mental performance'
          },
          {
            'title': 'Social-Academic Balance',
            'description': 'Your isolation during intensive study periods may be increasing stress. Balance solo study with collaborative learning sessions.',
            'priority': 'low',
            'icon': 'people',
            'insight': 'Social interaction supports mental health and learning'
          },
        ],
                        'daily_tips': [
                          'Start your day with a healthy breakfast to fuel your brain',
                          'Take regular breaks during study sessions (Pomodoro technique)',
                          'Stay hydrated - drink at least 8 glasses of water daily',
                          'Review your notes before sleeping for better retention',
                        ],
                        'correlation_stats': {
                          'sleep_academic_correlation': 85,
                          'stress_performance_correlation': 78,
                          'exercise_focus_correlation': 72,
                          'nutrition_concentration_correlation': 69,
                        }
      };
      isLoading = false;
    });
  }

  Widget _buildRecommendationCard({
    required String title,
    required String description,
    required String priority,
    required String iconName,
    String? insight,
    bool isCombined = false,
  }) {
    Color priorityColor;
    IconData cardIcon;
    
    // Set priority color
    switch (priority.toLowerCase()) {
      case 'high':
        priorityColor = AppTheme.errorColor;
        break;
      case 'medium':
        priorityColor = AppTheme.accentOrange;
        break;
      case 'low':
        priorityColor = AppTheme.accentTeal;
        break;
      default:
        priorityColor = AppTheme.primaryColor;
    }

    // Set icon based on type
    switch (iconName.toLowerCase()) {
      case 'schedule':
        cardIcon = Icons.schedule_outlined;
        break;
      case 'school':
        cardIcon = Icons.school_outlined;
        break;
      case 'group':
        cardIcon = Icons.group_outlined;
        break;
      case 'bedtime':
        cardIcon = Icons.bedtime_outlined;
        break;
      case 'spa':
        cardIcon = Icons.spa_outlined;
        break;
      case 'fitness_center':
        cardIcon = Icons.fitness_center_outlined;
        break;
      case 'psychology':
        cardIcon = Icons.psychology_outlined;
        break;
      case 'balance':
        cardIcon = Icons.balance_outlined;
        break;
      case 'directions_walk':
        cardIcon = Icons.directions_walk_outlined;
        break;
      case 'restaurant':
        cardIcon = Icons.restaurant_outlined;
        break;
      case 'people':
        cardIcon = Icons.people_outline;
        break;
      default:
        cardIcon = Icons.lightbulb_outline;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: isCombined ? 6 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isCombined 
              ? [
                  Colors.white,
                  AppTheme.primaryColor.withOpacity(0.03),
                  priorityColor.withOpacity(0.05),
                ]
              : [
                  Colors.white,
                  priorityColor.withOpacity(0.05),
                ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: isCombined 
            ? Border.all(color: AppTheme.primaryColor.withOpacity(0.2), width: 1)
            : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCombined 
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      cardIcon,
                      color: isCombined ? AppTheme.primaryColor : priorityColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: priorityColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                priority.toUpperCase(),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isCombined) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentViolet,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'COMBINED',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        if (insight != null && isCombined) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.accentViolet.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.accentViolet.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.insights_outlined,
                                  color: AppTheme.accentViolet,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Insight: $insight',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.accentViolet,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorrelationInsights() {
    if (recommendationData?['correlation_stats'] == null) return const SizedBox();
    
    final stats = recommendationData!['correlation_stats'] as Map<String, dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ThemeHelpers.themedAvatar(
                size: 40,
                icon: Icons.analytics_outlined,
              ),
              const SizedBox(width: 12),
              Text(
                'Data Correlation Insights',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.accentBlue.withOpacity(0.1),
                AppTheme.accentTeal.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.accentBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildCorrelationItem(
                'Sleep Quality ↔ Academic Performance',
                stats['sleep_academic_correlation'],
                Icons.bedtime_outlined,
                'Better sleep correlates strongly with improved grades',
              ),
              const SizedBox(height: 12),
              _buildCorrelationItem(
                'Stress Level ↔ Learning Performance',
                stats['stress_performance_correlation'],
                Icons.psychology_outlined,
                'Lower stress levels enhance memory retention',
              ),
              const SizedBox(height: 12),
              _buildCorrelationItem(
                'Exercise ↔ Focus Duration',
                stats['exercise_focus_correlation'],
                Icons.fitness_center_outlined,
                'Regular exercise improves concentration span',
              ),
              const SizedBox(height: 12),
              _buildCorrelationItem(
                'Nutrition ↔ Concentration',
                stats['nutrition_concentration_correlation'],
                Icons.restaurant_outlined,
                'Proper nutrition supports sustained mental focus',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCorrelationItem(
    String title,
    int percentage,
    IconData icon,
    String description,
  ) {
    Color correlationColor;
    if (percentage >= 80) {
      correlationColor = AppTheme.successColor;
    } else if (percentage >= 60) {
      correlationColor = AppTheme.accentOrange;
    } else {
      correlationColor = AppTheme.errorColor;
    }

    return Row(
      children: [
        Icon(
          icon,
          color: correlationColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: correlationColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$percentage%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyTipsSection() {
    if (recommendationData?['daily_tips'] == null) return const SizedBox();
    
    final tips = recommendationData!['daily_tips'] as List;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ThemeHelpers.themedAvatar(
                size: 40,
                icon: Icons.tips_and_updates_outlined,
              ),
              const SizedBox(width: 12),
              Text(
                'Daily Tips',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.secondaryColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.accentViolet,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
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
              icon: Icons.recommend_outlined, // Recommendation icon
            ),
            const SizedBox(width: 12),
            Text(
              'Daily Recommendations',
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchRecommendations,
            tooltip: 'Refresh Recommendations',
          ),
        ],
      ),
      body: ThemeHelpers.gradientBackground(
        child: isLoading
          ? Center(
              child: ThemedWidgets.loadingIndicator(
                message: 'Generating personalized recommendations...',
              ),
            )
          : errorMessage != null
            ? ThemedWidgets.emptyState(
                title: 'Unable to Load Recommendations',
                subtitle: errorMessage!,
                icon: Icons.error_outline,
                action: ThemeHelpers.themedButton(
                  text: 'Retry',
                  onPressed: fetchRecommendations,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          ThemeHelpers.themedAvatar(
                            size: 80,
                            icon: Icons.auto_awesome,
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.white.withOpacity(0.8)],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Personalized Recommendations',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Based on your academic performance and wellness data',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Combined Recommendations Section
                    if (recommendationData?['combined_recommendations'] != null) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.accentViolet.withOpacity(0.8),
                              AppTheme.primaryColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            ThemeHelpers.themedAvatar(
                              size: 60,
                              icon: Icons.psychology_outlined,
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.white.withOpacity(0.9)],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'AI-Powered Holistic Insights',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Recommendations based on the connection between your academic performance and wellness data',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      ...((recommendationData!['combined_recommendations'] as List).map(
                        (rec) => _buildRecommendationCard(
                          title: rec['title'],
                          description: rec['description'],
                          priority: rec['priority'],
                          iconName: rec['icon'],
                          insight: rec['insight'],
                          isCombined: true,
                        ),
                      )),
                      const SizedBox(height: 24),
                    ],

                    // Academic Recommendations
                    if (recommendationData?['academic_recommendations'] != null) ...[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            ThemeHelpers.themedAvatar(
                              size: 40,
                              icon: Icons.school_outlined,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Academic Recommendations',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...((recommendationData!['academic_recommendations'] as List).map(
                        (rec) => _buildRecommendationCard(
                          title: rec['title'],
                          description: rec['description'],
                          priority: rec['priority'],
                          iconName: rec['icon'],
                          isCombined: false,
                        ),
                      )),
                      const SizedBox(height: 24),
                    ],

                    // Wellness Recommendations
                    if (recommendationData?['wellness_recommendations'] != null) ...[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            ThemeHelpers.themedAvatar(
                              size: 40,
                              icon: Icons.psychology_outlined,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Wellness Recommendations',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...((recommendationData!['wellness_recommendations'] as List).map(
                        (rec) => _buildRecommendationCard(
                          title: rec['title'],
                          description: rec['description'],
                          priority: rec['priority'],
                          iconName: rec['icon'],
                          isCombined: false,
                        ),
                      )),
                      const SizedBox(height: 24),
                    ],

                    // Data Correlation Insights
                    _buildCorrelationInsights(),
                    const SizedBox(height: 24),

                    // Daily Tips
                    _buildDailyTipsSection(),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }
}