import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../models/sentiment_response.dart';

class ModelComparisonCard extends StatefulWidget {
  final String modelName;
  final ModelResult result;
  final int index;

  const ModelComparisonCard({
    super.key,
    required this.modelName,
    required this.result,
    this.index = 0,
  });

  @override
  State<ModelComparisonCard> createState() => _ModelComparisonCardState();
}

class _ModelComparisonCardState extends State<ModelComparisonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.longAnimation,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Staggered animation based on index
    Future.delayed(Duration(milliseconds: widget.index * 150), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _sentimentColor(String prediction) {
    switch (prediction.toLowerCase()) {
      case 'positive':
        return const Color(AppConstants.successColor);
      case 'negative':
        return const Color(AppConstants.errorColor);
      default:
        return const Color(AppConstants.warningColor);
    }
  }

  IconData _sentimentIcon(String prediction) {
    switch (prediction.toLowerCase()) {
      case 'positive':
        return Icons.sentiment_very_satisfied_rounded;
      case 'negative':
        return Icons.sentiment_very_dissatisfied_rounded;
      default:
        return Icons.sentiment_neutral_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sentimentColor = _sentimentColor(widget.result.prediction);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: sentimentColor.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: sentimentColor.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with animated gradient
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: AppConstants.mediumAnimation,
                  builder: (context, value, child) {
                    return Container(
                      padding: EdgeInsets.all(isMobile ? 16 : 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            sentimentColor.withValues(alpha: 0.15 * value),
                            sentimentColor.withValues(alpha: 0.08 * value),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // Animated icon
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: AppConstants.longAnimation,
                            curve: Curves.elasticOut,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: sentimentColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _sentimentIcon(widget.result.prediction),
                                    color: sentimentColor,
                                    size: isMobile ? 28 : 32,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: isMobile ? 16 : 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.modelName,
                                  style: TextStyle(
                                    fontSize: isMobile ? 18 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Animated sentiment badge
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: AppConstants.mediumAnimation,
                                  curve: Curves.elasticOut,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: sentimentColor,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: sentimentColor.withValues(alpha: 0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          widget.result.prediction.toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: isMobile ? 12 : 13,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: isMobile ? 20 : 24),
                // Confidence Section with animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: widget.result.probability),
                  duration: AppConstants.longAnimation,
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedValue, child) {
                    return Container(
                      padding: EdgeInsets.all(isMobile ? 16 : 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              sentimentColor.withValues(alpha: 0.1),
                              sentimentColor.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: sentimentColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.trending_up_rounded,
                                  color: sentimentColor,
                                  size: isMobile ? 22 : 24,
                                ),
                              ),
                              SizedBox(width: isMobile ? 12 : 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Confidence Level',
                                      style: TextStyle(
                                        fontSize: isMobile ? 13 : 14,
                                        color: const Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Animated progress bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: animatedValue,
                                        minHeight: isMobile ? 8 : 10,
                                        backgroundColor: sentimentColor.withValues(alpha: 0.1),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          sentimentColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: isMobile ? 12 : 16),
                              // Animated percentage
                              TweenAnimationBuilder<double>(
                                tween: Tween(
                                  begin: 0.0,
                                  end: widget.result.probability * 100,
                                ),
                                duration: AppConstants.longAnimation,
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: sentimentColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${value.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: isMobile ? 18 : 20,
                                        fontWeight: FontWeight.bold,
                                        color: sentimentColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
