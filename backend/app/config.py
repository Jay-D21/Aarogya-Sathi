from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = "postgresql+asyncpg://arogya_user:arogya_dev_password@localhost:5432/arogya_sathi"
    
    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"
    
    # JWT
    JWT_SECRET: str = "change-me-to-a-random-256-bit-secret"
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = 30
    
    # Gemini / Groq
    GOOGLE_API_KEY: str = ""
    GROQ_API_KEY: str = ""
    
    # External APIs
    WAQI_API_KEY: str = ""
    OPENWEATHER_API_KEY: str = ""
    
    # App
    APP_ENV: str = "development"
    APP_DEBUG: bool = True
    CORS_ORIGINS: str = "*"
    
    @property
    def cors_origins_list(self) -> List[str]:
        origins = [origin.strip() for origin in self.CORS_ORIGINS.split(",")]
        # If wildcard is present, return just ["*"] for proper CORS handling
        if "*" in origins:
            return ["*"]
        return origins
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

settings = Settings()
