# Backend-Frontend Integration Complete ✅

## Overview

Your sentiment analysis application is now fully integrated! The Flutter frontend connects to a Flask backend that uses the ML models from your Jupyter notebook.

## Architecture

```
┌─────────────────┐         HTTP POST          ┌──────────────────┐
│                 │    /api/predict            │                  │
│  Flutter App    │ ──────────────────────────> │  Flask Backend   │
│  (Frontend)     │                             │  (Python)        │
│                 │ <────────────────────────── │                  │
│                 │    JSON Response            │                  │
└─────────────────┘                             └──────────────────┘
                                                         │
                                                         │ Uses
                                                         ▼
                                                ┌──────────────────┐
                                                │  ML Models       │
                                                │  - Logistic Reg  │
                                                │  - Naive Bayes   │
                                                └──────────────────┘
```

## What Was Created

### Backend Files:
1. **`backend/app.py`** - Flask server with `/api/predict` endpoint
2. **`backend/train_models.py`** - Script to train and save models
3. **`backend/requirements.txt`** - Python dependencies
4. **`backend/start_server.bat`** - Windows startup script
5. **`backend/README.md`** - Backend documentation

### Updated Files:
1. **`SETUP.md`** - Complete setup guide for both backend and frontend

## How It Works

### 1. Backend Flow:
```
User Text → Flask API → Preprocess → Vectorize → 
Predict (LR + NB) → Format Response → Return JSON
```

### 2. Frontend Flow:
```
User Input → SentimentProvider → ApiService → 
HTTP POST → Parse Response → Update UI
```

### 3. Data Flow:
```
Flutter App sends: {"text": "movie review"}
                    ↓
Backend processes with both models
                    ↓
Backend returns: {
  "input_text": "...",
  "models": {
    "logistic_regression": {...},
    "naive_bayes": {...}
  }
}
                    ↓
Flutter displays side-by-side comparison
```

## Quick Start

### Terminal 1 - Start Backend:
```bash
cd backend
python app.py
```

### Terminal 2 - Start Flutter:
```bash
flutter run
```

## API Contract

The backend implements the exact API contract expected by the Flutter app:

**Endpoint:** `POST /api/predict`

**Request:**
```json
{"text": "This movie was great!"}
```

**Response:**
```json
{
  "input_text": "This movie was great!",
  "models": {
    "logistic_regression": {
      "prediction": "positive",
      "probability": 0.93,
      "metrics": {
        "accuracy": 0.90,
        "precision": 0.90,
        "recall": 0.90,
        "f1_score": 0.90
      }
    },
    "naive_bayes": {
      "prediction": "positive",
      "probability": 0.87,
      "metrics": {
        "accuracy": 0.86,
        "precision": 0.86,
        "recall": 0.86,
        "f1_score": 0.86
      }
    }
  }
}
```

## Features

✅ **Dual Model Comparison** - Both Logistic Regression and Naive Bayes predictions  
✅ **Real-time Analysis** - Instant sentiment prediction  
✅ **Performance Metrics** - Shows accuracy, precision, recall, F1 score  
✅ **Error Handling** - Graceful error messages  
✅ **CORS Enabled** - Works with Flutter app  
✅ **Model Persistence** - Models saved after training for fast startup  

## Testing

1. **Test Backend:**
   ```bash
   curl http://localhost:8000/api/health
   ```

2. **Test Prediction:**
   ```bash
   curl -X POST http://localhost:8000/api/predict \
     -H "Content-Type: application/json" \
     -d '{"text": "This movie was amazing!"}'
   ```

3. **Test Flutter App:**
   - Enter a review in the app
   - Click "Analyze Sentiment"
   - See both model predictions side-by-side

## Configuration

### Backend URL Configuration:

The Flutter app's API URL is set in `lib/services/api_service.dart`:

- **Default:** `http://localhost:8000` (iOS Simulator)
- **Android Emulator:** Change to `http://10.0.2.2:8000`
- **Physical Device:** Change to `http://YOUR_IP:8000`

## Next Steps

1. ✅ Backend created
2. ✅ Frontend connected
3. ✅ Integration complete
4. 🚀 **Ready to use!**

## Troubleshooting

See `SETUP.md` for detailed troubleshooting steps.

Common issues:
- Backend not running → Start with `python backend/app.py`
- Models not found → Run `python backend/train_models.py`
- Connection refused → Check URL in `api_service.dart`
- CORS errors → Already handled by Flask-CORS

## Files Reference

- **Backend Server:** `backend/app.py`
- **Model Training:** `backend/train_models.py`
- **Flutter API Service:** `lib/services/api_service.dart`
- **State Management:** `lib/state/sentiment_provider.dart`
- **UI Screen:** `lib/screens/home_screen.dart`

---

**Status:** ✅ Fully Integrated and Ready to Use!



