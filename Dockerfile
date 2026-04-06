# Use official Python image
FROM python:3.11-slim

# Set working directory inside container
WORKDIR /app

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY . .

# Expose the port Flask will run on
EXPOSE 5000

# Set environment variable to prevent Python buffering issues
ENV PYTHONUNBUFFERED=1

# Command to run Flask app
CMD ["python", "app.py"]