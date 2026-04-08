"""ICMR classification tests — pure Python, no database needed."""

import pytest
from app.utils.icmr import classify_bp, classify_sugar, classify_bmi, classify_aqi


# ── Blood Pressure Classification ──

def test_bp_normal():
    result = classify_bp(115, 75)
    assert result["status"] == "Normal"
    assert result["color"] == "green"


def test_bp_elevated():
    result = classify_bp(125, 78)
    assert result["status"] == "Elevated"


def test_bp_stage1():
    result = classify_bp(135, 85)
    assert result["status"] == "Hypertension Stage 1"
    assert result["color"] == "orange"


def test_bp_stage2():
    result = classify_bp(150, 95)
    assert result["status"] == "Hypertension Stage 2"
    assert result["color"] == "red"


def test_bp_diastolic_drives_stage2():
    """Even if systolic is normal, high diastolic should trigger."""
    result = classify_bp(118, 92)
    assert result["status"] == "Hypertension Stage 2"


# ── Blood Sugar Classification ──

def test_sugar_fasting_normal():
    result = classify_sugar(85, "fasting")
    assert result["status"] == "Normal"


def test_sugar_fasting_prediabetes():
    result = classify_sugar(115, "fasting")
    assert result["status"] == "Prediabetes"


def test_sugar_fasting_diabetes():
    result = classify_sugar(180, "fasting")
    assert result["status"] == "Diabetes"


def test_sugar_random_normal():
    result = classify_sugar(120, "random")
    assert result["status"] == "Normal"


def test_sugar_random_diabetes():
    result = classify_sugar(250, "random")
    assert result["status"] == "Diabetes"


# ── BMI Classification (Asian cutoffs) ──

def test_bmi_normal():
    result = classify_bmi(65, 170)
    assert result["status"] == "Normal"
    assert 18.5 <= result["bmi"] <= 22.9


def test_bmi_overweight():
    result = classify_bmi(75, 170)  # BMI ~25.95
    assert result["status"] == "Overweight"


def test_bmi_obese():
    result = classify_bmi(100, 170)
    assert result["status"] == "Obese"


def test_bmi_zero_height():
    result = classify_bmi(70, 0)
    assert result["status"] == "Invalid Height"


# ── AQI Classification ──

def test_aqi_good():
    result = classify_aqi(35)
    assert result["level"] == "Good"


def test_aqi_severe():
    result = classify_aqi(350)
    assert result["level"] == "Severe"
    assert result["color"] == "red"


def test_aqi_hazardous():
    result = classify_aqi(450)
    assert result["level"] == "Hazardous"
