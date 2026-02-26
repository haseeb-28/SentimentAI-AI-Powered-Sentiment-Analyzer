import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/analysis_history.dart';
import '../models/sentiment_response.dart';
import '../models/movie_response.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class SentimentProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService = StorageService();
  final _uuid = const Uuid();

  SentimentProvider(this._apiService);

  bool _isLoading = false;
  String? _errorMessage;
  SentimentResponse? _result;
  MovieResponse? _movieResult;
  bool _isMovieSearch = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SentimentResponse? get result => _result;
  MovieResponse? get movieResult => _movieResult;
  bool get isMovieSearch => _isMovieSearch;

  Future<void> searchMovie(String movieName) async {
    if (movieName.trim().isEmpty) {
      _errorMessage = 'Please enter a movie name.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _result = null;
    _movieResult = null;
    _isMovieSearch = true;
    notifyListeners();

    try {
      final response = await _apiService.searchMovie(movieName);
      _movieResult = response;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _movieResult = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> analyzeText(String text) async {
    if (text.trim().isEmpty) {
      _errorMessage = 'Please enter some text.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _isMovieSearch = false;
    notifyListeners();

    try {
      final response = await _apiService.predictSentiment(text);
      _result = response;
      
      // Save to history
      final history = AnalysisHistory(
        id: _uuid.v4(),
        text: text,
        lrPrediction: response.logisticRegression.prediction,
        nbPrediction: response.naiveBayes.prediction,
        lrConfidence: response.logisticRegression.probability,
        nbConfidence: response.naiveBayes.probability,
        timestamp: DateTime.now(),
      );
      await _storageService.saveAnalysis(history);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _result = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _result = null;
    _movieResult = null;
    _errorMessage = null;
    _isMovieSearch = false;
    notifyListeners();
  }
}

