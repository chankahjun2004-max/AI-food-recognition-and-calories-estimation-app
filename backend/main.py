from fastapi import FastAPI, UploadFile, File
from ultralytics import YOLO
from PIL import Image, ImageOps
import io
import numpy as np
import torch
import torchvision.transforms as T
import cv2

app = FastAPI()

# --- Initialize YOLO ---
# Ensure best.pt (detection) and bestSeg.pt (segmentation) are in the same directory
try:
    model_det = YOLO("best.pt")
    model_seg = YOLO("bestSeg.pt")
except Exception as e:
    print(f"Warning: Could not load YOLO models properly: {e}")
    model_det = None
    model_seg = None

# --- Initialize MiDaS ---
print("Initializing MiDaS Monocular Depth Estimation model...")
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model_type = "DPT_SwinV2_T_256"
try:
    midas = torch.hub.load("isl-org/MiDaS", model_type, pretrained=False)
    state_dict = torch.load("dpt_swin2_tiny_256.pt", map_location=device)
    if "model" in state_dict:
        state_dict = state_dict["model"]
    midas.load_state_dict(state_dict)
    midas.to(device)
    midas.eval()
    print("MiDaS successfully loaded from local .pt file!")
except Exception as e:
    print(f"Error loading MiDaS model: {e}")
    midas = None

# MiDaS tiny expects 256x256 standard normalization
midas_transform = T.Compose([
    T.ToTensor(),
    T.Resize((256, 256), antialias=True),
    T.Normalize(mean=[0.5, 0.5, 0.5], std=[0.5, 0.5, 0.5])
])

# Simple predefined dictionary for Malaysian food densities (g/cm³) and calories per gram
# (You should expand this dictionary based on your specific YOLOv8 classes)
# Expanded dictionary for Malaysian food densities (g/cm³) and calories per gram (kcal/g)
food_database = {
    "Apam Balik": {"density": 0.60, "cal_per_g": 2.80},
    "Bak Kut Teh": {"density": 1.00, "cal_per_g": 1.60},
    "Bean Sprouts": {"density": 0.50, "cal_per_g": 0.30},
    "Beef Rendang": {"density": 1.10, "cal_per_g": 2.10},
    "Boil Pork Slices": {"density": 1.05, "cal_per_g": 1.60},
    "Boiled Egg": {"density": 1.03, "cal_per_g": 1.55},
    "Char Siew": {"density": 1.05, "cal_per_g": 2.50},
    "Chee Cheong Fun": {"density": 1.10, "cal_per_g": 1.10},
    "Chicken Rice": {"density": 1.05, "cal_per_g": 1.60},
    "Chicken Satay": {"density": 1.05, "cal_per_g": 1.90},
    "Chinese Poach Chicken": {"density": 1.05, "cal_per_g": 1.65},
    "Chinese Sausage": {"density": 1.10, "cal_per_g": 4.80},
    "Curry": {"density": 1.00, "cal_per_g": 1.20},
    "Curry Chicken": {"density": 1.05, "cal_per_g": 1.80},
    "Eggplant": {"density": 0.90, "cal_per_g": 0.90},
    "Fish Ball": {"density": 1.05, "cal_per_g": 0.95},
    "Fish Cake": {"density": 1.05, "cal_per_g": 1.10},
    "Fried Anchovies": {"density": 0.60, "cal_per_g": 2.80}, # Loose packing
    "Fried Banana": {"density": 0.90, "cal_per_g": 2.50},
    "Fried Chicken": {"density": 0.95, "cal_per_g": 2.80},
    "Fried Dumpling": {"density": 0.95, "cal_per_g": 2.40},
    "Fried Egg": {"density": 0.95, "cal_per_g": 1.95},
    "Fried Fu Cuk": {"density": 0.40, "cal_per_g": 4.50}, # Very airy/crispy
    "Fried Kuey Teow": {"density": 1.05, "cal_per_g": 1.85},
    "Fried Rice": {"density": 1.00, "cal_per_g": 1.75},
    "Fried Squid": {"density": 1.05, "cal_per_g": 2.10},
    "Garlic": {"density": 1.05, "cal_per_g": 1.49},
    "Green Vegetables": {"density": 0.80, "cal_per_g": 0.60}, # Cooked/wilted
    "Keropok Lekor": {"density": 1.00, "cal_per_g": 2.40},
    "Maggie Noodle": {"density": 1.05, "cal_per_g": 1.40},
    "Minced Pork": {"density": 1.05, "cal_per_g": 2.40},
    "Murtabak": {"density": 0.90, "cal_per_g": 2.20},
    "Mushroom": {"density": 0.90, "cal_per_g": 0.35},
    "Nasi Kerabu": {"density": 1.00, "cal_per_g": 1.45},
    "Nasi Lemak": {"density": 1.05, "cal_per_g": 2.00},
    "Pan Mee Noodle": {"density": 1.10, "cal_per_g": 3.50},
    "Peanut": {"density": 0.65, "cal_per_g": 5.67}, # Bulk density (loose)
    "Peanut Sauce": {"density": 1.05, "cal_per_g": 2.50},
    "Poach Egg": {"density": 1.00, "cal_per_g": 1.43},
    "Pork Ball": {"density": 1.05, "cal_per_g": 2.10},
    "Pork Lard": {"density": 0.80, "cal_per_g": 8.00},
    "Pork Ribs": {"density": 1.05, "cal_per_g": 2.60},
    "Prawn": {"density": 1.05, "cal_per_g": 0.99},
    "Rice Noodle": {"density": 1.05, "cal_per_g": 1.40},
    "Roasted Chicken": {"density": 1.05, "cal_per_g": 2.20},
    "Roasted Pork": {"density": 1.05, "cal_per_g": 3.30},
    "Roti Canai": {"density": 0.85, "cal_per_g": 3.20},
    "Salted Egg": {"density": 1.05, "cal_per_g": 1.85},
    "Sambal": {"density": 1.10, "cal_per_g": 2.00},
    "Sambal Squid": {"density": 1.05, "cal_per_g": 1.70},
    "Sliced Cucumber": {"density": 0.95, "cal_per_g": 0.15},
    "Sliced Red Onion": {"density": 0.95, "cal_per_g": 0.40},
    "Sliced Tomato": {"density": 0.95, "cal_per_g": 0.18},
    "Soup Dumpling": {"density": 1.05, "cal_per_g": 1.80},
    "Stuffed Chili Pepper": {"density": 1.00, "cal_per_g": 1.20},
    "Tau Pok": {"density": 0.40, "cal_per_g": 2.20}, # Very porous tofu
    "Ulam-Ulaman": {"density": 0.30, "cal_per_g": 0.20}, # Raw leaves, very low volume weight
    "Wan Tan Mee Noodle": {"density": 1.05, "cal_per_g": 1.70},
    "White Rice": {"density": 1.05, "cal_per_g": 1.30},
    "Yellow Noodle": {"density": 1.05, "cal_per_g": 1.50},
    "You Tiao": {"density": 0.30, "cal_per_g": 4.10}, # Mostly air
    "default": {"density": 1.00, "cal_per_g": 2.00}
}

@app.get("/")
def read_root():
    return {"message": "YOLOv8 + MiDaS Depth API is running!"}

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    # Read the image file
    image_data = await file.read()
    image = Image.open(io.BytesIO(image_data)).convert('RGB')
    image = ImageOps.exif_transpose(image)
    
    image_width, image_height = image.size
    img_cv = np.array(image)

    # 1. Perform Monocular Depth Estimation
    depth_map = None
    if midas is not None:
        try:
            input_batch = midas_transform(img_cv).unsqueeze(0).to(device)
            with torch.no_grad():
                prediction = midas(input_batch)
                # Resize the depth map to match the original image resolution
                prediction = torch.nn.functional.interpolate(
                    prediction.unsqueeze(1),
                    size=(image_height, image_width),
                    mode="bicubic",
                    align_corners=False,
                ).squeeze()
            depth_map = prediction.cpu().numpy()
        except Exception as e:
            print(f"Depth estimation failed: {e}")

    # 2. Perform Object Detection and Segmentation
    results_det = model_det(image, conf=0.15) if model_det else []
    results_seg = model_seg(image, conf=0.15) if model_seg else []

    def get_iou(boxA, boxB):
        xA = max(boxA[0], boxB[0])
        yA = max(boxA[1], boxB[1])
        xB = min(boxA[2], boxB[2])
        yB = min(boxA[3], boxB[3])
        interArea = max(0, xB - xA) * max(0, yB - yA)
        return interArea / float(((boxA[2]-boxA[0])*(boxA[3]-boxA[1])) + ((boxB[2]-boxB[0])*(boxB[3]-boxB[1])) - interArea + 1e-5)

    detections = []
    seg_boxes_list = []
    
    # Adjusted FOV area: Reduced to 600.0 (roughly 30cm x 20cm) to halving the weight estimates as requested.
    TOTAL_IMAGE_AREA_CM2 = 800.0

    # Process segmentation results first (Primary for MakanPortionNet)
    if len(results_seg) > 0 and results_seg[0].boxes is not None:
        r_seg = results_seg[0]
        has_masks = r_seg.masks is not None
        masks_resized = None
        
        if has_masks:
            masks_tensor = r_seg.masks.data.unsqueeze(1)
            masks_resized = torch.nn.functional.interpolate(
                masks_tensor, size=(image_height, image_width), mode='nearest'
            ).squeeze(1).cpu().numpy()
            
        for k, box in enumerate(r_seg.boxes):
            class_name = r_seg.names[int(box.cls)]
            seg_bb = box.xyxy.tolist()[0]
            seg_boxes_list.append(seg_bb)
            
            food_info = food_database.get(class_name, food_database["default"])
            vol = 0
            weight_g = 0
            calories = 0
            percentage_area = 0
            
            if has_masks and masks_resized is not None and k < len(masks_resized):
                # Guaranteed 1-to-1 match because segmentation model outputs box and mask exactly together
                mask = masks_resized[k]
                mask_area_pixels = np.sum(mask > 0.5)
                percentage_area = mask_area_pixels / (image_height * image_width)
                
                # Rescale based on FOV assumption not raw pixel count
                area_cm2 = percentage_area * TOTAL_IMAGE_AREA_CM2
                
                avg_thickness_cm = 1.0
                if depth_map is not None and mask_area_pixels > 0:
                    masked_depth = depth_map[mask > 0.5]
                    raw_depth = float(np.mean(masked_depth))
                    # MiDaS tuning depth disparity to thickness height. Max 5cm for typical plated food.
                    avg_thickness_cm = max(0.5, raw_depth / 300.0)
                    avg_thickness_cm = min(avg_thickness_cm, 5.0)
                    
                vol = area_cm2 * avg_thickness_cm
                weight_g = vol * food_info["density"]
                calories = weight_g * food_info["cal_per_g"]
                
            detections.append({
                "class": class_name,
                "confidence": float(box.conf),
                "bbox": seg_bb,
                "portion_percentage": round(percentage_area * 100, 2),
                "volume_cm3": round(vol, 2),
                "estimated_grams": round(weight_g, 1),
                "calories": round(calories, 1),
                "density_used": food_info["density"],
                "cal_per_g_used": food_info["cal_per_g"],
            })

    # Fallback/merge detection results (Only add if no overlap with a segmented box)
    if len(results_det) > 0 and results_det[0].boxes is not None:
        r_det = results_det[0]
        for box in r_det.boxes:
            det_bb = box.xyxy.tolist()[0]
            
            is_duplicate = False
            for s_bb in seg_boxes_list:
                if get_iou(det_bb, s_bb) > 0.5:
                    is_duplicate = True
                    break
                    
            if not is_duplicate:
                class_name = r_det.names[int(box.cls)]
                food_info = food_database.get(class_name, food_database["default"])
                detections.append({
                    "class": class_name,
                    "confidence": float(box.conf),
                    "bbox": det_bb,
                    "portion_percentage": 0,
                    "volume_cm3": 0,
                    "estimated_grams": 0,
                    "calories": 0,
                    "density_used": food_info["density"],
                    "cal_per_g_used": food_info["cal_per_g"],
                })

    return {"detections": detections, "depth_map_generated": depth_map is not None}
