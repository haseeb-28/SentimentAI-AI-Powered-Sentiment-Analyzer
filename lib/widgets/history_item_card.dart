import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../models/analysis_history.dart';

class HistoryItemCard extends StatelessWidget {
  final AnalysisHistory history;
  final VoidCallback onDelete;
  final VoidCallback onAnalyzeAgain;

  const HistoryItemCard({
    super.key,
    required this.history,
    required this.onDelete,
    required this.onAnalyzeAgain,
  });

  Color _sentimentColor(String prediction) {
    return prediction.toLowerCase() == 'positive'
        ? const Color(AppConstants.successColor)
        : const Color(AppConstants.errorColor);
  }

  IconData _sentimentIcon(String prediction) {
    return prediction.toLowerCase() == 'positive'
        ? Icons.sentiment_very_satisfied_rounded
        : Icons.sentiment_very_dissatisfied_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final lrColor = _sentimentColor(history.lrPrediction);
    final nbColor = _sentimentColor(history.nbPrediction);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
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
          // Header
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        history.shortText,
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: Colors.grey[600],
                      onPressed: onDelete,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  history.formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // Predictions
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Logistic Regression
                Expanded(
                  child: _buildPredictionCard(
                    'Logistic Regression',
                    history.lrPrediction,
                    history.lrConfidence,
                    lrColor,
                    _sentimentIcon(history.lrPrediction),
                  ),
                ),
                const SizedBox(width: 12),
                // Naive Bayes
                Expanded(
                  child: _buildPredictionCard(
                    'Naive Bayes',
                    history.nbPrediction,
                    history.nbConfidence,
                    nbColor,
                    _sentimentIcon(history.nbPrediction),
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAnalyzeAgain,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Analyze Again'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(
    String modelName,
    String prediction,
    double confidence,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            modelName,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              prediction.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(confidence * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}



