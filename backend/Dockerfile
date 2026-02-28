# Use an official Python runtime as a parent image
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Install system dependencies required for OpenCV
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip install --upgrade pip

# Install PyTorch CPU version FIRST (to avoid downloading massive GPU version)
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Install OpenCV Headless FIRST to avoid Ultralytics pulling the wrong one
RUN pip install --no-cache-dir opencv-python-headless

# Install Ultralytics explicitly (it will use the already installed CPU torch and opencv-headless)
RUN pip install --no-cache-dir ultralytics

# Copy the requirements file into the container
COPY requirements.txt .

# Install other packages (FastAPI, etc.)
RUN pip install --no-cache-dir -r requirements.txt

# Copy the current directory contents into the container at /app
COPY . .

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Run main.py when the container launches
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
