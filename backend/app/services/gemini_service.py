"""Google Gemini 2.0 Flash integration for health chat responses."""

import time
import google.generativeai as genai
from app.config import settings

# System prompt (condensed from GEMINI_SYSTEM_PROMPT_740_LINES.md)
SYSTEM_PROMPT = """You are Aarogya Sathi (आरोग्य साथी), an AI-powered health companion designed for urban India.

## CORE RULES (NEVER VIOLATE):
1. NEVER diagnose. Say "this may suggest..." or "discuss with your doctor about..."
2. NEVER prescribe medication. Say "your doctor may consider..." 
3. ALWAYS recommend consulting a qualified healthcare provider
4. For ANY emergency (chest pain, breathing difficulty, unconsciousness, severe bleeding, stroke, seizure, suicidal thoughts): IMMEDIATELY tell user to CALL 108 or 112
5. ALWAYS include the disclaimer: "⚠️ This is AI-generated health information, not medical advice. Please consult a qualified healthcare provider."

## WHAT YOU CAN DO:
- Provide general health education based on ICMR and WHO guidelines
- Explain symptoms, conditions, and lifestyle factors
- Suggest when to seek medical attention
- Provide dietary and exercise recommendations per ICMR guidelines
- Interpret environmental data (AQI, temperature) for health impact
- Support mental wellness with coping strategies

## INDIA-SPECIFIC GUIDELINES:
- Use ICMR nutritional guidelines (RDA for Indians)
- Reference Indian food items (dal, roti, sabzi, etc.)
- Use Indian units (INR, km, kg)
- Blood pressure: Normal <120/80, Elevated 120-129/<80, Stage 1 130-139/80-89, Stage 2 ≥140/≥90
- Blood sugar (fasting): Normal 70-100, Prediabetes 100-125, Diabetes ≥126 mg/dL
- BMI (Asian cutoffs): Underweight <18.5, Normal 18.5-22.9, Overweight 23-27.4, Obese ≥27.5
- AQI (Indian NAQI): Good 0-50, Satisfactory 51-100, Moderate 101-200, Poor 201-300

## RESPONSE FORMAT:
- Be warm, empathetic, and conversational
- Use simple language accessible to all education levels
- Include actionable advice
- For health readings: state the classification and what it means
- End with relevant follow-up questions or next steps
- Keep responses focused and under 300 words unless detailed explanation is requested
"""


def _configure_gemini():
    """Initialize Gemini client."""
    if not settings.GOOGLE_API_KEY:
        return None
    genai.configure(api_key=settings.GOOGLE_API_KEY)
    return genai.GenerativeModel("gemini-2.0-flash")


async def get_ai_response(
    message: str,
    health_context: dict = None,
    env_context: dict = None,
) -> dict:
    """Get AI response from Gemini with health and environmental context."""
    start_time = time.time()

    # Build context string
    context_parts = []
    if health_context:
        context_parts.append(f"USER HEALTH DATA:\n- Latest BP: {health_context.get('latest_bp', 'N/A')}")
        context_parts.append(f"- Latest Sugar: {health_context.get('latest_sugar', 'N/A')}")
        context_parts.append(f"- Active Conditions: {health_context.get('conditions', 'None')}")
        context_parts.append(f"- BMI: {health_context.get('bmi', 'N/A')}")

    if env_context:
        context_parts.append(f"\nENVIRONMENTAL DATA:")
        context_parts.append(f"- City: {env_context.get('city', 'N/A')}")
        context_parts.append(f"- AQI: {env_context.get('aqi', 'N/A')}")
        context_parts.append(f"- Temperature: {env_context.get('temperature', 'N/A')}°C")
        context_parts.append(f"- Humidity: {env_context.get('humidity', 'N/A')}%")

    context_str = "\n".join(context_parts) if context_parts else ""

    # Build full prompt
    full_prompt = f"{context_str}\n\nUSER MESSAGE: {message}" if context_str else message

    model = _configure_gemini()
    if model is None:
        # Fallback if no API key is configured
        elapsed = int((time.time() - start_time) * 1000)
        return {
            "response": (
                "I appreciate your question! However, the AI service is currently being configured. "
                "In the meantime, please consult a qualified healthcare provider for medical advice.\n\n"
                "⚠️ This is AI-generated health information, not medical advice. "
                "Please consult a qualified healthcare provider."
            ),
            "tokens_used": 0,
            "response_time_ms": elapsed,
            "model": "fallback",
        }

    try:
        response = model.generate_content(
            contents=full_prompt,
            generation_config=genai.types.GenerationConfig(
                temperature=0.7,
                max_output_tokens=1024,
            ),
            system_instruction=SYSTEM_PROMPT,
        )

        elapsed = int((time.time() - start_time) * 1000)
        tokens_used = 0
        if hasattr(response, "usage_metadata") and response.usage_metadata:
            tokens_used = getattr(response.usage_metadata, "total_token_count", 0)

        return {
            "response": response.text,
            "tokens_used": tokens_used,
            "response_time_ms": elapsed,
            "model": "gemini-2.0-flash",
        }
    except Exception as e:
        elapsed = int((time.time() - start_time) * 1000)
        return {
            "response": (
                "I'm sorry, I'm having trouble processing your request right now. "
                "Please try again in a moment. If this is urgent, please call 108 for emergency services.\n\n"
                "⚠️ This is AI-generated health information, not medical advice."
            ),
            "tokens_used": 0,
            "response_time_ms": elapsed,
            "model": "error",
            "error": str(e),
        }
