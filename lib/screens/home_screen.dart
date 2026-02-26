import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../models/movie_response.dart';
import '../state/sentiment_provider.dart';
import '../widgets/model_comparison_card.dart';
import 'history_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  int _currentIndex = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: AppConstants.longAnimation,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    // Slide animation
    _slideController = AnimationController(
      vsync: this,
      duration: AppConstants.longAnimation,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // Scale animation
    _scaleController = AnimationController(
      vsync: this,
      duration: AppConstants.mediumAnimation,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    
    _fadeController.forward();
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onAnalyzePressed(BuildContext context) {
    final provider = context.read<SentimentProvider>();
    provider.analyzeText(_controller.text);
    FocusScope.of(context).unfocus();
    // Reset and replay scale animation
    _scaleController.reset();
    _scaleController.forward();
  }

  void _copyResults() {
    final provider = context.read<SentimentProvider>();
    if (provider.result != null) {
      final result = provider.result!;
      final text = '''
    Logistic Regression: ${result.logisticRegression.prediction} (${(result.logisticRegression.probability * 100).toStringAsFixed(1)}%)
    Naive Bayes: ${result.naiveBayes.prediction} (${(result.naiveBayes.probability * 100).toStringAsFixed(1)}%)
    ''';
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Results copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareResults() {
    final provider = context.read<SentimentProvider>();
    if (provider.result != null) {
      final result = provider.result!;
      final text = '''
    ${AppConstants.appName} - Sentiment Analysis

    Results:
    • Logistic Regression: ${result.logisticRegression.prediction} (${(result.logisticRegression.probability * 100).toStringAsFixed(1)}%)
    • Naive Bayes: ${result.naiveBayes.prediction} (${(result.naiveBayes.probability * 100).toStringAsFixed(1)}%)
    ''';
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Results copied to clipboard (ready to share)'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const HistoryScreen();
      case 2:
        return const StatisticsScreen();
      case 3:
        return const SettingsScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    final provider = context.watch<SentimentProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(AppConstants.primaryColor).withOpacity(0.08),
              const Color(AppConstants.secondaryColor).withOpacity(0.08),
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Animated AppBar
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildAppBar(isMobile),
                ),
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 24,
                        vertical: 16,
                      ),
                      child: Column(
                        children: [
                          // Input Field with animation
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: _buildInputField(provider, isMobile),
                          ),
                          SizedBox(height: isMobile ? 16 : 20),
                          // Analyze Button with animation
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: _buildAnalyzeButton(provider, isMobile),
                          ),
                          const SizedBox(height: 12),
                          // Error Message
                          AnimatedSize(
                            duration: AppConstants.shortAnimation,
                            curve: Curves.easeInOut,
                            child: provider.errorMessage != null
                                ? _buildErrorMessage(provider.errorMessage!)
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 12),
                          // Results Section
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: AppConstants.mediumAnimation,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.1),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: provider.result == null
                                  ? _buildEmptyState(isMobile)
                                  : _buildResultsSection(context, provider, isMobile),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildAppBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(AppConstants.primaryColor).withOpacity(0.12),
            const Color(AppConstants.secondaryColor).withOpacity(0.12),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(AppConstants.primaryColor),
                  Color(AppConstants.secondaryColor),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(AppConstants.primaryColor).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.sentiment_satisfied_alt,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(AppConstants.primaryColor),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.appTagline,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(SentimentProvider provider, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        maxLines: 1,
        style: TextStyle(fontSize: isMobile ? 15 : 16),
        decoration: InputDecoration(
          labelText: 'Enter a movie review',
          hintText: 'Write your review text here...',
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(AppConstants.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.movie_filter_rounded,
              color: Color(AppConstants.primaryColor),
            ),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _controller.clear();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: isMobile ? 16 : 20,
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildAnalyzeButton(SentimentProvider provider, bool isMobile) {
    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      width: double.infinity,
      height: isMobile ? 56 : 60,
      decoration: BoxDecoration(
        gradient: provider.isLoading
            ? null
            : const LinearGradient(
                colors: [
                  Color(AppConstants.primaryColor),
                  Color(AppConstants.secondaryColor),
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: provider.isLoading
            ? null
            : [
                BoxShadow(
                  color: const Color(AppConstants.primaryColor).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: provider.isLoading ? null : () => _onAnalyzePressed(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (provider.isLoading)
                  const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                else
                  const Icon(
                    Icons.analytics_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                const SizedBox(width: 12),
                Text(
                  provider.isLoading ? 'Analyzing...' : 'Analyze Sentiment',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppConstants.shortAnimation,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(AppConstants.errorColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(AppConstants.errorColor),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(AppConstants.errorColor).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: Color(AppConstants.errorColor),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Color(AppConstants.errorColor),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20 : 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: AppConstants.longAnimation,
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(AppConstants.primaryColor).withOpacity(0.15),
                            const Color(AppConstants.secondaryColor).withOpacity(0.15),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sentiment_neutral_outlined,
                        size: 64,
                        color: Color(AppConstants.primaryColor),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Ready to Analyze',
                style: TextStyle(
                  fontSize: isMobile ? 26 : 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter a movie review above and click\n"Analyze Sentiment" to compare models',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isMobile ? 14 : 16,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection(
      BuildContext context, SentimentProvider provider, bool isMobile) {
    if (provider.isMovieSearch && provider.movieResult != null) {
      return _buildMovieResults(context, provider, isMobile);
    } else if (!provider.isMovieSearch && provider.result != null) {
      return _buildSentimentResults(context, provider, isMobile);
    }
    return const SizedBox.shrink();
  }

  Widget _buildMovieResults(
      BuildContext context, SentimentProvider provider, bool isMobile) {
    final movieResult = provider.movieResult!;
    final lrPrediction = movieResult.overallSentiment.logisticRegression;
    final nbPrediction = movieResult.overallSentiment.naiveBayes;

    return SingleChildScrollView(
      key: const ValueKey('movie_results'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie Title and Recommendation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: AppConstants.mediumAnimation,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 16 : 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
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
                                color: const Color(AppConstants.primaryColor)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.movie_outlined,
                                color: Color(AppConstants.primaryColor),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movieResult.movieName,
                                    style: TextStyle(
                                      fontSize: isMobile ? 18 : 20,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${movieResult.reviewsAnalyzed} reviews analyzed',
                                    style: TextStyle(
                                      fontSize: isMobile ? 12 : 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
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
            },
          ),
          SizedBox(height: isMobile ? 16 : 20),
          // Recommendation Cards
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  _buildMovieRecommendationCard(
                    'Logistic Regression',
                    lrPrediction,
                    isMobile,
                    0,
                  ),
                  const SizedBox(height: 16),
                  _buildMovieRecommendationCard(
                    'Naive Bayes',
                    nbPrediction,
                    isMobile,
                    1,
                  ),
                ],
              );
            },
          ),
          SizedBox(height: isMobile ? 20 : 24),
          // Sample Reviews
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sample Reviews',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                ...movieResult.sampleReviews.asMap().entries.map((entry) {
                  final review = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.review,
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 14,
                              color: const Color(0xFF475569),
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Chip(
                                label: Text(
                                  review.lrSentiment,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor:
                                    review.lrSentiment == 'positive'
                                        ? Colors.green
                                        : Colors.red,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(review.lrProb * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieRecommendationCard(
    String modelName,
    ModelPrediction prediction,
    bool isMobile,
    int index,
  ) {
    final isGoodToWatch = prediction.prediction == 'good_to_watch';
    final backgroundColor = isGoodToWatch
        ? Colors.green.withOpacity(0.1)
        : Colors.red.withOpacity(0.1);
    final borderColor = isGoodToWatch ? Colors.green : Colors.red;
    final icon = isGoodToWatch ? Icons.thumb_up_rounded : Icons.thumb_down_rounded;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(
        milliseconds: AppConstants.mediumAnimation.inMilliseconds + (index * 100),
      ),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              modelName,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isGoodToWatch
                                  ? '👍 Good to Watch'
                                  : '👎 Not Recommended',
                              style: TextStyle(
                                fontSize: isMobile ? 13 : 14,
                                fontWeight: FontWeight.bold,
                                color: borderColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Positive',
                        prediction.positiveReviews.toString(),
                        Colors.green,
                        isMobile,
                      ),
                      _buildStatItem(
                        'Negative',
                        prediction.negativeReviews.toString(),
                        Colors.red,
                        isMobile,
                      ),
                      _buildStatItem(
                        'Confidence',
                        '${(prediction.averageConfidence * 100).toStringAsFixed(0)}%',
                        Colors.blue,
                        isMobile,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    bool isMobile,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSentimentResults(
      BuildContext context, SentimentProvider provider, bool isMobile) {
    return SingleChildScrollView(
      key: const ValueKey('results'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Your Review" display removed per user request.
          // Keep a small spacer to maintain layout spacing.
          SizedBox(height: isMobile ? 12 : 16),
          // Model Comparison Header with Actions
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: AppConstants.mediumAnimation,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(AppConstants.primaryColor),
                              Color(AppConstants.secondaryColor),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(AppConstants.primaryColor)
                                  .withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.compare_arrows_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Model Comparison',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                      ),
                      // Copy button
                      IconButton(
                        icon: const Icon(Icons.copy_rounded),
                        tooltip: 'Copy Results',
                        onPressed: _copyResults,
                      ),
                      // Share button
                      IconButton(
                        icon: const Icon(Icons.share_rounded),
                        tooltip: 'Share Results',
                        onPressed: _shareResults,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: isMobile ? 16 : 20),
          // Comparison Cards
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    ModelComparisonCard(
                      modelName: 'Logistic Regression',
                      result: provider.result!.logisticRegression,
                      index: 0,
                    ),
                    const SizedBox(height: 16),
                    ModelComparisonCard(
                      modelName: 'Naive Bayes',
                      result: provider.result!.naiveBayes,
                      index: 1,
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ModelComparisonCard(
                      modelName: 'Logistic Regression',
                      result: provider.result!.logisticRegression,
                      index: 0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ModelComparisonCard(
                      modelName: 'Naive Bayes',
                      result: provider.result!.naiveBayes,
                      index: 1,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Statistics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
