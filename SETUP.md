# Complete Setup Guide

## Backend Setup (Python/Flask)

### Step 1: Install Python Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### Step 2: Prepare Dataset

1. Download the IMDB Dataset CSV file from [Kaggle](https://www.kaggle.com/datasets/lakshmi25npathi/imdb-dataset-of-50k-movie-reviews)
2. Create a `data` folder in the `backend` directory:
   ```bash
   mkdir backend\data
   ```
3. Place the CSV file as `backend\data\IMDB Dataset.csv`

### Step 3: Train Models

```bash
cd backend
python train_models.py
```

This will train both models and save them to `backend\models\` folder.

### Step 4: Start Backend Server

```bash
cd backend
python app.py
```

The server will start on `http://localhost:8000`

**Verify it's running:** Open `http://localhost:8000/api/health` in your browser

---

## Flutter App Setup

### Step 1: Install Flutter Dependencies

```bash
flutter pub get
```

### Step 2: Configure Backend URL

Edit `lib/services/api_service.dart` and update the `_baseUrl`:

**For Android Emulator:**
```dart
static const String _baseUrl = 'http://10.0.2.2:8000';
```

**For iOS Simulator:**
```dart
static const String _baseUrl = 'http://localhost:8000';
```

**For Physical Device:**
1. Find your computer's IP address:
   - Windows: Run `ipconfig` in PowerShell, look for IPv4 Address
   - Mac/Linux: Run `ifconfig` or `ip addr`
2. Update the URL:
```dart
static const String _baseUrl = 'http://192.168.1.XXX:8000';  // Replace XXX with your IP
```

### Step 3: Run the Flutter App

```bash
flutter run
```

---

## Quick Start (Both Services)

### Terminal 1 - Backend:
```bash
cd backend
python app.py
```

### Terminal 2 - Flutter:
```bash
flutter run
```

---

## Testing

1. **Test Backend:** Open `http://localhost:8000/api/health` - should return `{"status": "healthy"}`
2. **Test Flutter App:** Enter a movie review and click "Analyze Sentiment"
3. **Sample Reviews:**
   - Positive: "This movie was absolutely amazing! Great acting and plot."
   - Negative: "Terrible movie. Waste of time and money."

---

## Troubleshooting

### Backend Issues:
- **Models not found**: Run `python backend/train_models.py` first
- **Dataset not found**: Ensure `backend/data/IMDB Dataset.csv` exists
- **Port 8000 in use**: Change port in `backend/app.py` (line with `app.run(port=8000)`)

### Flutter Issues:
- **Connection refused**: Make sure backend is running on port 8000
- **CORS errors**: Flask-CORS is configured, should work automatically
- **Android emulator can't connect**: Use `http://10.0.2.2:8000` instead of `localhost`

---

## Project Structure

```
sentiment_app/
├── backend/              # Python Flask backend
│   ├── app.py           # Flask server
│   ├── train_models.py  # Model training script
│   ├── requirements.txt # Python dependencies
│   ├── data/            # Dataset folder (create this)
│   │   └── IMDB Dataset.csv
│   └── models/          # Saved models (created after training)
│       ├── logreg_model.pkl
│       ├── naive_bayes_model.pkl
│       ├── vectorizer.pkl
│       └── tfidf.pkl
├── lib/                 # Flutter app code
│   ├── main.dart
│   ├── screens/
│   ├── services/
│   └── ...
└── pubspec.yaml         # Flutter dependencies
```

---

## Next Steps

1. ✅ Backend API created and ready
2. ✅ Flutter frontend ready
3. ✅ Integration complete
4. 🚀 Ready to use!

