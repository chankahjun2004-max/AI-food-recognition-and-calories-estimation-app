# AI Food Recognition and Calories Estimation App

A comprehensive mobile application built to recognize Malaysian foods, estimate serving sizes (volume), calculate weight in grams, and provide accurate nutritional and calorie estimations.

## System Architecture
This project consists of two main components:
1. **Frontend**: A cross-platform mobile app built with Flutter.
2. **Backend**: A Python REST API built with FastAPI that hosts machine learning models.

---

## Features

- **Food Recognition**: Uses YOLOv8 object detection and segmentation to accurately identify various Malaysian dishes (e.g., Nasi Lemak, Roti Canai, Char Siew, Pan Mee).
- **Portion Size & Weight Estimation**: Incorporates the MiDaS Monocular Depth Estimation model alongside YOLO segmentation masks to estimate the actual physical volume (cm³) and weight (grams) of the detected food.
- **Calorie Calculation**: Uses an extensive built-in database of specific food densities and caloric values to convert estimated weights into actionable nutritional data.
- **User Authentication**: Secure sign-up and login powered by Firebase Authentication.
- **Meal History & Tracking**: Stores past meals on Cloud Firestore and visualizes caloric intake over time using charts.
- **Profile & Wellness Insights**: Tracks user BMI and daily caloric goals based on personal metrics.

---

## Tech Stack

### Frontend (Mobile App)
- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: Provider
- **Backend as a Service**: Firebase (Core, Auth, Firestore, Storage)
- **UI/Visualization**: `fl_chart`, `percent_indicator`, `image_picker`
- **Testing**: `flutter_test`, `mocktail`, `firebase_auth_mocks`, `fake_cloud_firestore`

### Backend (Machine Learning API)
- **Framework**: [FastAPI](https://fastapi.tiangolo.com/) with Uvicorn
- **Machine Learning**: 
  - [Ultralytics YOLOv8](https://github.com/ultralytics/ultralytics) (Detection and Segmentation)
  - [PyTorch](https://pytorch.org/) (CPU optimized)
  - [MiDaS](https://github.com/isl-org/MiDaS) (Depth Estimation)
- **Image Processing**: OpenCV, Pillow
- **Deployment**: Docker ready (Google Cloud Run compatible)

---

## Project Structure

```text
├── FYP/                  # Flutter application source code
│   ├── lib/              # Main Dart application code (Views, ViewModels, Models)
│   ├── test/             # Unit and Functional tests
│   ├── pubspec.yaml      # Flutter dependencies
│   └── ...
└── backend/              # Python FastAPI source code
    ├── main.py           # Core API implementation and ML pipeline
    ├── best.pt           # YOLOv8 Object Detection Model weights
    ├── bestSeg.pt        # YOLOv8 Instance Segmentation Model weights
    ├── dpt_swin2_tiny_256.pt # MiDaS Depth Estimation Model weights
    ├── Dockerfile        # Dockerized container setup
    ├── requirements.txt  # Python dependencies
    └── ...
```

---

## Setup Instructions

### 1. Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Create and activate a Python virtual environment (recommended):
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```
3. Install the dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Run the FastAPI server locally:
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8080 --reload
   ```
   *The API will be available at `http://localhost:8080`*

### 2. Frontend Setup

1. Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
2. Navigate to the Flutter app directory:
   ```bash
   cd FYP
   ```
3. Get the required dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application on your connected device or emulator:
   ```bash
   flutter run
   ```

*(Note: Ensure you have your `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) configured in their respective folders for Firebase initialization).*

---

## Testing

The Flutter application includes a comprehensive test suite. To run the tests:

```bash
cd FYP
flutter test
```

## Docker Deployment

To deploy the backend using Docker:

```bash
cd backend
docker build -t food-recognition-backend .
docker run -p 8080:8080 food-recognition-backend
```
