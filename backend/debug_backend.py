
import requests
import json
import os
from ultralytics import YOLO
from PIL import Image
import io

# Configuration
BACKEND_URL = "https://backend-597587756390.asia-southeast1.run.app/predict"
IMAGE_PATH = "test_image.jpeg" # We will need the user to provide this or we use a dummy
LOCAL_MODEL_PATH = "best.pt"

def test_cloud_run(image_path):
    print(f"Testing Cloud Run Endpoint: {BACKEND_URL}")
    if not os.path.exists(image_path):
        print(f"Error: Image not found at {image_path}")
        return

    try:
        with open(image_path, 'rb') as f:
            files = {'file': f}
            response = requests.post(BACKEND_URL, files=files)
        
        print(f"Status Code: {response.status_code}")
        print(f"Response Body: {response.text}")
    except Exception as e:
        print(f"Cloud Run request failed: {e}")

def test_local_model(image_path, model_path):
    print(f"\nTesting Local Model: {model_path}")
    if not os.path.exists(model_path):
        print(f"Error: Model not found at {model_path}")
        return
    if not os.path.exists(image_path):
        print(f"Error: Image not found at {image_path}")
        return

    try:
        model = YOLO(model_path)
        # Run inference with low confidence to see if ANYTHING is detected
        results = model(image_path, conf=0.1) 
        
        for result in results:
            print(f"Boxes: {len(result.boxes)}")
            for box in result.boxes:
                print(f" - Class: {result.names[int(box.cls)]}, Conf: {float(box.conf):.2f}")
                
    except Exception as e:
        print(f"Local model inference failed: {e}")

if __name__ == "__main__":
    # Create a dummy image if it doesn't exist for connectivity test
    if not os.path.exists(IMAGE_PATH):
        # Verify if we can use one of the existing images
        # using one of the icons found
        found_image = r"FYP(GIL)\FYP\web\icons\Icon-512.png"
        if os.path.exists(found_image):
             IMAGE_PATH = found_image
             print(f"Using existing icon for connectivity test: {IMAGE_PATH}")
        else:
             print("Please place a food image named 'test_image.jpg' in this folder to test detection quality.")
    
    test_cloud_run(IMAGE_PATH)
    
    # Only test local model if best.pt exists
    if os.path.exists(LOCAL_MODEL_PATH):
        test_local_model(IMAGE_PATH, LOCAL_MODEL_PATH)
    else:
        print(f"\nLocal model {LOCAL_MODEL_PATH} not found. Cannot verify local inference.")
