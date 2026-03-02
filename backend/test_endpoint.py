from fastapi.testclient import TestClient
from main import app
import json

client = TestClient(app)

def test_predict():
    with open("test_image.jpeg", "rb") as f:
        response = client.post(
            "/predict",
            files={"file": ("test_image.jpeg", f, "image/jpeg")}
        )
    print(f"Status: {response.status_code}")
    print(json.dumps(response.json(), indent=2))

if __name__ == "__main__":
    test_predict()
