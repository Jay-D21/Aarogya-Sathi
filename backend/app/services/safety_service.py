"""Safety pipeline for medical AI responses — ensures no diagnosis, no prescriptions, emergency detection."""

import re
from typing import Dict

# Patterns that indicate the AI is making a diagnosis claim
DIAGNOSIS_PATTERNS = [
    r"you\s+have\s+\w+",
    r"you\s+are\s+suffering\s+from",
    r"i\s+can\s+tell\s+you\s+have",
    r"diagnosis\s*:\s*",
    r"you\s+are\s+diagnosed\s+with",
    r"this\s+is\s+clearly\s+a\s+case\s+of",
    r"you\s+definitely\s+have",
]

# Patterns that indicate prescription-like language
PRESCRIPTION_PATTERNS = [
    r"take\s+\d+\s*mg",
    r"tablet\s+per\s+day",
    r"dosage\s+of\s+\d+",
    r"prescribe\s+you",
    r"prescription\s*:",
    r"\d+\s*mg\s+(twice|thrice|once)\s+daily",
    r"take\s+(paracetamol|ibuprofen|aspirin|crocin|dolo|combiflam|metformin|amlodipine)",
]

# Emergency keywords that require immediate intervention
EMERGENCY_KEYWORDS = [
    "chest pain", "can't breathe", "cannot breathe", "difficulty breathing",
    "unconscious", "seizure", "severe bleeding", "stroke",
    "suicide", "want to die", "kill myself", "end my life",
    "heart attack", "fainting", "collapsed", "not responding",
    "severe allergic reaction", "anaphylaxis",
]

STANDARD_DISCLAIMER = (
    "\n\n⚠️ **Disclaimer:** I am an AI health assistant, not a doctor. "
    "This information is for educational purposes only and should not replace "
    "professional medical advice. Please consult a qualified healthcare provider "
    "for diagnosis and treatment."
)

EMERGENCY_BANNER = (
    "🚨 **MEDICAL EMERGENCY DETECTED** 🚨\n\n"
    "**Please call 108 (Indian Emergency) or 112 immediately!**\n"
    "If someone is with you, ask them to call while you follow basic first aid.\n\n"
    "---\n\n"
)


def check_safety(ai_response: str, user_message: str) -> Dict:
    """
    Run safety checks on AI response. Returns sanitized response and flags.
    
    Checks:
    1. Diagnosis claims → replaced with safer language
    2. Prescription claims → appended with doctor warning
    3. Emergency keywords → prepended with emergency banner + 108 number
    4. Disclaimer → ensured present
    """
    safe_response = ai_response
    contained_diagnosis_claim = False
    contained_prescription_claim = False
    contained_emergency_keywords = False
    safety_passed = True

    # 1. Check for diagnosis claims in AI response
    for pattern in DIAGNOSIS_PATTERNS:
        if re.search(pattern, safe_response, re.IGNORECASE):
            contained_diagnosis_claim = True
            safety_passed = False
            # Replace with safer language
            safe_response = re.sub(
                pattern,
                "based on the symptoms you described, it may be worth discussing with your doctor about",
                safe_response,
                flags=re.IGNORECASE,
            )

    # 2. Check for prescription claims in AI response
    for pattern in PRESCRIPTION_PATTERNS:
        if re.search(pattern, safe_response, re.IGNORECASE):
            contained_prescription_claim = True
            safety_passed = False

    if contained_prescription_claim:
        safe_response += (
            "\n\n⚕️ **Important:** Only a qualified doctor can prescribe medications. "
            "Please do not self-medicate based on AI suggestions."
        )

    # 3. Check for emergency keywords in USER message
    user_msg_lower = user_message.lower()
    for keyword in EMERGENCY_KEYWORDS:
        if keyword in user_msg_lower:
            contained_emergency_keywords = True
            break

    if contained_emergency_keywords:
        safe_response = EMERGENCY_BANNER + safe_response

    # 4. Ensure disclaimer is present
    if "⚠️" not in safe_response:
        safe_response += STANDARD_DISCLAIMER

    return {
        "safe_response": safe_response,
        "diagnosis_claim": contained_diagnosis_claim,
        "prescription_claim": contained_prescription_claim,
        "emergency": contained_emergency_keywords,
        "safety_passed": not (contained_diagnosis_claim or contained_prescription_claim),
    }
