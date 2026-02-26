@echo off
echo ========================================
echo IMDB Sentiment Analysis Backend Server
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8+ and try again
    pause
    exit /b 1
)

REM Check if virtual environment exists, if not create one
if not exist "venv\" (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Install dependencies if needed
if not exist "venv\Lib\site-packages\flask" (
    echo Installing dependencies...
    pip install -r requirements.txt
)

REM Check if models exist
if not exist "models\logreg_model.pkl" (
    echo.
    echo WARNING: Models not found!
    echo Please run: python train_models.py
    echo.
    pause
)

REM Start server
echo.
echo Starting Flask server...
echo Server will be available at: http://localhost:8000
echo Press CTRL+C to stop
echo.
python app.py

pause



