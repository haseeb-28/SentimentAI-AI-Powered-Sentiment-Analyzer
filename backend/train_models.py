"""
Script to train and save sentiment analysis models
Based on the sentiment analysis.ipynb notebook
"""
import pandas as pd
import numpy as np
import re
import joblib
import os
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import CountVectorizer, TfidfTransformer
from sklearn.linear_model import LogisticRegression
from sklearn.naive_bayes import MultinomialNB
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
from sklearn.utils import shuffle


def clean_text(text):
    """Preprocess text"""
    text = re.sub(r'<br />', ' ', str(text))
    text = re.sub(r'\d+', '', text)
    text = re.sub(r'[^\w\s]', '', text)
    text = text.lower()
    return text


def train_and_save_models():
    """Train models and save them"""
    print("=" * 50)
    print("Training Sentiment Analysis Models")
    print("=" * 50)
    
    # Check if dataset exists
    dataset_path = 'data/IMDB Dataset.csv'
    if not os.path.exists(dataset_path):
        print(f"\n❌ Error: Dataset not found at {dataset_path}")
        print("\nPlease download the IMDB Dataset.csv file and place it in the data/ folder")
        print("Dataset available at: https://www.kaggle.com/datasets/lakshmi25npathi/imdb-dataset-of-50k-movie-reviews")
        return False
    
    print(f"\n✓ Loading dataset from {dataset_path}")
    df = pd.read_csv(dataset_path)
    df = shuffle(df, random_state=42)
    print(f"✓ Loaded {len(df)} reviews")
    
    # Preprocess
    print("\n✓ Preprocessing text...")
    df['review'] = df['review'].apply(clean_text)
    df['sentiment'] = df['sentiment'].apply(lambda x: 1 if x.lower() == 'positive' else 0)
    
    # Split data
    print("✓ Splitting data...")
    X_train, X_test, y_train, y_test = train_test_split(
        df['review'], df['sentiment'], test_size=0.2, random_state=42
    )
    print(f"  Training samples: {len(X_train)}")
    print(f"  Test samples: {len(X_test)}")
    
    # Vectorize
    print("\n✓ Vectorizing text...")
    vectorizer = CountVectorizer(stop_words='english')
    X_train_counts = vectorizer.fit_transform(X_train)
    X_test_counts = vectorizer.transform(X_test)
    
    tfidf_transformer = TfidfTransformer()
    X_train_tfidf = tfidf_transformer.fit_transform(X_train_counts)
    X_test_tfidf = tfidf_transformer.transform(X_test_counts)
    
    # Train Logistic Regression
    print("\n✓ Training Logistic Regression...")
    model_lr = LogisticRegression(max_iter=1000)
    model_lr.fit(X_train_tfidf, y_train)
    y_pred_lr = model_lr.predict(X_test_tfidf)
    
    acc_lr = accuracy_score(y_test, y_pred_lr)
    prec_lr = precision_score(y_test, y_pred_lr)
    rec_lr = recall_score(y_test, y_pred_lr)
    f1_lr = f1_score(y_test, y_pred_lr)
    
    print(f"  Accuracy: {acc_lr:.4f}")
    print(f"  Precision: {prec_lr:.4f}")
    print(f"  Recall: {rec_lr:.4f}")
    print(f"  F1 Score: {f1_lr:.4f}")
    
    # Train Naive Bayes
    print("\n✓ Training Naive Bayes...")
    model_nb = MultinomialNB()
    model_nb.fit(X_train_tfidf, y_train)
    y_pred_nb = model_nb.predict(X_test_tfidf)
    
    acc_nb = accuracy_score(y_test, y_pred_nb)
    prec_nb = precision_score(y_test, y_pred_nb)
    rec_nb = recall_score(y_test, y_pred_nb)
    f1_nb = f1_score(y_test, y_pred_nb)
    
    print(f"  Accuracy: {acc_nb:.4f}")
    print(f"  Precision: {prec_nb:.4f}")
    print(f"  Recall: {rec_nb:.4f}")
    print(f"  F1 Score: {f1_nb:.4f}")
    
    # Save models
    print("\n✓ Saving models...")
    os.makedirs('models', exist_ok=True)
    
    joblib.dump(model_lr, 'models/logreg_model.pkl')
    joblib.dump(model_nb, 'models/naive_bayes_model.pkl')
    joblib.dump(vectorizer, 'models/vectorizer.pkl')
    joblib.dump(tfidf_transformer, 'models/tfidf.pkl')
    
    print("✓ Models saved to models/ folder:")
    print("  - logreg_model.pkl")
    print("  - naive_bayes_model.pkl")
    print("  - vectorizer.pkl")
    print("  - tfidf.pkl")
    
    print("\n" + "=" * 50)
    print("Training completed successfully!")
    print("=" * 50)
    
    return True


if __name__ == '__main__':
    train_and_save_models()



