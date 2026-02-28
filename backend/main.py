from fastapi import FastAPI, UploadFile, File
from ultralytics import YOLO
from PIL import Image, ImageOps
import io

app = FastAPI()

# Load the YOLOv8 model
# Ensure best.pt is in the same directory
model = YOLO("best.pt")

@app.get("/")
def read_root():
    return {"message": "YOLOv8 API is running!"}

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    # Read the image file
    image_data = await file.read()
    image = Image.open(io.BytesIO(image_data))
    
    # Fix EXIF rotation which is common with phone cameras
    image = ImageOps.exif_transpose(image)

    # Perform inference with lower confidence threshold
    results = model(image, conf=0.15)

    # Process results (this returns bounding boxes, classes, and confidence)
    detections = []
    for result in results:
        for box in result.boxes:
            detections.append({
                "class": result.names[int(box.cls)],
                "confidence": float(box.conf),
                "bbox": box.xyxy.tolist()[0]
            })

    return {"detections": detections}
