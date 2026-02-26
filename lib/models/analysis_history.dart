import 'package:intl/intl.dart';

class AnalysisHistory {
  final String id;
  final String text;
  final String lrPrediction;
  final String nbPrediction;
  final double lrConfidence;
  final double nbConfidence;
  final DateTime timestamp;

  AnalysisHistory({
    required this.id,
    required this.text,
    required this.lrPrediction,
    required this.nbPrediction,
    required this.lrConfidence,
    required this.nbConfidence,
    required this.timestamp,
  });

  String get formattedDate {
    return DateFormat('MMM dd, yyyy • HH:mm').format(timestamp);
  }

  String get shortText {
    if (text.length <= 50) return text;
    return '${text.substring(0, 50)}...';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'lr_prediction': lrPrediction,
      'nb_prediction': nbPrediction,
      'lr_confidence': lrConfidence,
      'nb_confidence': nbConfidence,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AnalysisHistory.fromJson(Map<String, dynamic> json) {
    return AnalysisHistory(
      id: json['id'] as String,
      text: json['text'] as String,
      lrPrediction: json['lr_prediction'] as String,
      nbPrediction: json['nb_prediction'] as String,
      lrConfidence: (json['lr_confidence'] as num).toDouble(),
      nbConfidence: (json['nb_confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}



