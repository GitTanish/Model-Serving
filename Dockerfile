# use Python 3.11 base image
FROM python:3.11-slim

#set working directory
WORKDIR /app

# copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# copy rest of application code
COPY . .

# Expose the application port
EXPOSE 8000

# command to start FastAPI application
CMD ["uvicorn", "app:app", "--host", "0.0.0.0","--port","8000"]
