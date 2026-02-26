# SentimentAI: AI Powered Sentiment Analyzer

A Flutter mobile application for sentiment analysis using Logistic Regression and Naive Bayes models trained on the IMDB dataset.

## Features

- 📝 Text input for movie reviews
- 🤖 Dual model prediction (Logistic Regression & Naive Bayes)
- 📊 Side-by-side comparison of model predictions
- 📈 Display of performance metrics (Accuracy, Precision, Recall, F1 Score)
- ⚡ Real-time sentiment analysis via REST API
- 🎨 Modern Material Design 3 UI

## Project Structure

```
lib/
├── main.dart                    # App entry point with Provider setup
├── models/
│   └── sentiment_response.dart # Data models for API responses
├── services/
│   └── api_service.dart        # HTTP client for backend communication
├── state/
│   └── sentiment_provider.dart # State management with Provider
├── screens/
│   └── home_screen.dart        # Main UI screen
└── widgets/
    └── model_comparison_card.dart # Reusable card widget for model results
```

## Setup Instructions

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android emulator or physical device / iOS simulator

### Installation

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Configure backend URL:**
   
   Edit `lib/services/api_service.dart` and update the `_baseUrl` constant:
   
   ```dart
   // For local development (Android emulator):
   static const String _baseUrl = 'http://10.0.2.2:8000';
   
   // For iOS simulator:
   static const String _baseUrl = 'http://localhost:8000';
   
   // For physical device (replace with your computer's IP):
   static const String _baseUrl = 'http://192.168.1.XXX:8000';
   
   // For production:
   static const String _baseUrl = 'https://your-backend-domain.com';
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## API Contract

The app expects the backend to provide the following API:

### Endpoint
`POST /api/predict`

### Request Body
```json
{
  "text": "This movie was absolutely amazing!"
}
```

### Response Format
```json
{
  "input_text": "This movie was absolutely amazing!",
  "models": {
    "logistic_regression": {
      "prediction": "positive",
      "probability": 0.93,
      "metrics": {
        "accuracy": 0.89,
        "precision": 0.90,
        "recall": 0.88,
        "f1_score": 0.89
      }
    },
    "naive_bayes": {
      "prediction": "positive",
      "probability": 0.87,
      "metrics": {
        "accuracy": 0.85,
        "precision": 0.86,
        "recall": 0.84,
        "f1_score": 0.85
      }
    }
  }
}
```

### HTTP Status Codes
- `200` - Success
- `400` - Invalid input
- `401/403` - Authentication error
- `500` - Server error

## Dependencies

- `flutter` - Flutter SDK
- `http: ^1.2.0` - HTTP client for API calls
- `provider: ^6.1.1` - State management

## Testing

### Manual Testing Steps

1. **Start the app** on an emulator or physical device
2. **Enter sample text** in the input field:
   - Positive: "This movie was absolutely amazing! Great acting and plot."
   - Negative: "Terrible movie. Waste of time and money."
3. **Click "Analyze Sentiment"** button
4. **Verify**:
   - Loading indicator appears during API call
   - Results display side-by-side for both models
   - Metrics are shown correctly
   - Error messages appear if backend is unavailable

### Mock Testing (Without Backend)

To test the UI without a backend, you can temporarily modify `api_service.dart` to return mock data:

```dart
Future<SentimentResponse> predictSentiment(String text) async {
  // Mock response for testing
  await Future.delayed(const Duration(seconds: 1));
  return SentimentResponse.fromJson({
    "input_text": text,
    "models": {
      "logistic_regression": {
        "prediction": "positive",
        "probability": 0.93,
        "metrics": {
          "accuracy": 0.89,
          "precision": 0.90,
          "recall": 0.88,
          "f1_score": 0.89
        }
      },
      "naive_bayes": {
        "prediction": "positive",
        "probability": 0.87,
        "metrics": {
          "accuracy": 0.85,
          "precision": 0.86,
          "recall": 0.84,
          "f1_score": 0.85
        }
      }
    }
  });
}
```

## Error Handling

The app handles:
- ✅ Network timeouts (15 seconds)
- ✅ Invalid input validation
- ✅ HTTP error status codes
- ✅ JSON parsing errors
- ✅ Connection failures

## Next Steps

1. **Backend Integration**: Connect to your ML backend API
2. **Authentication**: Add token-based auth if required
3. **Caching**: Cache recent predictions locally
4. **History**: Save prediction history
5. **Export**: Export results as PDF/CSV

## License

This project is part of a data mining course assignment.

