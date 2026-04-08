"""Safety pipeline tests — ensures AI responses are medically safe."""

import pytest
from app.services.safety_service import check_safety


def test_no_diagnosis_claim():
    """AI response should not make diagnosis claims."""
    response = "Based on your symptoms, you have diabetes and need insulin."
    result = check_safety(response, "I feel thirsty all the time")
    assert result["diagnosis_claim"] is True
    assert "you have diabetes" not in result["safe_response"].lower()


def test_no_prescription():
    """AI response should not prescribe specific medications."""
    response = "Take 500mg paracetamol twice daily for your headache."
    result = check_safety(response, "I have a headache")
    assert result["prescription_claim"] is True
    assert "Only a qualified doctor can prescribe" in result["safe_response"]


def test_emergency_detection_chest_pain():
    """Emergency keywords in user message should trigger emergency banner."""
    result = check_safety("Please rest and monitor.", "I have severe chest pain")
    assert result["emergency"] is True
    assert "108" in result["safe_response"]
    assert "EMERGENCY" in result["safe_response"]


def test_emergency_detection_breathing():
    """Can't breathe should trigger emergency."""
    result = check_safety("Take deep breaths.", "I can't breathe properly")
    assert result["emergency"] is True
    assert "108" in result["safe_response"]


def test_emergency_detection_suicide():
    """Suicidal language should trigger emergency response."""
    result = check_safety("I understand you're going through a tough time.", "I want to kill myself")
    assert result["emergency"] is True
    assert "108" in result["safe_response"]


def test_disclaimer_present():
    """Every response must contain the disclaimer symbol."""
    result = check_safety("Drink warm water and rest.", "I have a cold")
    assert "⚠️" in result["safe_response"]


def test_disclaimer_not_duplicated():
    """If response already has disclaimer, don't add another."""
    response = "Stay hydrated. ⚠️ This is not medical advice."
    result = check_safety(response, "How much water should I drink?")
    assert result["safe_response"].count("⚠️") == 1


def test_safe_response_passes():
    """A clean response without diagnosis/prescription should pass safety."""
    response = "Staying hydrated is important. Aim for 2-3 liters of water daily."
    result = check_safety(response, "How much water should I drink?")
    assert result["diagnosis_claim"] is False
    assert result["prescription_claim"] is False
    assert result["emergency"] is False


def test_multiple_flags():
    """Response with both diagnosis and prescription should flag both."""
    response = "You have hypertension. Take 5mg amlodipine daily."
    result = check_safety(response, "My BP is high")
    assert result["diagnosis_claim"] is True
    assert result["prescription_claim"] is True
