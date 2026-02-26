class ModelMetrics {
  final double accuracy;
  final double precision;
  final double recall;
  final double f1Score;

  ModelMetrics({
    required this.accuracy,
    required this.precision,
    required this.recall,
    required this.f1Score,
  });

  factory ModelMetrics.fromJson(Map<String, dynamic> json) {
    return ModelMetrics(
      accuracy: (json['accuracy'] as num).toDouble(),
      precision: (json['precision'] as num).toDouble(),
      recall: (json['recall'] as num).toDouble(),
      f1Score: (json['f1_score'] as num).toDouble(),
    );
  }
}

class ModelResult {
  final String prediction;
  final double probability;
  final ModelMetrics metrics;

  ModelResult({
    required this.prediction,
    required this.probability,
    required this.metrics,
  });

  factory ModelResult.fromJson(Map<String, dynamic> json) {
    return ModelResult(
      prediction: json['prediction'] as String,
      probability: (json['probability'] as num).toDouble(),
      metrics: ModelMetrics.fromJson(json['metrics']),
    );
  }
}

class SentimentResponse {
  final String inputText;
  final ModelResult logisticRegression;
  final ModelResult naiveBayes;

  SentimentResponse({
    required this.inputText,
    required this.logisticRegression,
    required this.naiveBayes,
  });

  factory SentimentResponse.fromJson(Map<String, dynamic> json) {
    final models = json['models'] as Map<String, dynamic>;
    return SentimentResponse(
      inputText: json['input_text'] as String,
      logisticRegression:
          ModelResult.fromJson(models['logistic_regression']),
      naiveBayes: ModelResult.fromJson(models['naive_bayes']),
    );
  }
}

