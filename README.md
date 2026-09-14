# Insurance Premium Prediction API

A FastAPI-based REST API that serves a pre-trained machine learning model to predict a user's **insurance premium category** (e.g. Low, Medium, High) based on personal and lifestyle attributes.

---

## Features

- Predicts insurance premium category with confidence scores and full class probability distribution
- Automatic feature engineering from raw user inputs (BMI, age group, lifestyle risk, city tier)
- Input validation via Pydantic with descriptive error messages
- Health check endpoint for monitoring

---

## Project Structure

```
Model Serving/
├── app.py                      # FastAPI application & route definitions
├── requirements.txt            # Python dependencies
├── config/
│   └── city_tier.py            # Tier 1 / Tier 2 city lists
├── model/
│   ├── model.pkl               # Pre-trained scikit-learn model
│   └── predict.py              # Model loading & prediction logic
└── schema/
    ├── user_input.py           # Request schema with computed fields
    └── prediction_response.py  # Response schema
```

---

## API Endpoints

### `GET /`
Returns a simple status message confirming the API is running.

**Response**
```json
{"message": "Insurance Prediction API"}
```

---

### `GET /health`
Returns model health and version information.

**Response**
```json
{
  "status": "OK",
  "version": "1.0.0",
  "model_loaded": true
}
```

---

### `POST /predict`
Accepts user data and returns the predicted insurance premium category.

**Request Body**

| Field        | Type    | Constraints                          | Description                        |
|--------------|---------|--------------------------------------|------------------------------------|
| `age`        | integer | 1 – 119                              | Age of the user                    |
| `weight`     | float   | > 0, < 300 (kg)                      | Weight of the user                 |
| `height`     | float   | > 0 (metres)                         | Height of the user                 |
| `income_lpa` | float   | > 0                                  | Annual income in Lakhs Per Annum   |
| `smoker`     | boolean | —                                    | Whether the user is a smoker       |
| `city`       | string  | —                                    | City of residence                  |
| `occupation` | string  | See valid values below               | Primary occupation of the user     |

**Valid `occupation` values**
`retired`, `freelancer`, `student`, `government_job`, `business_owner`, `unemployed`, `private_job`

**Example Request**
```json
{
  "age": 35,
  "weight": 80,
  "height": 1.75,
  "income_lpa": 12.5,
  "smoker": false,
  "city": "Mumbai",
  "occupation": "private_job"
}
```

**Example Response**
```json
{
  "predicted_category": "Medium",
  "confidence": 0.7841,
  "class_probabilities": {
    "Low": 0.1023,
    "Medium": 0.7841,
    "High": 0.1136
  }
}
```

---

## Feature Engineering

The following features are **automatically computed** from the raw input before being passed to the model:

| Computed Feature  | Logic                                                                                          |
|-------------------|-----------------------------------------------------------------------------------------------|
| `bmi`             | `weight / height²`                                                                            |
| `age_group`       | `young` (< 25), `adult` (< 45), `middle_aged` (< 60), `senior` (60+)                        |
| `lifestyle_risk`  | `high` (smoker AND BMI > 30), `medium` (smoker OR BMI > 27), `low` (otherwise)              |
| `city_tier`       | `1` (major metros), `2` (large cities), `3` (all others) — see `config/city_tier.py`         |

---

## Setup & Running

### 1. Create and activate a virtual environment

```bash
python -m venv .venv

# Windows
.venv\Scripts\activate

# macOS / Linux
source .venv/bin/activate
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Start the server

```bash
uvicorn app:app --reload
```

The API will be available at `http://127.0.0.1:8000`.

### 4. Explore the interactive docs

FastAPI generates interactive documentation automatically:

- **Swagger UI**: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
- **ReDoc**: [http://127.0.0.1:8000/redoc](http://127.0.0.1:8000/redoc)

---

## Dependencies

| Package           | Version  | Purpose                        |
|-------------------|----------|--------------------------------|
| `fastapi`         | 0.141.1  | Web framework                  |
| `uvicorn`         | 0.52.4   | ASGI server                    |
| `python-multipart`| 0.0.32   | Form data parsing              |
| `pydantic`        | 2.13.5   | Data validation & serialisation|
| `pandas`          | 2.3.1    | DataFrame construction         |
| `numpy`           | 2.3.1    | Numerical operations           |
| `scikit-learn`    | 1.6.1    | ML model (training & inference)|
| `joblib`          | 1.5.1    | Model serialisation support    |
