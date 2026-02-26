import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../widgets/stat_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StorageService _storageService = StorageService();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    final history = await _storageService.getHistory();
    
    int totalAnalyses = history.length;
    int positiveLr = 0, negativeLr = 0;
    int positiveNb = 0, negativeNb = 0;
    double avgConfidenceLr = 0, avgConfidenceNb = 0;
    
    for (var item in history) {
      if (item.lrPrediction.toLowerCase() == 'positive') {
        positiveLr++;
      } else {
        negativeLr++;
      }
      
      if (item.nbPrediction.toLowerCase() == 'positive') {
        positiveNb++;
      } else {
        negativeNb++;
      }
      
      avgConfidenceLr += item.lrConfidence;
      avgConfidenceNb += item.nbConfidence;
    }
    
    if (totalAnalyses > 0) {
      avgConfidenceLr /= totalAnalyses;
      avgConfidenceNb /= totalAnalyses;
    }
    
    setState(() {
      _stats = {
        'total': totalAnalyses,
        'positive_lr': positiveLr,
        'negative_lr': negativeLr,
        'positive_nb': positiveNb,
        'negative_nb': negativeNb,
        'avg_confidence_lr': avgConfidenceLr,
        'avg_confidence_nb': avgConfidenceNb,
        'agreement': history.where((item) => 
          item.lrPrediction.toLowerCase() == item.nbPrediction.toLowerCase()
        ).length,
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_stats['total'] == 0)
                      _buildEmptyState(isMobile)
                    else
                      Column(
                        children: [
                          // Total Analyses
                          StatCard(
                            title: 'Total Analyses',
                            value: '${_stats['total']}',
                            icon: Icons.analytics_outlined,
                            color: const Color(AppConstants.primaryColor),
                          ),
                          const SizedBox(height: 16),
                          // Model Agreement
                          StatCard(
                            title: 'Model Agreement',
                            value: '${_stats['agreement']}/${_stats['total']}',
                            subtitle: '${((_stats['agreement'] / _stats['total']) * 100).toStringAsFixed(1)}%',
                            icon: Icons.handshake_rounded,
                            color: const Color(AppConstants.successColor),
                          ),
                          const SizedBox(height: 16),
                          // Logistic Regression Stats
                          _buildModelStats(
                            'Logistic Regression',
                            _stats['positive_lr'],
                            _stats['negative_lr'],
                            _stats['avg_confidence_lr'],
                            const Color(AppConstants.primaryColor),
                            isMobile,
                          ),
                          const SizedBox(height: 16),
                          // Naive Bayes Stats
                          _buildModelStats(
                            'Naive Bayes',
                            _stats['positive_nb'],
                            _stats['negative_nb'],
                            _stats['avg_confidence_nb'],
                            const Color(AppConstants.secondaryColor),
                            isMobile,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildModelStats(
    String modelName,
    int positive,
    int negative,
    double avgConfidence,
    Color color,
    bool isMobile,
  ) {
    final total = positive + negative;
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.psychology_rounded, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                modelName,
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Positive',
                  '$positive',
                  '${total > 0 ? (positive / total * 100).toStringAsFixed(1) : 0}%',
                  const Color(AppConstants.successColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Negative',
                  '$negative',
                  '${total > 0 ? (negative / total * 100).toStringAsFixed(1) : 0}%',
                  const Color(AppConstants.errorColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up_rounded, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Avg Confidence: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${(avgConfidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 32 : 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: isMobile ? 64 : 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Statistics Yet',
              style: TextStyle(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Analyze some reviews to see statistics',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}



