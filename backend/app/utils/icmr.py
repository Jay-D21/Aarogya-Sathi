"""ICMR-based health threshold constants for India-specific health assessments."""

# Blood Pressure Classification (Asian/Indian cutoffs)
BP_CLASSIFICATION = {
    "normal": {"systolic": (0, 119), "diastolic": (0, 79), "label": "Normal", "color": "green"},
    "elevated": {"systolic": (120, 129), "diastolic": (0, 79), "label": "Elevated", "color": "yellow"},
    "stage1": {"systolic": (130, 139), "diastolic": (80, 89), "label": "Hypertension Stage 1", "color": "orange"},
    "stage2": {"systolic": (140, 300), "diastolic": (90, 300), "label": "Hypertension Stage 2", "color": "red"},
}

# Blood Sugar Classification (mg/dL)
SUGAR_FASTING = {
    "normal": {"range": (70, 100), "label": "Normal"},
    "prediabetes": {"range": (101, 125), "label": "Prediabetes"},
    "diabetes": {"range": (126, 600), "label": "Diabetes"},
    "hypoglycemia": {"range": (0, 69), "label": "Hypoglycemia"},
}

SUGAR_RANDOM = {
    "normal": {"range": (70, 139), "label": "Normal"},
    "prediabetes": {"range": (140, 199), "label": "Prediabetes"},
    "diabetes": {"range": (200, 600), "label": "Diabetes"},
}

SUGAR_POST_MEAL = {
    "normal": {"range": (70, 139), "label": "Normal"},
    "prediabetes": {"range": (140, 199), "label": "Prediabetes"},
    "diabetes": {"range": (200, 600), "label": "Diabetes"},
}

# BMI Classification (Asian cutoffs)
BMI_CLASSIFICATION = {
    "underweight": {"range": (0, 18.4), "label": "Underweight"},
    "normal": {"range": (18.5, 22.9), "label": "Normal"},
    "overweight": {"range": (23.0, 27.4), "label": "Overweight"},
    "obese": {"range": (27.5, 100), "label": "Obese"},
}

# AQI Classification (Indian NAQI scale)
AQI_LEVELS = {
    "good": {"range": (0, 50), "label": "Good", "color": "green"},
    "satisfactory": {"range": (51, 100), "label": "Satisfactory", "color": "lightgreen"},
    "moderate": {"range": (101, 200), "label": "Moderate", "color": "yellow"},
    "poor": {"range": (201, 300), "label": "Poor", "color": "orange"},
    "severe": {"range": (301, 400), "label": "Severe", "color": "red"},
    "hazardous": {"range": (401, 999), "label": "Hazardous", "color": "darkred"},
}


def classify_bp(systolic: int, diastolic: int) -> dict:
    """Classify BP per ICMR/Indian guidelines."""
    if systolic >= 140 or diastolic >= 90:
        return {"status": "Hypertension Stage 2", "severity": "high", "color": "red"}
    elif systolic >= 130 or diastolic >= 80:
        return {"status": "Hypertension Stage 1", "severity": "moderate", "color": "orange"}
    elif systolic >= 120:
        return {"status": "Elevated", "severity": "low", "color": "yellow"}
    else:
        return {"status": "Normal", "severity": "none", "color": "green"}


def classify_sugar(value: int, reading_type: str = "random") -> dict:
    """Classify blood sugar per ICMR guidelines."""
    lookup = {"fasting": SUGAR_FASTING, "random": SUGAR_RANDOM, "post_meal": SUGAR_POST_MEAL}
    classifications = lookup.get(reading_type, SUGAR_RANDOM)

    for key, info in classifications.items():
        low, high = info["range"]
        if low <= value <= high:
            return {"status": info["label"], "severity": key}
    return {"status": "Unknown", "severity": "unknown"}


def classify_bmi(weight_kg: float, height_cm: float) -> dict:
    """Calculate BMI and classify per Asian cutoffs."""
    if height_cm <= 0:
        return {"bmi": 0, "status": "Invalid Height"}
    height_m = height_cm / 100.0
    bmi = round(weight_kg / (height_m * height_m), 2)

    for key, info in BMI_CLASSIFICATION.items():
        low, high = info["range"]
        if low <= bmi <= high:
            return {"bmi": bmi, "status": info["label"]}
    return {"bmi": bmi, "status": "Obese"}


def classify_aqi(aqi: int) -> dict:
    """Classify AQI per Indian NAQI scale."""
    for key, info in AQI_LEVELS.items():
        low, high = info["range"]
        if low <= aqi <= high:
            return {"level": info["label"], "color": info["color"]}
    return {"level": "Hazardous", "color": "darkred"}
