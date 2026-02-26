class MovieResponse {
  final String movieName;
  final int reviewsAnalyzed;
  final OverallSentiment overallSentiment;
  final List<SampleReview> sampleReviews;

  MovieResponse({
    required this.movieName,
    required this.reviewsAnalyzed,
    required this.overallSentiment,
    required this.sampleReviews,
  });

  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    return MovieResponse(
      movieName: json['movie_name'] as String,
      reviewsAnalyzed: json['reviews_analyzed'] as int,
      overallSentiment: OverallSentiment.fromJson(
        json['overall_sentiment'] as Map<String, dynamic>,
      ),
      sampleReviews: (json['sample_reviews'] as List)
          .map((e) => SampleReview.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OverallSentiment {
  final ModelPrediction logisticRegression;
  final ModelPrediction naiveBayes;

  OverallSentiment({
    required this.logisticRegression,
    required this.naiveBayes,
  });

  factory OverallSentiment.fromJson(Map<String, dynamic> json) {
    return OverallSentiment(
      logisticRegression: ModelPrediction.fromJson(
        json['logistic_regression'] as Map<String, dynamic>,
      ),
      naiveBayes: ModelPrediction.fromJson(
        json['naive_bayes'] as Map<String, dynamic>,
      ),
    );
  }
}

class ModelPrediction {
  final String prediction; // 'good_to_watch' or 'not_recommended'
  final int positiveReviews;
  final int negativeReviews;
  final double averageConfidence;
  final Map<String, dynamic> metrics;

  ModelPrediction({
    required this.prediction,
    required this.positiveReviews,
    required this.negativeReviews,
    required this.averageConfidence,
    required this.metrics,
  });

  factory ModelPrediction.fromJson(Map<String, dynamic> json) {
    return ModelPrediction(
      prediction: json['prediction'] as String,
      positiveReviews: json['positive_reviews'] as int,
      negativeReviews: json['negative_reviews'] as int,
      averageConfidence: (json['average_confidence'] as num).toDouble(),
      metrics: json['metrics'] as Map<String, dynamic>,
    );
  }
}

class SampleReview {
  final String review;
  final String lrSentiment;
  final double lrProb;
  final String nbSentiment;
  final double nbProb;

  SampleReview({
    required this.review,
    required this.lrSentiment,
    required this.lrProb,
    required this.nbSentiment,
    required this.nbProb,
  });

  factory SampleReview.fromJson(Map<String, dynamic> json) {
    return SampleReview(
      review: json['review'] as String,
      lrSentiment: json['lr_sentiment'] as String,
      lrProb: (json['lr_prob'] as num).toDouble(),
      nbSentiment: json['nb_sentiment'] as String,
      nbProb: (json['nb_prob'] as num).toDouble(),
    );
  }
}
