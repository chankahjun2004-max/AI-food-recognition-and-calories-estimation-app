import torch
import cv2
import numpy as np

def test_midas():
    try:
        print("Loading architecture...")
        model_type = "DPT_SwinV2_T_256"
        model = torch.hub.load("isl-org/MiDaS", model_type, pretrained=False)
        print("Loading weights...")
        device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        
        # Load local weights
        state_dict = torch.load("dpt_swin2_tiny_256.pt", map_location=device)
        # Handle cases where weights might be wrapped
        if "model" in state_dict:
            state_dict = state_dict["model"]
            
        model.load_state_dict(state_dict)
        print("Weights loaded successfully!")
        
        model.eval()
        
        # Load transforms to resize and normalize the image
        # Load transforms and configure for 256
        import torchvision.transforms as T
        transform = T.Compose([
            T.ToTensor(),
            T.Resize((256, 256), antialias=True),
            T.Normalize(mean=[0.5, 0.5, 0.5], std=[0.5, 0.5, 0.5])
        ])
        
        # Create a dummy image to test inference
        img = np.zeros((480, 640, 3), dtype=np.uint8)
        input_batch = transform(img).unsqueeze(0).to(device)
        
        print("Running inference...")
        with torch.no_grad():
            prediction = model(input_batch)
            
            prediction = torch.nn.functional.interpolate(
                prediction.unsqueeze(1),
                size=img.shape[:2],
                mode="bicubic",
                align_corners=False,
            ).squeeze()
        
        output = prediction.cpu().numpy()
        print(f"Inference successful! Depth map shape: {output.shape}")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_midas()
