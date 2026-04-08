"""Environment service — AQI and weather data from WAQI + OpenWeatherMap APIs."""

import httpx
from app.config import settings
from app.utils.icmr import classify_aqi


async def get_current_environment(city: str) -> dict:
    """Fetch current AQI and weather for a city."""
    aqi_data = await _fetch_aqi(city)
    weather_data = await _fetch_weather(city)

    # Classify AQI
    aqi_value = aqi_data.get("aqi", 0)
    aqi_classification = classify_aqi(aqi_value) if aqi_value else {"level": "Unknown", "color": "grey"}
    
    # Health recommendations
    recommendations = get_health_recommendations(aqi_value, weather_data.get("temperature", 25))

    return {
        "city": city,
        "aqi": {
            "value": aqi_value,
            "level": aqi_classification["level"],
            "color": aqi_classification["color"],
            "dominant_pollutant": aqi_data.get("dominant_pollutant", "N/A"),
        },
        "weather": {
            "temperature": weather_data.get("temperature"),
            "humidity": weather_data.get("humidity"),
            "description": weather_data.get("description", "N/A"),
        },
        "recommendations": recommendations,
    }


async def _fetch_aqi(city: str) -> dict:
    """Fetch AQI from WAQI API."""
    if not settings.WAQI_API_KEY or settings.WAQI_API_KEY == "your-waqi-key":
        return _fallback_aqi(city)

    try:
        async with httpx.AsyncClient(timeout=10) as client:
            resp = await client.get(
                f"https://api.waqi.info/feed/{city}/",
                params={"token": settings.WAQI_API_KEY},
            )
            data = resp.json()
            if data.get("status") == "ok":
                return {
                    "aqi": data["data"]["aqi"],
                    "dominant_pollutant": data["data"].get("dominentpol", "N/A"),
                }
    except Exception:
        pass

    return _fallback_aqi(city)


async def _fetch_weather(city: str) -> dict:
    """Fetch weather from OpenWeatherMap API."""
    if not settings.OPENWEATHER_API_KEY or settings.OPENWEATHER_API_KEY == "your-openweather-key":
        return _fallback_weather()

    try:
        async with httpx.AsyncClient(timeout=10) as client:
            resp = await client.get(
                "https://api.openweathermap.org/data/2.5/weather",
                params={"q": city, "appid": settings.OPENWEATHER_API_KEY, "units": "metric"},
            )
            data = resp.json()
            if data.get("main"):
                return {
                    "temperature": data["main"]["temp"],
                    "humidity": data["main"]["humidity"],
                    "description": data["weather"][0]["description"] if data.get("weather") else "N/A",
                }
    except Exception:
        pass

    return _fallback_weather()


def _fallback_aqi(city: str) -> dict:
    """Fallback AQI data when API is unavailable."""
    return {"aqi": 95, "dominant_pollutant": "pm25", "_note": "Fallback data — API key not configured"}


def _fallback_weather() -> dict:
    """Fallback weather data when API is unavailable."""
    return {"temperature": 32, "humidity": 65, "description": "haze", "_note": "Fallback data"}


def get_health_recommendations(aqi: int, temp: float) -> list:
    """Generate health recommendations based on environmental data."""
    recs = []

    if aqi > 300:
        recs.append("🔴 AQI is Severe. Avoid all outdoor activities. Use N95 mask if going outside. Keep windows closed.")
    elif aqi > 200:
        recs.append("🟠 AQI is Poor. Reduce outdoor exercise. Sensitive individuals should stay indoors.")
    elif aqi > 100:
        recs.append("🟡 AQI is Moderate. Sensitive individuals may experience mild discomfort. Consider indoor exercise.")
    else:
        recs.append("🟢 Air quality is good. Outdoor activities are safe.")

    if temp > 40:
        recs.append("🔥 Heatwave conditions. Stay hydrated (3-4L water), avoid direct sun between 11am-4pm.")
    elif temp > 35:
        recs.append("☀️ High temperature. Increase water intake, wear light clothing.")
    elif temp < 10:
        recs.append("❄️ Cold conditions. Dress warmly, protect extremities.")

    return recs
