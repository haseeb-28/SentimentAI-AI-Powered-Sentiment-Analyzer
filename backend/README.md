# IMDB Sentiment Analysis Backend API

Flask backend server for sentiment analysis using Logistic Regression and Naive Bayes models.

## Quick Start

### Windows:
```bash
start_server.bat
```

### Mac/Linux:
```bash
python app.py
```

## Setup Instructions

### 1. Install Python Dependencies

```bash
pip install -r requirements.txt
```

Or use a virtual environment (recommended):
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Download IMDB Dataset

Download the IMDB Dataset CSV file and place it in the `data/` folder:

- **Download from**: [Kaggle IMDB Dataset](https://www.kaggle.com/datasets/lakshmi25npathi/imdb-dataset-of-50k-movie-reviews)
- **File location**: `data/IMDB Dataset.csv`

Create the data folder:
```bash
mkdir data
# Copy IMDB Dataset.csv to data/IMDB Dataset.csv
```

### 3. Train Models (First Time Setup)

If you don't have saved model files, train them:

```bash
python train_models.py
```

This will:
- Load the IMDB dataset
- Train both Logistic Regression and Naive Bayes models
- Save models to `models/` folder
- Display evaluation metrics

**Expected output:**
- Logistic Regression: ~90% accuracy
- Naive Bayes: ~86% accuracy

### 4. Start the Server

```bash
python app.py
```

The server will start on `http://localhost:8000`

**Verify it's running:** Open `http://localhost:8000/api/health` in your browser

## API Endpoints

### POST `/api/predict`

Predict sentiment for a given text.

**Request:**
```json
{
  "text": "This movie was absolutely amazing!"
}
```

**Response:**
```json
{
  "input_text": "This movie was absolutely amazing!",
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

### GET `/api/health`

Check if the server and models are loaded.

**Response:**
```json
{
  "status": "healthy",
  "models_loaded": true
}
```

### GET `/`

API information endpoint.

## Project Structure

```
backend/
├── app.py              # Flask server
├── train_models.py     # Model training script
├── requirements.txt    # Python dependencies
├── start_server.bat    # Windows startup script
├── README.md          # This file
├── data/              # Dataset folder (create this)
│   └── IMDB Dataset.csv
└── models/            # Saved models (created after training)
    ├── logreg_model.pkl
    ├── naive_bayes_model.pkl
    ├── vectorizer.pkl
    └── tfidf.pkl
```

## Connecting to Flutter App

The Flutter app is configured to connect to `http://localhost:8000` by default.

**For Android Emulator:**
- Change `_baseUrl` in `lib/services/api_service.dart` to `http://10.0.2.2:8000`

**For iOS Simulator:**
- Keep `_baseUrl` as `http://localhost:8000`

**For Physical Device:**
- Change `_baseUrl` to `http://YOUR_COMPUTER_IP:8000`
- Find your IP:
  - Windows: `ipconfig` → IPv4 Address
  - Mac/Linux: `ifconfig` or `ip addr`

## Troubleshooting

### Models not loading
- **Solution**: Run `python train_models.py` first
- Ensure dataset exists at `data/IMDB Dataset.csv`

### Dataset not found
- **Error**: `Dataset not found at data/IMDB Dataset.csv`
- **Solution**: Download from Kaggle and place in `data/` folder

### Port already in use
- **Error**: `Address already in use`
- **Solution**: 
  1. Change port in `app.py`: `app.run(port=8001)` 
  2. Update Flutter app's `_baseUrl` accordingly

### CORS errors
- **Solution**: Flask-CORS is already configured, should work automatically
- If issues persist, check `CORS(app)` is in `app.py`

### Module not found errors
- **Solution**: Install dependencies: `pip install -r requirements.txt`

## Development Notes

- Models are trained on the IMDB dataset (50k reviews)
- Text preprocessing matches the training pipeline from the notebook
- Models are saved after training for faster startup
- Server runs in debug mode by default (change for production)
- Training takes ~2-5 minutes depending on your machine

## Production Deployment

For production:
1. Set `debug=False` in `app.py`
2. Use a production WSGI server (e.g., Gunicorn)
3. Configure proper CORS origins
4. Add authentication if needed
5. Use environment variables for configuration
