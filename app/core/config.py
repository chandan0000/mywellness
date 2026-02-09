from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # Primary DB URLs used by the app (can be provided via .env)
    DATABASE_ASYNC_URL: str | None = None
    DATABASE_SYNC_URL: str | None = None

    # Common alternative used by some docker setups
    DATABASE_URL: str | None = None

    # Security settings
    SECRET_KEY: str = "your-secret-key"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    ALGORITHM: str

    model_config = SettingsConfigDict(env_file=".env")


# Create a single, reusable instance of the settings
settings = Settings()
